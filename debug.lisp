;; Copyright (c) 2006-2020 Carlos Ungil

(in-package :rcl)

(defun debug-sexprec (sexp)
  (format t "SXPINFO:    ~A~%" (sexp-sxpinfo sexp))
  (format t "[bitfield]  ~A~%" (sxpinfo-bitfield (sexp-sxpinfo sexp)))
  (format t "ATTRIB:     ~A~%" (sexp-attrib sexp))
  (format t "NEXT-NODE:  ~A~%" (sexp-next-node sexp))
  (format t "PREV-NODE:  ~A~%" (sexp-prev-node sexp))
  (format t "UNION:      ~A~%" (sexp-union sexp)))

(defun debug-info ()
  (format t "UNBOUND:   ~A~%NIL: ~A~%GLOBALENV: ~A" 
	  rf::*r-unboundvalue* rf::*r-nilvalue* (r-header rf::*r-globalenv*)))
