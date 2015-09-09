;; -*- Lisp -*-
(in-package #:cl-user)

(defpackage #:cl-spider-system (:use #:cl #:asdf))

(in-package #:cl-spider-system)

(asdf:defsystem #:cl-spider
  :author "Vito Van"
  :serial t
  :components ((:file "package")
               (:file "spider"))
  :depends-on (:drakma :plump :clss))
