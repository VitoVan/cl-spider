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

(defun get-what-I-want (uri &key selector attrs html)
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

;;(cl-spider:get-all-i-want "https://news.ycombinator.com/" :selector "tr.athing,tr.athing+tr" :desires '(((:selector . "td.title>a") (:attrs . ("href"))) ((:selector . "td.title>a") (:attrs . ("text"))) ((:selector . "td.subtext>span") (:attrs . ("text"))) ((:selector . "td.subtext>a[href^='user']") (:attrs . ("text")))))


(defun get-all-I-want (uri &key selector desires)
  (let* ((parent-html-list (get-what-I-want uri :selector selector)))
    (mapcar
     #'(lambda (parent-html)
         (let* ((result))
           (dolist (desire desires)
             (format t "DESIRES: ~A :::: ~A~%" desires parent-html)
             (setf result (append result
                                  (car (get-what-I-want nil
                                                        :selector (cdr (assoc ':selector desire))
                                                        :attrs (cdr (assoc ':attrs desire))
                                                        :html parent-html)))))
           result))
     parent-html-list)))

;;(cl-spider:get-all-i-want "https://news.ycombinator.com/" :selector "td.title" :desires '(((:selector . "a") (:attrs . ("href"))) ((:selector . "a") (:attrs . ("text"))) ((:selector . "span.rank") (:attrs . ("text")))))

