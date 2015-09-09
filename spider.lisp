(setf sb-impl::*default-external-format* :UTF-8)
;;(declaim (optimize (debug 3)))
(ql:quickload '(drakma plump clss clack clack-v1-compat cl-json))

(defpackage cl-spider
  (:use :cl :drakma :plump :clss :clack :json))
(in-package :cl-spider)

(defun get-html (uri &key (expected-code 200) (method :get) parameters)
  (let* ((response (multiple-value-list (http-request uri :method method :parameters parameters)))
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

(defun get-what-I-want (uri selector &key attr)
  (map 'list
       #'(lambda (node)
           (if attr
               (attribute node attr)
               (get-text node)))
       (get-nodes selector (get-dom (get-html uri)))))

;;(get-what-i-want "http://sh.58.com/xiaoqu/xqlist_A_1/" "ul>li>a")

(defun gen-number-uri(uri-prefix &key (min 1) (max 10))
  (do ((index min (+ 1 index))
       (uri-list))
      ((> index max) uri-list)
    (push (concatenate 'string uri-prefix (write-to-string index)) uri-list)))

(defun get-multiple-what-I-want (uri-list selector &key attr)
  (let* ((result))
    (dolist (uri uri-list)
      (setf result (append (get-what-I-want uri selector :attr attr) result)))
    result))

;;(get-multiple-what-i-want
;;  '("http://sh.58.com/xiaoqu/xqlist_A_1/" "http://sh.58.com/xiaoqu/xqlist_B_1/") "ul>li>a" :attr "href")

(defvar *env* nil)

(defun app (env)
  (setf *env* env)
  (cond
    ((string= (getf env :path-info) "/")
     '(200 (:content-type "text/html") ("Hello fucker")))
    ((string= (getf env :path-info) "/doge")
     `(200 (:content-type "application/json" :fucker "hey")
           (,(format nil "~A" env))))
    (t
     '(404 (:content-type "text/plain") ("Not found")))))

(defvar *handler*)

(defun start-server ()
  (setf *handler*
        (clackup
         #'app
         :server :woo)))

(defun stop-server ()
  (stop *handler*))
