;; Copyright (c) 2006-2020 Carlos Ungil

(defpackage :rcl.test
  (:use "CL" "RCL" "FIVEAM")
  (:export "RUN"))

(in-package :rcl.test)

(defun run-tests ()
  (run! 'rcl.test::rcl-suite))

(def-suite rcl-suite)

(in-suite rcl-suite)

#+windows
(test r-home
  (is (remove #\/ (remove #\\ (r::getenv "R_HOME"))) (remove #\/ (remove #\\ r::*r-home*)))
  (is (remove #\/ (remove #\\ r::*r-home*)) (remove #\/ (remove #\\ (rf::get-r-home)))))

#-(or windows linux)
(test version
  (is (equal #\R (elt (r::version) 0))))

(test lib
  (is (not (null rcl::*r-lib-loaded*)))
  (is (string= r::*r-lib-name*
		   (pathname-name (cffi::foreign-library-pathname rcl::*r-lib-loaded*)))))

#+windows
(test embedded
  (is-true (stringp (rf::getdllversion)))
  (is-true (stringp (rf::getruser)))
  (is-true (stringp (rf::get-r-home))))

(test init
  (is (eq :running (r-init))))

;; (r:r-print (cffi:with-foreign-object (err :int)
;; 	      (rf::r-tryeval (rf::rf-findfun (rf::rf-install "R.Version") rf::*r-globalenv*) err)))

(test (basic-objects :depends-on init)
  (is-true (rf::rf-issymbol rf::*r-dimsymbol*))
  (is-true (rf::rf-isstring (rf::rf-mkstring "test")))
  (loop for vectype in (list r::intsxp r::realsxp r::cplxsxp
			     r::strsxp r::vecsxp r::lglsxp)
	collect (is-true (rf::rf-isvector (rf::rf-allocvector vectype 10)))))

#-linux
(test (altrep :depends-on init)
  (let ((range (rf::r-compact-intrange 100 200)))
    (is-true (rf::integer-is-sorted range))
    (is-true (rf::integer-no-na range))    
    (is-true (= 150 (rf::altinteger-elt range 50)))
    (is-true (= 15150
		    (first (r-to-lisp (rf::altinteger-sum range t)))
    		    (first (r-to-lisp (rf::altinteger-sum range nil)))))
    (is-true (equal
		  (cffi::with-foreign-object (buf :int 10)
		    (rf::INTEGER-GET-REGION range 50 10 buf)
		    (loop for i from 0 below 10 collect (cffi:mem-aref buf :int i)))
		  '(150 151 152 153 154 155 156 157 158 159))))
  (is-true (every #'identity (r "==" (rf::r-compact-intrange 2 4) (r%-parse-eval "2:4")))))

(test (environments :depends-on init)
  (is-true (rf::rf-isenvironment rf::*r-globalenv*))
  (is-true (rf::rf-isenvironment rf::*r-baseenv*))
  (is-true (rf::rf-isenvironment rf::*r-emptyenv*))
  (is (string= "<environment: R_EmptyEnv>"
		   (string-trim '(#\Newline) (r-print rf::*r-emptyenv* t))))
  (is (string= "<environment: R_GlobalEnv>"
		   (string-trim '(#\Newline) (r-print rf::*r-globalenv* t))))
  (is (string= "<environment: base>"
  		   (string-trim '(#\Newline) (r-print rf::*r-baseenv* t))))
  (is (equal (r-to-lisp (r::envsxp-hashtab (r::pointer (r% "new.env"))))
		 '(:|type| ("message"))))
  (is (string= (r::name (r::parent (r::parent (r "new.env")))) "package:stats")))

(test (basic :depends-on init)
  (let ((m (r::pointer (r% "matrix" nil 2 3))))
    (is-false (rf::rf-isnull m))
    (is-true (rf::rf-ismatrix m))
    (is (eq 6 (rf::rf-length m)))
    (is (eq 2 (rf::rf-nrows m)))
    (is (eq 3 (rf::rf-ncols m)))))

(test (formula :depends-on init)
  (let ((lc (r "x~y")))
    (is (eq 'r::language-construct (first lc)))
    (is (equal (mapcar #'r::name (second (r "x~y"))) '("~" "x" "y")))))

;; (let ((r::*r-funcall-debug* t)) (r::r-ignore "class" 1))
;; ("class" 1) 
;; (R::LANGUAGE-CONSTRUCT ((R::BUILTIN "class") (1))) 
;; ("integer")

(test (raw-bytes :depends-on init)
  (is (equal "test"
		 (coerce (mapcar #'code-char (r-to-lisp (r% "charToRaw" "test")))' string))))

(test (sum :depends-on init)
  (let ((sum (r "+" 2 2))
	(sum% (r% "+" 2 2)))
    (is (listp sum))
    (is (equal '(4) sum))
    (is (typep sum% 'r::r-pointer))
    (is (equal sum (r-to-lisp sum%)))))

(test (sum2 :depends-on init)
  (is (equal '(22 23 24) (r "+" 20 '(2 3 4)))))

(test (double :depends-on init)
  (is (equal '(2d0 3d0) (r-to-lisp (lisp-to-r '(2d0 3d0))))))

(test (integer :depends-on init)
  (is (equal '(2 3) (r-to-lisp (lisp-to-r '(2 3))))))

(test (new-string-single :depends-on init)
  (is (equal '("eo") (r-to-lisp (new-string-single "eo")))))

(test (new-string :depends-on init)
  (is (equal (loop repeat 10 collect "") (r-to-lisp (new-string 10)))))

(test (list :depends-on init)
  (is (equal (r "list" '("A" "B") '("C" "D")) '(("A" "B") ("C" "D")))))

(test (matrix :depends-on init)
  (is (equalp (r::matrix (r "matrix" '(1 2 3 4) :nrow 2 :byrow t))
		  #2A((1 2) (3 4)))))

;; (test matrix2
;;   (is (and (equal (r::names (r "matrix" '(1 2 3 4) :nrow 2 :dimnames '(("A" "B") ("C" "D"))))
;; 		      '(("A" "B") ("C" "D")))
;; 	       (equalp (r::matrix (r "matrix" '(1 2 3 4) :nrow 2 :dimnames '(("A" "B") ("C" "D"))))
;; 		       #2A((1 3) (2 4))))))

(test (gc :depends-on init)
  (let ((r:*r-streams* :console))
    (is (numberp (reduce #'+ (loop repeat 1000 append (r "runif" 1)))))))

(test (x11 :depends-on init)
  (is-true (progn (x11)
		      #-bordeaux-threads t
		      #+bordeaux-threads (bt:thread-alive-p r::*event-loop*))))

(test (plot :depends-on x11)
  (is-false (r "plot" (r% "rnorm" 20) (r% "rnorm" 20) :xlab "" :ylab "")))

;; restarting is not supported by R
#+NIL
(test init-and-quit-twice 
  (is (r:r-init))
  (is (null (r:r-quit)))
  (is (r:r-init))
  (is (null (r:r-quit))))
