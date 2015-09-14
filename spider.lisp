(in-package :cl-spider)

(defun get-html (uri &key (expected-code 200) (method :get) (max-content-length (* 1024 1024 2)) parameters)
  (let* ((response (multiple-value-list
                    (handler-case (drakma:http-request uri
                                                       :method method
                                                       :parameters parameters
                                                       :connection-timeout 5
                                                       :want-stream t)
                      (error
                          (condition)
                        (format nil "~A" condition)))))
         (s (car response))
         (header (nth 2 response))
         (content-length
          (or (parse-integer (write-to-string (drakma:header-value :content-length header)) :junk-allowed t)
              (progn (push '(:content-length . (write-to-string max-content-length)) header) max-content-length)))         
         (size-ok (and content-length (<= content-length max-content-length)))
         (code (nth 1 response)))
    (if (and code (= code expected-code))
        (if size-ok
            (car (multiple-value-list (drakma::read-body s header t)))
            "Too large")
        (or code response))))

(defun get-dom(html)
  (parse html))

(defun get-nodes(selector dom)
  (select selector dom))

(defun get-text(node)
  (string-trim '(#\Space #\Tab #\Newline) (text node)))

(defun get-data (uri &key selector attrs html)
  (handler-case (if (null selector)
                    (or html (get-html uri))
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
                         (get-nodes selector (get-dom (or html (get-html uri))))))
    (error
        (condition)
      (format nil "~A" condition))))

;;(cl-spider:get-data "https://news.ycombinator.com/" :selector "a" :attrs '("href" "text"))

(defun get-block-data (uri &key selector desires)
  (let* ((parent-html-list (get-data uri :selector selector)))
    (mapcar
     #'(lambda (parent-html)
         (let* ((result))
           (dolist (desire desires)
             (setf result (append result
                                  (car (get-data nil
                                                 :selector (cdr (assoc ':selector desire))
                                                 :attrs (cdr (assoc ':attrs desire))
                                                 :html parent-html)))))
           result))
     parent-html-list)))

;;(cl-spider:get-block-data "https://news.ycombinator.com/" 
;;                                   :selector "tr.athing" 
;;                                   :desires '(((:selector . "span.rank") (:attrs . ("text as rank")))
;;                                              ((:selector . "td.title>a") (:attrs . ("href as uri" "text as title")))
;;                                              ((:selector . "span.sitebit.comhead") (:attrs . ("text as site")))))
