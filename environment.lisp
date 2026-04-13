;; Copyright (c) 2006-2020 Carlos Ungil

(in-package :rcl)

(defclass r-environment (r-pointer)
  ((name :accessor name :initarg :name)
   (path :accessor path :initarg :path)))

(defmethod parent ((env r-environment))
  (let ((parent (envsxp-enclos (pointer env))))
    (cond ((sexp-nil-p parent) nil)
	  ((cffi::pointer-eq parent rf::*r-emptyenv*) :empty-environment)
	  (t (r-to-lisp parent)))))

(defmethod frame ((env r-environment))
  (r-to-lisp (envsxp-frame (pointer env))))

(defmethod hashtab ((env r-environment))
  (r-to-lisp (envsxp-hashtab (pointer env))))

(defmethod print-object ((env r-environment) stream) 
  (print-unreadable-object (env stream :type t :identity t)
     (format stream "~S ~S" (name env) (path env))))

