;; Copyright (c) 2006-2020 Carlos Ungil

(in-package :rcl)

;; the first version worked on PPC, but not on Intel
;; ppc:  671088768   #b 00101 0 00 0000000000000000 1 0 0 0 0 000
;; intel: 16777221   #b 000 0 0 0 0 1 0000000000000000 00 0 00101
;; there is something wrong with openmcl
;;       134217728   #b 00001000 00000000 00000000 00000000
;; (ldb version of sxpinfo-decode by Alexey Goldin)

#+ppc
(defun sxpinfo-decode (int)
  (let ((type  (ldb (byte 5 27) int))
	(obj   (ldb (byte 1 26) int))
	(named (ldb (byte 2 24) int))
	(gp    (ldb (byte 16 8) int))
	(mark  (ldb (byte 1 7) int))
	(debug (ldb (byte 1 6) int))
	(trace (ldb (byte 1 5) int))
	(fin   (ldb (byte 1 4) int))
	(gcgen (ldb (byte 1 3) int))
	(gccls (ldb (byte 3 0) int)))
    (list :type type :obj obj :named named :gp gp :mark mark
	  :debug debug :trace trace :fin fin :gcgen gcgen :gccls gccls)))

#-ppc
(defun sxpinfo-decode (int)
  #-ALTREP
  (let ((type  (ldb (byte 5 0) int))
	(obj   (ldb (byte 1 5) int))
	(named (ldb (byte 2 6) int)) 
	(gp    (ldb (byte 16 8) int))
	(mark  (ldb (byte 1 24) int))
	(debug (ldb (byte 1 25) int))
	(trace (ldb (byte 1 26) int))
	(fin   (ldb (byte 1 27) int))
	(gcgen (ldb (byte 1 28) int))
	(gccls (ldb (byte 3 29) int)))
    (list type obj named gp mark debug trace fin gcgen gccls))
  #+ALTREP
  (let ((type   (ldb (byte 5 0) int))
	(scalar (ldb (byte 1 5) int))
	(obj    (ldb (byte 1 6) int))
	(alt    (ldb (byte 1 7) int))
	(gp     (ldb (byte 16 8) int))
	(mark   (ldb (byte 1 24) int))
	(debug  (ldb (byte 1 25) int))
	(trace  (ldb (byte 1 26) int))
	(spare  (ldb (byte 1 27) int))
	(gcgen  (ldb (byte 1 28) int))
	(gccls  (ldb (byte 3 29) int))
	(named  (ldb (byte 16 32) int)))
    (list :type type :scalar scalar :obj obj :alt alt :gp gp :mark mark
	  :debug debug :trace trace :spare spare :gcgen gcgen :gccls gccls :named named)))

