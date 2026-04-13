;; Copyright (c) 2006-2020 Carlos Ungil

(in-package :rcl)

(defclass r-pointer ()
  ((pointer :initarg :pointer :accessor pointer)))

;;  clisp    ffi:foreign-address 
;;  cmu      sys:system-area-pointer
;;  openmcl  ccl:macptr
;;  sbcl     sb-sys:system-area-pointer
;;  allegro  integer
;;  ecl      foreign

(defun r-obj-p (thing)
  (typep thing 'r-pointer))

(defgeneric r-header (sexp))

(defgeneric r-type (sexp))

(defgeneric sexp-alt-p (sexp))

(defgeneric sexp-unbound-p (sexp))

(defgeneric sexp-nil-p (sexp))

(defmethod r-header ((sexp r-pointer))
  (r-header (pointer sexp)))

(defmethod r-type ((sexp r-pointer))
  (r-type (pointer sexp)))

(defmethod sexp-alt-p ((sexp r-pointer))
  (sexp-alt-p (pointer sexp)))

(defmethod sexp-unbound-p ((sexp r-pointer))
  (sexp-unbound-p (pointer sexp)))

(defmethod sexp-nil-p ((sexp r-pointer))
  (sexp-nil-p (pointer sexp)))

(defgeneric r-to-lisp (sexp))

(defgeneric r-obj-describe (sexp))

(defmethod r-to-lisp ((sexp r-pointer))
  (r-to-lisp (pointer sexp)))

(defmethod r-obj-describe ((sexp r-pointer))
  (r-obj-describe (pointer sexp)))

(defmethod print-object ((r-pointer r-pointer) stream)
  (print-unreadable-object (r-pointer stream :type t :identity t)
    (format stream "~s ~s" (r-obj-describe r-pointer) (pointer r-pointer))))

(defvar *unprotect-runner* (make-instance 'simple-tasks:queued-runner))

(defun start-unprotect-runner ()
  (simple-tasks:make-runner-thread *unprotect-runner*)
  (loop until (eq :running (simple-tasks:status *unprotect-runner*)) do (bt:thread-yield)))

(defun schedule-unprotect-task (ptr)
  (simple-tasks:schedule-task
   (make-instance 'simple-tasks:call-task
		  :func (lambda () (rf::rf-unprotect-ptr ptr)))
   *unprotect-runner*))

#+(or abcl allegro cmucl ecl)
(defun schedule-unprotect-task (ptr)
  (rf::rf-unprotect-ptr ptr))

(defun make-r-pointer (ptr)
  (let ((r-pointer (make-instance 'r-pointer :pointer ptr)))
    (rf::rf-protect ptr)
    (trivial-garbage:finalize r-pointer
			      #-bordeaux-threads
			      (lambda () (rf::rf-unprotect-ptr ptr))
			      #+bordeaux-threads
			      (lambda () (schedule-unprotect-task ptr)))
    r-pointer))

