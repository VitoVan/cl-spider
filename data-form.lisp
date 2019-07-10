(in-package :cl-spider)

(defclass form()
  ((action :accessor form-action :initarg :action)
   (method :accessor form-method :initarg :method)
   (fields :accessor form-fields :initarg :fields)
   (cookie :accessor form-cookie :initarg :cookie)))

(defun assoc-string (string alist)
  (cdr (assoc string alist :test #'equal)))

(defun get-form (uri &key (selector "form") parameters)
  (let* ((cookie-jar (make-instance 'cookie-jar))
         (html-raw (get-html uri :cookie-jar cookie-jar))
         (form-raw (car (html-block-select
                         nil
                         :params parameters
                         :selector selector
                         :desires '(((:selector . "input") (:attrs . ("name" "value")))
                                    ((:selector . "form") (:attrs . ("action" "method"))))
                         :html html-raw)))
         (form-fields)
         (form-action)
         (form-method :get))
    (dolist (f form-raw)
      (let* ((f-value (assoc-string "value" f))
             (f-name (assoc-string "name" f))
             (f-action (assoc-string "action" f))
             (f-method (assoc-string "method" f)))
        (if f-name
            (push (cons f-name f-value) form-fields)
            (progn
              (setf form-action f-action)
              (setf form-method f-method)))))
    (make-instance 'form
                   :action form-action
                   :method form-method
                   :fields form-fields
                   :cookie cookie-jar)))

(defun update-form (key value form-obj)
  (let* ((fields (form-fields form-obj))
         (field (assoc key fields  :test #'equal)))
    (if field
        (rplacd
         field
         value)
        (setf
         (form-fields form-obj)
         (push (cons key value) fields)))))

(defun exec-form (form-obj &key base-url)
  (http-request
   (concatenate 'string base-url (form-action form-obj))
   :method (if (equal (form-method form-obj) "post") :post :get)
   :user-agent *cl-spider-user-agent*
   :parameters (form-fields form-obj)
   :cookie-jar (form-cookie form-obj)))
