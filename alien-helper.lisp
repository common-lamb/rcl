;; Copyright (c) 2006-2020 Carlos Ungil

(in-package :rcl)

(defmacro with-float-traps-masked (&rest body)
  #+cmu `(ext:with-float-traps-masked
	    (:divide-by-zero :invalid)
	  ,@body)
  #+sbcl `(sb-int:with-float-traps-masked 
	      (:underflow :overflow :inexact :divide-by-zero :invalid)
	    ,@body)
  #-(or sbcl cmu) `(cl:progn ,@body))

(defmacro defcfun (name-and-options return-type &body args)
  "Defines a Lisp function that calls a foreign function."
  (let ((docstring (when (stringp (car args)) (pop args))))
    (multiple-value-bind (lisp-name foreign-name options)
        (cffi::parse-name-and-options name-and-options)
      (let ((name (intern (concatenate 'string "%" (symbol-name lisp-name)))))
	(if (eq (cffi::lastcar args) '&rest)
	    (append
	     (cffi::%defcfun-varargs name foreign-name return-type
				     (butlast args) options docstring)
	     `((defun ,lisp-name (,@(mapcar #'car (butlast args)))
		 (in-r-thread
		  (with-float-traps-masked
		      (,name ,@(mapcar #'car (butlast args))))))))
	    (append	    
	     (cffi::%defcfun name foreign-name return-type 
			     args options docstring)
	     `((defun ,lisp-name (,@(mapcar #'car args))
		 (in-r-thread
		  (with-float-traps-masked
		      (,name ,@(mapcar #'car args))))))))))))

(defvar *r-lock* (bordeaux-threads:make-lock))

(defmacro in-r-thread (&rest body)
  `(bordeaux-threads:with-lock-held (*r-lock*) ,@body))

#|

#-(or abcl allegro cmucl ecl)
(defmacro in-r-thread (&rest body)
  `(simple-tasks:with-body-as-task (*r-runner*)
     ,@body))

#+(or abcl allegro cmucl ecl)
(defmacro in-r-thread (&rest body)
  `(progn ,@body))

(defvar *r-runner* (make-instance 'simple-tasks:queued-runner))

(defun start-r-runner ()
  (simple-tasks:make-runner-thread *r-runner*)
  (loop until (eq :running (simple-tasks:status *r-runner*)) do (bt:thread-yield)))

|#
