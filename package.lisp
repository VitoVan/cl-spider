(in-package #:cl-user)

(defpackage #:cl-spider
  (:use #:common-lisp #:drakma #:plump #:clss)
  (:export
   #:get-data
   #:get-block-data
   #:*cl-spider-user-agent*))
