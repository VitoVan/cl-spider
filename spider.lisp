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
                        (cons attr
                              (if (equal attr "text")
                                  (get-text node)
                                  (attribute node attr))) results))
                     results)
                   (serialize node nil)))
           (get-nodes selector (get-dom (or html (get-html uri)))))))


;;(decode-json-from-string "[{\"selector\":\"ul>li\",\"attrs\":[\"name\",\"type\"]},{\"selector\":\"div\"}]")
