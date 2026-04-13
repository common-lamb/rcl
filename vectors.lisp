;; Copyright (c) 2006-2020 Carlos Ungil

(in-package :rcl)

(declaim (optimize speed))

;; FIXME strings bytes (complex? logical?)

(defun get-data-integers (sexp)
  (if (sexp-alt-p sexp)
      (let ((length (rf::rf-length sexp)))
	(loop for i from 0 below length
	      collect (rf::altinteger-elt sexp i)))
  (let ((start-data (cffi:inc-pointer sexp (cffi:foreign-type-size '(:struct rf::vector_sexprec))))
	(length (getf (sexp-vecsxp sexp) 'rf::length)))
    (loop for i from 0 below length
       collect (cffi:mem-aref start-data :int i)))))

(defun set-data-integers (sexp integers)
  (if (sexp-alt-p sexp)
      (let ((length (rf::rf-length sexp)))
	(dotimes (i (length integers))
	  (rf::altinteger-set-elt sexp i (if (elt integers i)
					     (coerce (elt integers i) 'integer)
					     rf::*r-naint*))))
      (let ((start-data (cffi:inc-pointer sexp (cffi:foreign-type-size '(:struct rf::vector_sexprec)))))
	(dotimes (i (length integers))
	  (setf (cffi:mem-aref start-data :int i)
		(if (elt integers i)
		    (coerce (elt integers i) 'integer)
		    rf::*r-naint*))))))

(defun get-data-reals (sexp)
  (if (sexp-alt-p sexp)
      (let ((length (rf::rf-length sexp)))
	(loop for i from 0 below length
	      collect (rf::altreal-elt sexp i)))
      (let ((start-data (cffi:inc-pointer sexp (cffi:foreign-type-size '(:struct rf::vector_sexprec))))
	    (length (getf (sexp-vecsxp sexp) 'rf::length)))
	(loop for i from 0 below length
	      collect (cffi:mem-aref start-data :double i)))))

(defun set-data-reals (sexp reals)
  (if (sexp-alt-p sexp)
      (let ((length (rf::rf-length sexp)))
	(dotimes (i (length reals))
	  (rf::altreal-set-elt sexp i (if (elt reals i)
					  (coerce (elt reals i) 'double-float)
					  rf::*r-nareal*))))
  (let ((start-data (cffi:inc-pointer sexp (cffi:foreign-type-size '(:struct rf::vector_sexprec)))))
    (dotimes (i (length reals))
      (setf (cffi:mem-aref start-data :double i)
	    (if (elt reals i)
		(coerce (elt reals i) 'double-float)
		rf::*r-nareal*))))))

(defun get-data-sexps (sexp)
  (let ((start-data (cffi:inc-pointer sexp (cffi:foreign-type-size '(:struct rf::vector_sexprec))))
	(length (getf (sexp-vecsxp sexp) 'rf::length)))
    (loop for i from 0 below length
       collect (cffi:mem-aref start-data '(:pointer (:struct rf::vector_sexprec)) i))))

(defun set-data-sexps (sexp pointers)
  (let ((start-data (cffi:inc-pointer sexp (cffi:foreign-type-size '(:struct rf::vector_sexprec)))))
    (dotimes (i (length pointers))
      (setf (cffi:mem-aref start-data '(:pointer (:struct rf::vector_sexprec)) i) (elt pointers i)))))

(defun get-data-strings (sexp)
  (let ((start-data (cffi:inc-pointer sexp (cffi:foreign-type-size '(:struct rf::vector_sexprec))))
	(length (getf (sexp-vecsxp sexp) 'rf::length)))
    (loop for i from 0 below length
       collect (r-to-lisp (cffi:mem-aref start-data :pointer i)))))

(defun set-data-strings (sexp strings)
  (let ((start-data (cffi:inc-pointer sexp (cffi:foreign-type-size '(:struct rf::vector_sexprec)))))
    (dotimes (i (length strings))
      (setf (cffi:mem-aref start-data :pointer i)
	    (if (elt strings i)
		(new-internal-char (elt strings i))
		rf::*r-nastring*)))))

(defun get-data-bytes (sexp)
  (let ((start-data (cffi:inc-pointer sexp (cffi:foreign-type-size '(:struct rf::vector_sexprec))))
	(length (getf (sexp-vecsxp sexp) 'rf::length)))
    (loop for i from 0 below length
       collect (cffi:mem-aref start-data :unsigned-char i))))

(defun set-data-bytes (sexp integers)
  (let ((start-data (cffi:inc-pointer sexp (cffi:foreign-type-size '(:struct rf::vector_sexprec)))))
    (dotimes (i (length integers))
      (setf (cffi:mem-aref start-data :unsigned-char i)
	    (if (elt integers i)
		(coerce (elt integers i) 'unsigned-byte)
		rf::*r-naint*)))))
