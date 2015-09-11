(in-package :cl-spider)

(defun get-html (uri &key (expected-code 200) (method :get) parameters)
  (let* ((response (multiple-value-list
                    (handler-case (drakma:http-request uri :method method :parameters parameters)
                      (error
                          (condition)
                        (format nil "~A" condition)))))
         (html (car response))
         (code (nth 1 response)))
    (if (and code (= code expected-code))
        html
        (or code response))))

(defun get-dom(html)
  (parse html))

(defun get-nodes(selector dom)
  (select selector dom))

(defun get-text(node)
  (string-trim '(#\Space #\Tab #\Newline) (text node)))

(defun get-data (uri &key selector attrs html)
  (if (null selector)
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
           (get-nodes selector (get-dom (or html (get-html uri)))))))

;;(cl-spider:get-data "https://news.ycombinator.com/" :selector "a" :attrs '("href" "text"))

(defun get-block-data (uri &key selector desires)
  (let* ((parent-html-list (get-what-I-want uri :selector selector)))
    (mapcar
     #'(lambda (parent-html)
         (let* ((result))
           (dolist (desire desires)
             (format t "DESIRES: ~A :::: ~A~%" desires parent-html)
             (setf result (append result
                                  (car (get-data nil
                                                        :selector (cdr (assoc ':selector desire))
                                                        :attrs (cdr (assoc ':attrs desire))
                                                        :html parent-html)))))
           result))
     parent-html-list)))

;;(cl-spider:get-block-data "https://news.ycombinator.com/" 
;;                                   :selector "tr.athing" 
;;                                   :desires '(((:selector . "span.rank") (:attrs . ("text")))
;;                                              ((:selector . "td.title>a") (:attrs . ("href" "text")))
;;                                              ((:selector . "span.sitebit.comhead") (:attrs . ("text")))))


