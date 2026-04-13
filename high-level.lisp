;; Copyright (c) 2006-2015 Carlos Ungil

(in-package :rcl)

;; with-r-streams is more robust, but closes all the existing connections
;;FIXME *r-streams* :values won't work properly if decoding produces values!

(defun r%-parse-eval (string)
  "Parse and evaluate the string in the R environment (returns r-pointer)"
  (with-r-streams (r-funcall "eval" (r-funcall "parse" :text string))))

(defun r-parse-eval (string)
  "Call r%-parse-eval and decode the result"
  (r-to-lisp (r%-parse-eval string)))

(defun r% (&rest args)
  "Apply the first argument to rest of the arguments (returns an r-pointer). 
If there is single string argument that looks like a formula (contains ~), calls r%-parse-eval instead."
  (if (and (= 1 (length args)) (stringp (first args)) (find #\~ (first args)))
      (r%-parse-eval (first args))
      (with-r-streams (apply #'r-funcall args))))

(defun r (&rest args)
  "Call r% and decode the result"
  (r-to-lisp (apply #'r% args)))

(defun r%-values (&rest args)
  "Like r%, but returning output and messages as additional value"
  (let ((*r-streams* :values)) (apply #'r% args)))

(defun r-values (&rest args)
  "Call r%-values and decode the result"
  (let ((vals (multiple-value-list (apply #'r%-values args))))
    (apply #'values (r-to-lisp (first vals)) vals)))

(defun r%-ignore (&rest args)
  "Like r%, but ignoring output and messages (will go to the terminal)"
  (apply #'r-funcall args))

(defun r-ignore (&rest args)
  "Like r%, but ignoring output and messages (will go to the terminal)"
  (r-to-lisp (apply #'r%-ignore args)))
	     
(defun r-print (x &optional to-string)
  "Calls R function print on the object (and returns nil)."
  (if to-string
      (multiple-value-bind (discard output message) (r%-values "print" x)
	(declare (ignore discard))
	(if (equal message "")
	    output
	    (values output message)))
      (progn
	(r% "print" x)
	nil)))

(defun r-summary (x &optional to-string)
  "Prints the R summary of the object (and returns nil)."
  (r-print (r% "summary" x) to-string))



