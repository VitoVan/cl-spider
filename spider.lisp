(setf sb-impl::*default-external-format* :UTF-8)
;;(declaim (optimize (debug 3)))
(ql:quickload '(drakma plump clss))

(defpackage cl-spider
  (:use :cl :drakma :plump :clss))
(in-package :cl-spider)

(defvar url-dicts "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")

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

(defun get-attribute(attr node)
  (attribute node attr))

;;This is not ok, people may want 0 - 9999, it's not regex thing
(defun gen-address(uri-prefix regex)
  (mapcar
   #'(lambda (letter)
       (concatenate 'string uri-prefix letter))
   (cl-ppcre:all-matches-as-strings regex url-dicts)))

(defun get-what-I-want (uri selector &key attr)
  (map 'list
       #'(lambda (node)
           (if attr
               (get-attribute attr node)
               (get-text node)))
       (get-nodes selector (get-dom (get-html uri)))))

(get-what-i-want "http://sh.58.com/xiaoqu/xqlist_A_1/" "ul>li>a")
