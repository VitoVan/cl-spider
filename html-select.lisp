(in-package :cl-spider)

(defun get-html (uri &key (expected-code 200) (method :get) parameters cookie-jar)
  "Get HTML strings from specific uri"
  (let* ((response (multiple-value-list
                    (handler-case (drakma:http-request uri
                                                       :method method
                                                       :parameters parameters
                                                       :connection-timeout *cl-spider-timeout-seconds*
                                                       :user-agent *cl-spider-user-agent*
                                                       :want-stream t
                                                       :cookie-jar cookie-jar)
                      (error
                          (condition)
                        (format nil "~A" condition)))))
         (s (car response))
         (header (nth 2 response))
         (content-length
          (or (drakma:header-value :content-length header)
              (progn (push '(:content-length . (write-to-string *cl-spider-max-length*)) header)
                     (write-to-string *cl-spider-max-length*))))
         (size-ok (and content-length (<= (parse-integer content-length :junk-allowed t) *cl-spider-max-length*)))
         (code (nth 1 response)))
    (if (and code (= code expected-code))
        (if size-ok
            (car (multiple-value-list (drakma::read-body s header t)))
            "Too large")
        (or code response))))

(defun get-dom(html)
  "Parse HTML strings to DOM"
  (parse html))

(defun get-nodes(selector dom)
  "Get nodes from DOM, by CSS selector"
  (select selector dom))

(defun get-text(node)
  "Get the text content in the node"
  (string-trim '(#\Space #\Tab #\Newline) (text node)))

(defun html-select (uri &key selector attrs html params)
  (handler-case (if (null selector)
                    (or html (get-html uri :parameters params))
                    (map 'list
                         #'(lambda (node)
                             (if attrs
                                 (let* ((results))
                                   (dolist (attr attrs)
                                     (push
                                      (cons (or (and (cl-ppcre:scan " as " attr) (cadr (cl-ppcre:split " as " attr))) attr)
                                            (if (cl-ppcre:scan "^text$|^text as " attr)
                                                (get-text node)
                                                (attribute node
                                                           (or (and (cl-ppcre:scan " as " attr) (car (cl-ppcre:split " as " attr))) attr)))) results))
                                   results)
                                 (serialize node nil)))
                         (get-nodes selector (get-dom (or html (get-html uri :parameters params))))))
    (error
        (condition)
      (format nil "~A" condition))))

;;(cl-spider:html-select "https://news.ycombinator.com/"
;;                       :selector "a"
;;                       :attrs '("href" "text"))

(defun html-block-select (uri &key selector desires params html)
  (let* ((parent-html-list (html-select uri :selector selector :params params :html html)))
    (mapcar
     #'(lambda (parent-html)
         (let* ((result))
           (dolist (desire desires)
             (setf result (append result
                                  (html-select nil
                                               :params params
                                               :selector (cdr (assoc ':selector desire))
                                               :attrs (cdr (assoc ':attrs desire))
                                               :html parent-html))))
           result))
     parent-html-list)))

;;(cl-spider:html-block-select
;; "https://news.ycombinator.com/" 
;; :selector "tr.athing" 
;; :desires '(((:selector . "span.rank") (:attrs . ("text as rank")))
;;            ((:selector . "td.title>a") (:attrs . ("href as uri" "text as title")))
;;            ((:selector . "span.sitebit.comhead") (:attrs . ("text as site")))))
