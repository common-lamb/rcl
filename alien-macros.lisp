;; Copyright (c) 2006-2020 Carlos Ungil

(in-package :rcl)

(defmacro new-language-construct (n)
  `(rf::rf-allocvector langsxp ,n))

(defmacro new-integer (n)
  `(rf::rf-allocvector intsxp ,n))

(defmacro new-real (n)
  `(rf::rf-allocvector realsxp ,n))

(defmacro new-complex (n)
  `(rf::rf-allocvector cplxsxp ,n))

(defmacro new-list (n)
  `(rf::rf-allocvector vecsxp ,n))

(defmacro new-logical (n)
  `(rf::rf-allocvector lglsxp ,n))

(defmacro new-character (n)
  `(rf::rf-allocvector strsxp ,n))

(defmacro new-string (n)
  `(rf::rf-allocvector strsxp ,n))

(defmacro new-string-single (string)
  `(rf::rf-mkstring ,string))

(defmacro new-internal-char (string)
  `(rf::rf-mkchar ,string))

(defmacro sexp-attrib (sexp)
  `(cffi:foreign-slot-value ,sexp '(:struct rf::SEXPREC) 'rf::attrib))

(defmacro sexp-next-node (sexp)
  `(cffi:foreign-slot-value ,sexp '(:struct rf::SEXPREC) 'rf::gengc_next_node))

(defmacro sexp-prev-node (sexp)
  `(cffi:foreign-slot-value ,sexp '(:struct rf::SEXPREC) 'rf::gengc_prev_node))

(defmacro sexp-union (sexp)
  `(cffi:foreign-slot-value ,sexp '(:struct rf::SEXPREC) 'rf::u))

(defmacro sexp-vecsxp (sexp)
  `(cffi:foreign-slot-value ,sexp '(:struct rf::VECTOR_SEXPREC) 'rf::vecsxp))

(defmacro sexp-sxpinfo (sexp)
  `(cffi:foreign-slot-value ,sexp '(:struct rf::SEXPREC) 'rf::sxpinfo))

(defmacro sxpinfo-bitfield (sxpinfo)
  `(cffi:foreign-slot-value ,sxpinfo '(:struct rf::sxpinfo_struct) 'rf::bitfield))

(defmacro vecsxp-length (vecsxp)
  `(cffi:foreign-slot-value ,vecsxp '(:struct rf::vecsxp_struct) 'rf::length))

(defmacro vecsxp-truelength (vecsxp)
  `(cffi:foreign-slot-value ,vecsxp '(:struct rf::vecsxp_struct) 'rf::truelength))

(defmacro listsxp-car (listsxp)
  `(cffi:foreign-slot-value ,listsxp '(:struct rf::listsxp_struct) 'rf::carval))

(defmacro listsxp-cdr (listsxp)
  `(cffi:foreign-slot-value ,listsxp '(:struct rf::listsxp_struct) 'rf::cdrval))

(defmacro listsxp-tag (listsxp)
  `(cffi:foreign-slot-value ,listsxp '(:struct rf::listsxp_struct) 'rf::tagval))

;; #define TAG(e)		((e)->u.listsxp.tagval)

(defmacro symsxp-pname (symsxp)
    `(cffi:foreign-slot-value ,symsxp '(:struct rf::symsxp_struct) 'rf::pname))

(defmacro symsxp-value (symsxp)
    `(cffi:foreign-slot-value ,symsxp '(:struct rf::symsxp_struct) 'rf::value))

(defmacro symsxp-internal (symsxp)
    `(cffi:foreign-slot-value ,symsxp '(:struct rf::symsxp_struct) 'rf::internal))

(defmacro primsxp-offset (primsxp)
    `(cffi:foreign-slot-value ,primsxp '(:struct rf::primsxp_struct) 'rf::offset))

(defmacro promsxp-value (promsxp)
    `(cffi:foreign-slot-value ,promsxp '(:struct rf::promsxp_struct) 'rf::value))

(defmacro promsxp-expr (promsxp)
    `(cffi:foreign-slot-value ,promsxp '(:struct rf::promsxp_struct) 'rf::expr))

(defmacro promsxp-env (promsxp)
    `(cffi:foreign-slot-value ,promsxp '(:struct rf::promsxp_struct) 'rf::env))

(defmacro envsxp-frame (envsxp)
    `(cffi:foreign-slot-value ,envsxp '(:struct rf::envsxp_struct) 'rf::frame))

(defmacro envsxp-enclos (envsxp)
    `(cffi:foreign-slot-value ,envsxp '(:struct rf::envsxp_struct) 'rf::enclos))

(defmacro envsxp-hashtab (envsxp)
    `(cffi:foreign-slot-value ,envsxp '(:struct rf::envsxp_struct) 'rf::hashtab))
