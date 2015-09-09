;; -*- Lisp -*-

(defpackage #:cl-spider-system
  (:use #:common-lisp #:asdf))

(in-package #:cl-spider-system)

(defsystem cl-spider
    :author "Vito Van"
    :serial t
    :components ((:file "package")
		 (:file "spider"))
    :depends-on (drakma plump clss))
