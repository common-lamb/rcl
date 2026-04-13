;; Copyright (c) 2006-2020 Carlos Ungil

(in-package :rcl.ffi)

;; include/Rinternals 797 - 862

;; /* ALTREP support */
;; void *(STDVEC_DATAPTR)(SEXP x);
;; int (IS_SCALAR)(SEXP x, int type);
;; int (ALTREP)(SEXP x);
;; SEXP ALTREP_DUPLICATE_EX(SEXP x, Rboolean deep);
;; SEXP ALTREP_COERCE(SEXP x, int type);
;; Rboolean ALTREP_INSPECT(SEXP, int, int, int, void (*)(SEXP, int, int, int));
;; SEXP ALTREP_SERIALIZED_CLASS(SEXP);
;; SEXP ALTREP_SERIALIZED_STATE(SEXP);
;; SEXP ALTREP_UNSERIALIZE_EX(SEXP, SEXP, SEXP, int, int);
;; R_xlen_t ALTREP_LENGTH(SEXP x);
;; R_xlen_t ALTREP_TRUELENGTH(SEXP x);
;; void *ALTVEC_DATAPTR(SEXP x);
;; const void *ALTVEC_DATAPTR_RO(SEXP x);
;; const void *ALTVEC_DATAPTR_OR_NULL(SEXP x);
;; SEXP ALTVEC_EXTRACT_SUBSET(SEXP x, SEXP indx, SEXP call);

(r::defcfun "ALTREP_LENGTH" :int64 (x SEXP))
(r::defcfun "ALTREP_TRUELENGTH" :int64 (x SEXP))

;; /* data access */
;; int ALTINTEGER_ELT(SEXP x, R_xlen_t i);
;; void ALTINTEGER_SET_ELT(SEXP x, R_xlen_t i, int v);
;; int ALTLOGICAL_ELT(SEXP x, R_xlen_t i);
;; void ALTLOGICAL_SET_ELT(SEXP x, R_xlen_t i, int v);
;; double ALTREAL_ELT(SEXP x, R_xlen_t i);
;; void ALTREAL_SET_ELT(SEXP x, R_xlen_t i, double v);
;; SEXP ALTSTRING_ELT(SEXP, R_xlen_t);
;; void ALTSTRING_SET_ELT(SEXP, R_xlen_t, SEXP);
;; Rcomplex ALTCOMPLEX_ELT(SEXP x, R_xlen_t i);
;; void ALTCOMPLEX_SET_ELT(SEXP x, R_xlen_t i, Rcomplex v);
;; Rbyte ALTRAW_ELT(SEXP x, R_xlen_t i);
;; void ALTRAW_SET_ELT(SEXP x, R_xlen_t i, Rbyte v);

