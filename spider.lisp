(setf sb-impl::*default-external-format* :UTF-8)
;;(declaim (optimize (debug 3)))
(ql:quickload '(drakma plump clss cl-json hunchentoot))

(defpackage cl-spider
  (:use :cl :plump :clss :json :hunchentoot))
(in-package :cl-spider)

(defun get-html (uri &key (expected-code 200) (method :get) parameters)
  (let* ((response (multiple-value-list (drakma:http-request uri :method method :parameters parameters)))
         (html (car response))
         (code (nth 1 response)))
    (if (= code expected-code)
        html
        code)))

(defun get-dom(html)
  (parse html))

(defun get-nodes(selector dom)
  (select selector dom))

(defun get-text(node)
  (string-trim '(#\Space #\Tab #\Newline) (text node)))

(defun get-what-I-want (uri selector &key attrs)
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
                 (if (= 1 (length attrs))
                     (car results)
                     results))
               (get-text node)))
       (get-nodes selector (get-dom (get-html uri)))))

;;(get-what-i-want "http://sh.58.com/xiaoqu/xqlist_A_1/" "ul>li>a")

;;(get-what-i-want "http://sh.58.com/xiaoqu/xqlist_A_1/" "ul>li>a" :attrs '("href" "text"))

;; Start Hunchentoot
(setf *show-lisp-errors-p* t)
(setf *acceptor* (make-instance 'hunchentoot:easy-acceptor
                                :port 5000
                                :access-log-destination "log/access.log"
                                :message-log-destination "log/message.log"
                                :error-template-directory  "www/errors/"
                                :document-root "www/"))

(defun start-server ()
  (start *acceptor*))

(defun controller-doge-wow()
  (setf (hunchentoot:content-type*) "application/json")
  (format nil "~A" *request*))

(defun controller-doge-new()
  (setf (hunchentoot:content-type*) "application/json")
  (format nil "~A" *request*))

(defun controller-doge-test()
  (setf (hunchentoot:content-type*) "application/json")
  (encode-json-to-string
   (get-what-i-want
    (parameter "uri")
    (parameter "selector")
    :attrs (decode-json-from-string (parameter "attrs")))))

(setf *dispatch-table*
      (list
       (create-regex-dispatcher "^/doge/wow$" 'controller-doge-wow)
       (create-regex-dispatcher "^/doge/new$" 'controller-doge-new)
       (create-regex-dispatcher "^/doge/test$" 'controller-doge-test)))

(start-server)
