(in-package :cl-spider)
;; set default encode system
(setf drakma:*drakma-default-external-format* :UTF-8)

;; customization
(defvar *cl-spider-user-agent* "cl-spider")
(defvar *cl-spider-max-length* (* 1024 1024 2))
(defvar *cl-spider-timeout-seconds* 5)