(r::defcfun "ALTINTEGER_ELT" :int (x SEXP) (i :int64))
(r::defcfun "ALTINTEGER_SET_ELT" :void (x SEXP) (i :int64) (v :int))
(r::defcfun "ALTLOGICAL_ELT" :bool (x SEXP) (i :int64))
(r::defcfun "ALTLOGICAL_SET_ELT" :void (x SEXP) (i :int64) (v :bool))
(r::defcfun "ALTREAL_ELT" :int (x SEXP) (i :int64))
(r::defcfun "ALTREAL_SET_ELT" :void (x SEXP) (i :int64) (v :int))
(r::defcfun "ALTSTRING_ELT" :string (x SEXP) (i :int64))
(r::defcfun "ALTSTRING_SET_ELT" :void (x SEXP) (i :int64) (v :string))
;; (r::defcfun "ALTCOMPLEX_ELT" :int (x SEXP) 
;; (r::defcfun "ALTCOMPLEX_SET_ELT" :void (x SEXP) 
(r::defcfun "ALTRAW_ELT" :uint8 (x SEXP) (i :int64))
(r::defcfun "ALTRAW_SET_ELT" :void (x SEXP) (i :int64) (v :uint8))

;; R_xlen_t INTEGER_GET_REGION(SEXP sx, R_xlen_t i, R_xlen_t n, int *buf);
;; R_xlen_t REAL_GET_REGION(SEXP sx, R_xlen_t i, R_xlen_t n, double *buf);
;; R_xlen_t LOGICAL_GET_REGION(SEXP sx, R_xlen_t i, R_xlen_t n, int *buf);
;; R_xlen_t COMPLEX_GET_REGION(SEXP sx, R_xlen_t i, R_xlen_t n, Rcomplex *buf);
;; R_xlen_t RAW_GET_REGION(SEXP sx, R_xlen_t i, R_xlen_t n, Rbyte *buf);

(r::defcfun "INTEGER_GET_REGION" :int64 (sx SEXP) (i :int64) (n :int64) (buf (:pointer :int)))
(r::defcfun "REAL_GET_REGION" :int64 (sx SEXP) (i :int64) (n :int64) (buf (:pointer :double)))
(r::defcfun "LOGICAL_GET_REGION" :int64 (sx SEXP) (i :int64) (n :int64) (buf (:pointer :double)))
;; (r::defcfun "COMPLEX_GET_REGION" :int64 (sx SEXP)
(r::defcfun "RAW_GET_REGION" :int64 (sx SEXP) (i :int64) (n :int64) (buf (:pointer :uint8)))

;; /* metadata access */
;; int INTEGER_IS_SORTED(SEXP x);
;; int INTEGER_NO_NA(SEXP x);
;; int REAL_IS_SORTED(SEXP x);
;; int REAL_NO_NA(SEXP x);
;; int LOGICAL_IS_SORTED(SEXP x);
;; int LOGICAL_NO_NA(SEXP x);
;; int STRING_IS_SORTED(SEXP x);
;; int STRING_NO_NA(SEXP x);

(r::defcfun "INTEGER_IS_SORTED" :bool (x SEXP))
(r::defcfun "INTEGER_NO_NA" :bool (x SEXP))
(r::defcfun "REAL_IS_SORTED" :bool (x SEXP))
(r::defcfun "REAL_NO_NA" :bool (x SEXP))
(r::defcfun "LOGICAL_IS_SORTED" :bool (x SEXP))
(r::defcfun "LOGICAL_NO_NA" :bool (x SEXP))
(r::defcfun "STRING_IS_SORTED" :bool (x SEXP))
(r::defcfun "STRING_NO_NA" :bool (x SEXP))

;; /* invoking ALTREP class methods */
;; SEXP ALTINTEGER_SUM(SEXP x, Rboolean narm);
;; SEXP ALTINTEGER_MIN(SEXP x, Rboolean narm);
;; SEXP ALTINTEGER_MAX(SEXP x, Rboolean narm);
;;;; SEXP INTEGER_MATCH(SEXP, SEXP, int, SEXP, SEXP, Rboolean); /* NEVER DEFINED IN SOURCE */
;;;; SEXP INTEGER_IS_NA(SEXP x);  /* NEVER DEFINED IN SOURCE */
;; SEXP ALTREAL_SUM(SEXP x, Rboolean narm);
;; SEXP ALTREAL_MIN(SEXP x, Rboolean narm);
;; SEXP ALTREAL_MAX(SEXP x, Rboolean narm);
;;;; SEXP REAL_MATCH(SEXP, SEXP, int, SEXP, SEXP, Rboolean); /* NEVER DEFINED IN SOURCE */
;;;; SEXP REAL_IS_NA(SEXP x);  /* NEVER DEFINED IN SOURCE */
;; SEXP ALTLOGICAL_SUM(SEXP x, Rboolean narm);

(r::defcfun "ALTINTEGER_SUM" SEXP (x SEXP) (narm :bool))
(r::defcfun "ALTINTEGER_MIN" SEXP (x SEXP) (narm :bool))
(r::defcfun "ALTINTEGER_MAX" SEXP (x SEXP) (narm :bool))
;; (r::defcfun "INTEGER_MATCH" ;; NEVER DEFINED IN SOURCE
;; (r::defcfun "INTEGER_IS_NA" SEXP (x SEXP)) ;; NEVER DEFINED IN SOURCE
(r::defcfun "ALTREAL_SUM" SEXP (x SEXP) (narm :bool))
(r::defcfun "ALTREAL_MIN" SEXP (x SEXP) (narm :bool))
(r::defcfun "ALTREAL_MAX" SEXP (x SEXP) (narm :bool))
;; (r::defcfun "REAL_MATCH" ;; NEVER DEFINED IN SOURCE
;; (r::defcfun "REAL_IS_NA" SEXP (x SEXP)) ;; NEVER DEFINED IN SOURCE
(r::defcfun "ALTLOGICAL_SUM" SEXP (x SEXP) (narm :bool))

;; /* constructors for internal ALTREP classes */
;; SEXP R_compact_intrange(R_xlen_t n1, R_xlen_t n2);
;; SEXP R_deferred_coerceToString(SEXP v, SEXP info);
;;;; SEXP R_virtrep_vec(SEXP, SEXP); /* NEVER DEFINED IN SOURCE */
;; SEXP R_tryWrap(SEXP);
;; SEXP R_tryUnwrap(SEXP);

(r::defcfun "R_compact_intrange" SEXP (n1 :int64) (n2 :int64))
(r::defcfun "R_deferred_coerceToString" SEXP (v SEXP) (info SEXP))
;; (r::defcfun "R_virtrep_vec" ;; NEVER DEFINED IN SOURCE
(r::defcfun "R_tryWrap" SEXP (x SEXP))
(r::defcfun "R_tryUnwrap" SEXP (x SEXP))
