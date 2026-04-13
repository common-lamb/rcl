;; Copyright (c) 2006-2014 Carlos Ungil

(in-package :rcl)

;; (r "as.data.frame" (r% "matrix" 1 2 3 :dimnames '(("a" "b") ("X" "Y" "Z"))))

(defclass r-dataframe ()
  ((data :accessor data :initarg :data)
   (names :accessor names :initarg :names)
   (rownames :accessor rownames :initarg :rownames)))

(defmethod print-object ((dataframe r-dataframe) stream) 
  (print-unreadable-object (dataframe stream :type t :identity t)
    (let ((rownames (rownames dataframe))
	  (colnames (names dataframe))
	  (nrows (length (first (data dataframe))))
	  (ncols (length (data dataframe))))
      (format stream "~s rows, ~s columns, column names ~{~s~^ ~}~A"
	      nrows ncols colnames
	      (format nil ", row names ~{~s~^ ~}" rownames)))))