(defmethod r-header (sexp)
  #-ALTREP
  (values
   (sxpinfo-decode (getf (sexp-sxpinfo sexp) 'rf::bitfield)))
   ;;(sxpinfo-decode (sxpinfo-bitfield (sexp-sxpinfo sexp))))
  #+ALTREP
  (values
   (sxpinfo-decode (getf (sexp-sxpinfo sexp) 'rf::bitfield))))
   ;;(sxpinfo-decode (sxpinfo-bitfield (sexp-sxpinfo sexp)))))

(defmethod r-type (sexp)
  (cdr (assoc (getf (r-header sexp) :type) *r-types*)))

(defmethod sexp-alt-p (sexp)
  (plusp (getf (r-header sexp) :alt)))
 
(defmethod sexp-unbound-p (sexp)
  (= (cffi:pointer-address rf::*r-unboundvalue*)
     (cffi:pointer-address sexp)))

(defmethod sexp-nil-p (sexp)
  (= (cffi:pointer-address rf::*r-nilvalue*)
     (cffi:pointer-address sexp)))

(defmethod r-obj-describe (sexp)
  (cond
    ((sexp-unbound-p sexp) :unbound)
    ((sexp-nil-p sexp) nil)
    (t (let ((type (r-type sexp)))
	 (if (member type *r-vector-types*)
	     (list type :length (rf::rf-length sexp)
			:truelength (if (sexp-alt-p sexp)
					(rf::ALTREP-TRUELENGTH sexp)
					(getf (sexp-vecsxp sexp) 'rf::truelength)))
	     type)))))

(defun group-elements (list dims)
  (if (> (length dims) 1)
      (mapcar (lambda (x) (group-elements x (rest dims)))
	      (apply #'mapcar #'list (loop for i from 0 below (length list) by (first dims)
					collect (subseq list i (+ i (first dims))))))
      list))

(defun decode-promise (ptr)
  (make-instance 'r-promise
		 :value (promsxp-value ptr)
		 :expression (promsxp-expr ptr)
		 :environment (promsxp-env ptr)))

(defun decode-language-construct (ptr)
  (list 
   'language-construct
   (let ((car (r-to-lisp (listsxp-car ptr)))
	 (cdr (r-to-lisp (listsxp-cdr ptr))))
     (if (equal (r-type (listsxp-tag ptr)) :null)
	 (cons car cdr)
       (cons (intern (name (r-to-lisp (listsxp-tag ptr))) "KEYWORD") (cons car cdr))))))

(defun decode-closure (ptr)
  (warn "Closure")
  (list 'closure))

(defun decode-environment (ptr &optional attributes)
  (let ((name (getf attributes :|name|))
	(path (getf attributes :|path|)))
    (remf attributes :|name|)
    (remf attributes :|path|)
    (when (> (length name) 1) (warn "extra names ~A" name))
    (when (> (length path) 1) (warn "extra paths ~A" path))
    (when (> (length attributes) 0) (warn "extra attributes ~A" attributes))
    (make-instance 'r-environment :pointer ptr :name (first name) :path (first path))))
  
(defun decode-builtin (ptr)
  (list 'builtin (get-builtin-name (primsxp-offset ptr))))

(defmethod r-to-lisp (sexp)
  (cond
    ((sexp-nil-p sexp) nil)
    ((sexp-unbound-p sexp) :unbound)
    ((equal (r-type sexp) :null) :null)
    ((equal (r-type sexp) :special-form) :special-form)
    (t (let ((attributes (decode-attributes sexp))) ;; SEXP Rf_getAttrib(SEXP, SEXP)
;;	 (format t "~&Attributes: ~A~&" attributes)
	 (let ((names (getf attributes :|names|)) ;; Rf_namesgets(SEXP, SEXP) 
	       (rownames (getf attributes :|row.names|)) ;; Rf_rownamesgets (not defined anywhere?) / SEXP Rf_GetRowNames(SEXP)
	       (class (getf attributes :|class|)) ;; SEXP Rf_classgets(SEXP, SEXP)
	       (dim (getf attributes :|dim|)) ;; SEXP Rf_dimgets(SEXP, SEXP)
	       (dimnames (getf attributes :|dimnames|))) ;; SEXP Rf_dimnamesgets(SEXP, SEXP) / SEXP Rf_GetArrayDimnames(SEXP)
	   (remf attributes :|names|)
	   (remf attributes :|row.names|)
           (remf attributes :|class|)
	   (remf attributes :|dim|)
	   (remf attributes :|dimnames|)
;;	   (format t "~&~A Names: ~A~&" sexp names)
;;   	   (format t "~&~A Class: ~A~&" sexp class)
	   (if (member (r-type sexp) '(:generic-vector :logical-vector :string-vector
				       :real-vector :integer-vector :expressions-vector
				       :raw-bytes))
	       (let ((values (ecase (r-type sexp) 
			       (:generic-vector (mapcar #'r-to-lisp (get-data-sexps sexp)))
			       (:expressions-vector (mapcar #'r-to-lisp (get-data-sexps sexp)))
			       (:logical-vector (mapcar #'plusp (get-data-integers sexp)))
			       (:string-vector (get-data-strings sexp))
			       (:real-vector (get-data-reals sexp))
			       (:integer-vector (get-data-integers sexp))
			       (:raw-bytes (get-data-bytes sexp)))))
		 (if (find "data.frame" class :test #'string=)
		     (make-instance 'r-dataframe :data values :names names :rownames rownames)
		     (if (null names)
			 (if dim 
			     (make-instance 'r-matrix :matrix (make-array dim :initial-contents (group-elements values dim))
						      :names dimnames)
			     values)
			 (pairlis names values))))
	       (progn
		 (when names 
		   (error "I didn't expect to get names in a non-vector sexp"))
		 (case (r-type sexp)
		   (:symbol
		    (let ((list (sexp-union sexp)))
		      (make-instance 'r-symbol 
				     :name (r-to-lisp (symsxp-pname list))
				     :value (r-to-lisp (symsxp-value list))
				     :internal (r-to-lisp (symsxp-internal list)))))
		   (:list-of-dotted-pairs
			    (let* ((list (sexp-union sexp))
				   (tag (ignore-errors ;; FIXME?
					(intern (name (r-to-lisp (listsxp-tag list)))
						"KEYWORD")))
				   (car (r-to-lisp (listsxp-car list)))
				   (cdr (r-to-lisp (listsxp-cdr list))))
			      (if tag 
				  (cons tag (cons car cdr))
				  (cons car cdr))))
		   (:scalar-string-type
		    (cffi:foreign-string-to-lisp (cffi:inc-pointer sexp (cffi:foreign-type-size '(:struct rf::vector_sexprec)))))
		   (:promise
		    (decode-promise (sexp-union sexp)))
		   (:language-construct
		    (decode-language-construct (sexp-union sexp)))
		   (:closure
		    (decode-closure (sexp-union sexp)))
		   (:environments
		    (decode-environment (sexp-union sexp) attributes))
		   (:builtin-non-special-forms
		    (decode-builtin (sexp-union sexp)))
		   (t
		    (warn "unknown type ~A" (r-type sexp))
		    (list :unknown-type (r-type sexp)))))))))))
