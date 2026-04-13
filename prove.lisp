;; Copyright (c) 2006-2020 Carlos Ungil

(defpackage "RCL.PROVE"
  (:use "CL" "RCL" "PROVE"))

(in-package :rcl.prove)

(if (ignore-errors (equal (package-name (symbol-package (synonym-stream-symbol *standard-output*)))
			  "SWANK"))
    (setf *enable-colors* nil))

(setf *default-reporter* :fiveam)

(plan 7)

(isnt r::*r-lib-loaded* nil)

#+(or windows linux) (skip 1 "PrintVersionString hidden on Windows and Linux")
#-(or windows linux) (is-type (r::version) 'string)

(is (pathname-name (cffi::foreign-library-pathname rcl::*r-lib-loaded*)) r::*r-lib-name*)

#-windows (skip 1 "Windows-only functions")

#+windows (subtest "Windows-only functions"
	    (is-type (rf::getdllversion) 'string)
	    (is-type (rf::getruser) 'string)
	    (is-type (rf::get-r-home) 'string))

#-windows (skip 1 "R_HOME relevant only on Windows")

#+windows (subtest "R_HOME"
		   (is (remove #\/ (remove #\\ (r::getenv "R_HOME"))) (remove #\/ (remove #\\ r::*r-home*)))
		   (is (remove #\/ (remove #\\ r::*r-home*)) (remove #\/ (remove #\\ (rf::get-r-home)))))

(is (r-init) :running)

;; ;; (r:r-print (cffi:with-foreign-object (err :int)
;; ;; 	      (rf::r-tryeval (rf::rf-findfun (rf::rf-install "R.Version") rf::*r-globalenv*) err)))

(subtest "basic-objects"
  (is (rf::rf-issymbol rf::*r-dimsymbol*) t)
  (is (rf::rf-isstring (rf::rf-mkstring "test")) t)
  (loop for vectype in (list r::intsxp r::realsxp r::cplxsxp
 			     r::strsxp r::vecsxp r::lglsxp)
 	collect (is (rf::rf-isvector (rf::rf-allocvector vectype 10)) t)))

;; #-linux
;; (5am:test (altrep :depends-on init)
;;   (let ((range (rf::r-compact-intrange 100 200)))
;;     (5am:is-true (rf::integer-is-sorted range))
;;     (5am:is-true (rf::integer-no-na range))    
;;     (5am:is-true (= 150 (rf::altinteger-elt range 50)))
;;     (5am:is-true (= 15150
;; 		    (first (r-to-lisp (rf::altinteger-sum range t)))
;;     		    (first (r-to-lisp (rf::altinteger-sum range nil)))))
;;     (5am:is-true (equal
;; 		  (cffi::with-foreign-object (buf :int 10)
;; 		    (rf::INTEGER-GET-REGION range 50 10 buf)
;; 		    (loop for i from 0 below 10 collect (cffi:mem-aref buf :int i)))
;; 		  '(150 151 152 153 154 155 156 157 158 159))))
;;   (5am:is-true (every #'identity (r "==" (rf::r-compact-intrange 2 4) (r%-parse-eval "2:4")))))

;; (5am:test (environments :depends-on init)
;;   (5am:is-true (rf::rf-isenvironment rf::*r-globalenv*))
;;   (5am:is-true (rf::rf-isenvironment rf::*r-baseenv*))
;;   (5am:is-true (rf::rf-isenvironment rf::*r-emptyenv*))
;;   (5am:is (string= "<environment: R_EmptyEnv>"
;; 		   (string-trim '(#\Newline) (r-print rf::*r-emptyenv* t))))
;;   (5am:is (string= "<environment: R_GlobalEnv>"
;; 		   (string-trim '(#\Newline) (r-print rf::*r-globalenv* t))))
;;   (5am:is (string= "<environment: base>"
;;   		   (string-trim '(#\Newline) (r-print rf::*r-baseenv* t))))
;;   (5am:is (equal (r-to-lisp (r::envsxp-hashtab (r::pointer (r% "new.env"))))
;; 		 '(:|type| ("message"))))
;;   (5am:is (string= (r::name (r::parent (r::parent (r "new.env")))) "package:stats")))

;; (5am:test (basic :depends-on init)
;;   (let ((m (r::pointer (r% "matrix" nil 2 3))))
;;     (5am:is-false (rf::rf-isnull m))
;;     (5am:is-true (rf::rf-ismatrix m))
;;     (5am:is (eq 6 (rf::rf-length m)))
;;     (5am:is (eq 2 (rf::rf-nrows m)))
;;     (5am:is (eq 3 (rf::rf-ncols m)))))

;; (5am:test (formula :depends-on init)
;;   (let ((lc (r "x~y")))
;;     (5am:is (eq 'r::language-construct (first lc)))
;;     (5am:is (equal (mapcar #'r::name (second (r "x~y"))) '("~" "x" "y")))))

;; ;; (let ((r::*r-funcall-debug* t)) (r::r-ignore "class" 1))
;; ;; ("class" 1) 
;; ;; (R::LANGUAGE-CONSTRUCT ((R::BUILTIN "class") (1))) 
;; ;; ("integer")

;; (5am:test (raw-bytes :depends-on init)
;;   (5am:is (equal "test"
;; 		 (coerce (mapcar #'code-char (r-to-lisp (r% "charToRaw" "test")))' string))))

;; (5am:test (sum :depends-on init)
;;   (let ((sum (r "+" 2 2))
;; 	(sum% (r% "+" 2 2)))
;;     (5am:is (listp sum))
;;     (5am:is (equal '(4) sum))
;;     (5am:is (typep sum% 'r::r-pointer))
;;     (5am:is (equal sum (r-to-lisp sum%)))))

;; (5am:test (sum2 :depends-on init)
;;   (5am:is (equal '(22 23 24) (r "+" 20 '(2 3 4)))))

;; (5am:test (double :depends-on init)
;;   (5am:is (equal '(2d0 3d0) (r-to-lisp (lisp-to-r '(2d0 3d0))))))

;; (5am:test (integer :depends-on init)
;;   (5am:is (equal '(2 3) (r-to-lisp (lisp-to-r '(2 3))))))

;; (5am:test (new-string-single :depends-on init)
;;   (5am:is (equal '("eo") (r-to-lisp (new-string-single "eo")))))

;; (5am:test (new-string :depends-on init)
;;   (5am:is (equal (loop repeat 10 collect "") (r-to-lisp (new-string 10)))))

;; (5am:test (list :depends-on init)
;;   (5am:is (equal (r "list" '("A" "B") '("C" "D")) '(("A" "B") ("C" "D")))))

;; (5am:test (matrix :depends-on init)
;;   (5am:is (equalp (r::matrix (r "matrix" '(1 2 3 4) :nrow 2 :byrow t))
;; 		  #2A((1 2) (3 4)))))

;; ;; (5am:test matrix2
;; ;;   (5am:is (and (equal (r::names (r "matrix" '(1 2 3 4) :nrow 2 :dimnames '(("A" "B") ("C" "D"))))
;; ;; 		      '(("A" "B") ("C" "D")))
;; ;; 	       (equalp (r::matrix (r "matrix" '(1 2 3 4) :nrow 2 :dimnames '(("A" "B") ("C" "D"))))
;; ;; 		       #2A((1 3) (2 4))))))

;; (5am:test (gc :depends-on init)
;;   (let ((r:*r-streams* :console))
;;     (5am:is (numberp (reduce #'+ (loop repeat 1000 append (r "runif" 1)))))))

;; (5am:test (x11 :depends-on init)
;;   (5am:is-true (progn (x11)
;; 		      #-bordeaux-threads t
;; 		      #+bordeaux-threads (bt:thread-alive-p r::*event-loop*))))

;; (5am:test (plot :depends-on x11)
;;   (5am:is-false (r "plot" (r% "rnorm" 20) (r% "rnorm" 20) :xlab "" :ylab "")))

;; ;; restarting is not supported by R
;; #+NIL
;; (5am:test init-and-quit-twice 
;;   (5am:is (r:r-init))
;;   (5am:is (null (r:r-quit)))
;;   (5am:is (r:r-init))
;;   (5am:is (null (r:r-quit))))


(finalize)
