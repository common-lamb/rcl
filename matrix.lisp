;; Copyright (c) 2006-2014 Carlos Ungil

(in-package :rcl)

(defclass r-matrix ()
  ((matrix :accessor matrix :initarg :matrix)
   (names :accessor names :initarg :names)))

(defmethod print-object ((matrix r-matrix) stream) 
  (print-unreadable-object (matrix stream :type t :identity t)
    (format stream "~s ~s" (matrix matrix) (names matrix))))

;; (r "matrix" 1 2 3 :dimnames '(("a" "b") ("X" "Y" "Z")))

;; (r "matrix" 1 1 1)

;; (r "matrix" 1 2 3 :dimnames '(("X" "Y" "Z"))) ;; CAPTURE ERROR !!!!

