;; Copyright (c) 2006-2015 Carlos Ungil

(declaim (optimize (debug 3)))

(in-package :rcl)

(defvar *r-funcall-debug* nil)

(defvar *downcase-argnames* t
  "By default, if an argument name is all uppercase it will be converted to downcase.
This makes (r \"sum\" x :na.rm t) equivalent to (r \"sum\" x :|na.rm| t).
Disable the automatic conversion if you need to pass all-uppercase argument names to R.")

(defun r%-symbol (name)
  "Intern the symbol in the R image"
  (rf::rf-install name))

(defun r%-variable (name)
  "Find the variable in the R image"
  (rf::rf-findvar (rf::rf-install name) rf::*r-globalenv*))

(defun r-symbol (name)
  "Intern the symbol in the R image"
  (make-r-pointer (r%-symbol name)))

(defun r-variable (name)
  "Find the variable in the R image"
  (make-r-pointer (r%-variable name)))

(defun r-function (name)
  "Find the function in the R image"
  (when (member (r-type (rf::rf-findvar (rf::rf-install name) rf::*r-globalenv*))
		'(:promise :closure :special-form 
		  :builtin-non-special-forms))
    (let ((result (rf::rf-findfun (rf::rf-install name) rf::*r-globalenv*)))
      (when result (make-instance 'r-pointer :pointer result)))))
    
(defun r-funcall (function &rest args)
  "Call the function in the R image"
  (unless (eq *r-session* :running)
    (cerror "Run (r-init)" "R is not running")
    (r-init))
  (when *r-funcall-debug* (print `(,function ,@args) (terpri)))
  (cffi:with-foreign-object (error-occurred :int)
    (let ((command (new-language-construct (1+ (count-if-not #'keywordp args))))
	  (r-function (r-function function)))
      (unless r-function (error "~A is not a valid function" function))
      (let ((list (sexp-union command)) 
	    cdr)
	(setf (listsxp-car list) (pointer r-function))
	(loop while args
	      do (let ((arg (pop args)))
		   (setf cdr (listsxp-cdr list))
		   (setf list (sexp-union cdr))
		   ;; named argument passed as two successive arguments :name value
		   (when (keywordp arg)
		     (setf (listsxp-tag list)
			   (rf::rf-install (let ((sname (substitute #\_ #\- (symbol-name arg))))
					     (if (and *downcase-argnames* (string= sname (string-upcase sname)))
						 (string-downcase sname)
						 sname)))
			   arg (pop args)))
		   ;; named argument passed as cons (:name . value)
		   (when (and (consp arg) (keywordp (car arg)))
		     (setf (listsxp-tag list)
			   (rf::rf-install (let ((sname (substitute #\_ #\- (symbol-name (car arg)))))
					     (if (and *downcase-argnames* (string= sname (string-upcase sname)))
						 (string-downcase sname)
						 sname)))
			   arg (cdr arg)))
		   (setf (listsxp-car list) (lisp-to-r arg)))))
      (when *r-funcall-debug* (print (r-to-lisp command)) (terpri))
      (let ((result (rf::r-tryeval command rf::*r-globalenv* error-occurred)))
	(if (zerop (cffi:mem-aref error-occurred :int))
	    (make-r-pointer result)
	    (handler-bind ((error #'abort))
	      ;;(print (cffi:mem-aref error-occurred :int))
	      ;;(print (type-of error-occurred))
	      ;;(describe error-occurred)
	      (error "error calling ~A" function)))))))

