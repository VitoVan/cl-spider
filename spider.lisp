(setf sb-impl::*default-external-format* :UTF-8)
;;(declaim (optimize (debug 3)))
(ql:quickload '(drakma plump clss cl-json hunchentoot cl-mongo))

(defpackage cl-spider
  (:use :cl :plump :clss :json :hunchentoot :cl-mongo))
(in-package :cl-spider)

;;init db
(db.use "cl-spider")

(defun cache-uri(uri html)
  (db.update
   "cache"
   ($ "uri" uri)
   (kv ($set "time" (get-universal-time)) ($set "html" html))
   :upsert t :multi t))

(defun get-cache(uri)
  (get-element "html"
               (car (docs
                     (db.find "cache"
                              (kv
                               (kv "uri" uri)
                               ($>= "time" (- (get-universal-time) (* 60 2)))))))))

(defun get-html (uri &key (expected-code 200) (method :get) parameters)
  (or
   (get-cache uri)
   (let* ((response (multiple-value-list
                     (handler-case (drakma:http-request uri :method method :parameters parameters)
                       (error
                           (condition)
                         (format nil "~A" condition)))))
          (html (car response))
          (code (nth 1 response)))
     (if (and code (= code expected-code))
         (progn (cache-uri uri html) html)
         (or code response)))))

(defun get-dom(html)
  (parse html))

(defun get-nodes(selector dom)
  (select selector dom))

(defun get-text(node)
  (string-trim '(#\Space #\Tab #\Newline) (text node)))

(defun get-what-I-want (uri &key selector attrs)
  (if (null selector)
      (get-html uri)
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
           (get-nodes selector (get-dom (get-html uri))))))

;;(get-what-i-want "http://sh.58.com/xiaoqu/xqlist_A_1/")
;;(get-what-i-want "http://sh.58.com/xiaoqu/xqlist_A_1/" :selector "ul>li>a")
;;(get-what-i-want "http://sh.58.com/xiaoqu/xqlist_A_1/" :selector "ul>li>a" :attrs '("href" "text"))

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
  (if (null (parameter "selector"))
      (progn
        (setf (hunchentoot:content-type*) "text/plain")
        (get-what-i-want (parameter "uri")))
      (progn
        (setf (hunchentoot:content-type*) "application/json")
        (encode-json-to-string
         (get-what-i-want
          (parameter "uri")
          :selector (parameter "selector")
          :attrs (and (parameter "attrs") (decode-json-from-string (parameter "attrs"))))))))

;;http://cl-spider.vito/doge/test?uri=http://v2ex.com/
;;http://cl-spider.vito/doge/test?uri=http://v2ex.com/&selector=span.item_title
;;http://cl-spider.vito/doge/test?uri=http://v2ex.com/&selector=span.item_title>a&attrs=["href","text"]

(setf *dispatch-table*
      (list
       (create-regex-dispatcher "^/doge/wow$" 'controller-doge-wow)
       (create-regex-dispatcher "^/doge/new$" 'controller-doge-new)
       (create-regex-dispatcher "^/doge/test$" 'controller-doge-test)))

(start-server)
