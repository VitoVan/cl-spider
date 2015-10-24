(in-package #:cl-user)

(defpackage #:cl-spider
  (:use #:common-lisp #:drakma #:plump #:clss)
  (:export
   #:html-select
   #:html-block-select
   #:*cl-spider-user-agent*
   #:*cl-spider-max-length*
   #:*cl-spider-timeout-seconds*))
