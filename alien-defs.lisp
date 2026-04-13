;; Copyright (c) 2006-2020 Carlos Ungil

(in-package :rcl.ffi)

(cffi:defctype SEXP :pointer)

#-ALTREP
;;  :type  5  :obj   1  :named 2
;;  :gp   16
;;  :mark 1   :debug 1  :trace 1  :fin   1  :gcgen  1  :gccls 3
(cffi:defcstruct sxpinfo_struct
  (bitfield :unsigned-int))

#+ALTREP
;;  :type   5  :scalar 1  :obj    1  :alt   1
;;  :gp    16
;;  :mark   1  :debug  1  :trace  1  :spare 1  :gcgen  1  :gccls 3
;;  :named 16  :extra 16
(cffi:defcstruct sxpinfo_struct
  (bitfield :unsigned-long-long))

(cffi:defcstruct primsxp_struct
  (offset :int))

(cffi:defcstruct symsxp_struct
  (pname :pointer)
  (value :pointer)
  (internal :pointer))

(cffi:defcstruct listsxp_struct
  (carval :pointer)
  (cdrval :pointer)
  (tagval :pointer))

(cffi:defcstruct envsxp_struct
  (frame :pointer)
  (enclos :pointer)
  (hashtab :pointer))

(cffi:defcstruct closxp_struct
  (formals :pointer)
  (body :pointer)
  (env :pointer))

(cffi:defcstruct promsxp_struct
  (value :pointer)
  (expr :pointer)
  (env :pointer))

(cffi:defcunion SEXPREC_UNION
 (primsxp (:struct primsxp_struct))
 (symsxp (:struct symsxp_struct))
 (listsxp (:struct listsxp_struct))
 (envsxp (:struct envsxp_struct))
 (closxp (:struct closxp_struct))
 (promsxp (:struct promsxp_struct)))

(cffi:defcstruct SEXPREC
  (sxpinfo (:struct sxpinfo_struct))
  (attrib :pointer)
  (gengc_next_node :pointer)
  (gengc_prev_node :pointer)
  (u (:union SEXPREC_UNION)))

#-ALTREP
(cffi:defcstruct vecsxp_struct
  (length :int32)
  (truelength :int32))

#+ALTREP
(cffi:defcstruct vecsxp_struct
  (length :int64)
  (truelength :int64))

(cffi:defcstruct VECTOR_SEXPREC
  (sxpinfo (:struct sxpinfo_struct))
  (attrib :pointer)
  (gengc_next_node :pointer)
  (gengc_prev_node :pointer)
  (vecsxp (:struct vecsxp_struct)))

(cffi:defcunion SEXPREC_ALIGN
  (s (:struct VECTOR_SEXPREC))
  (align :double))

(cffi:defcstruct Rcomplex
  (r :double)
  (i :double))

;; Rinternals.h lines 996 to 1019
(cffi:defcvar ("R_GlobalEnv" :read-only t) SEXP)
(cffi:defcvar ("R_EmptyEnv" :read-only t) SEXP)
(cffi:defcvar ("R_BaseEnv" :read-only t) SEXP)
(cffi:defcvar ("R_BaseNamespace" :read-only t) SEXP)
(cffi:defcvar ("R_NamespaceRegistry" :read-only t) SEXP)
(cffi:defcvar ("R_NilValue" :read-only t) SEXP)
(cffi:defcvar ("R_UnboundValue" :read-only t) SEXP)
(cffi:defcvar ("R_MissingArg" :read-only t) SEXP)
(cffi:defcvar ("R_InBCInterpreter" :read-only t) SEXP)
(cffi:defcvar ("R_Srcref" :read-only t) SEXP)
(cffi:defcvar ("R_CurrentExpression" :read-only t) SEXP)
(cffi:defcvar ("R_RestartToken" :read-only t) SEXP)

(cffi:defcvar ("R_NamesSymbol" :read-only t) SEXP)
(cffi:defcvar ("R_DimSymbol" :read-only t) SEXP)

(cffi:defcvar ("R_NaN" :read-only t) SEXP)
(cffi:defcvar ("R_PosInf" :read-only t) SEXP)
(cffi:defcvar ("R_NegInf" :read-only t) SEXP)

(cffi:defcvar ("R_NaReal" :read-only t) SEXP) ;; real
(cffi:defcvar ("R_NaInt" :read-only t) SEXP) ;; logical, integer
(cffi:defcvar ("R_NaString" :read-only t) SEXP) ;; string

(r::defcfun "Rf_install" SEXP (str :string))
(r::defcfun "Rf_findFun" SEXP (fun SEXP) (rho SEXP))
(r::defcfun "Rf_findVar" SEXP (var SEXP) (rho SEXP))
(r::defcfun "Rf_eval" SEXP (expr SEXP) (rho SEXP))

(r::defcfun "R_tryEval" SEXP (expr SEXP) (rho SEXP) (error :pointer))
(r::defcfun "R_tryEvalSilent" SEXP (expr SEXP) (rho SEXP) (error :pointer))
(r::defcfun "R_GetCurrentEnv" SEXP)
(cffi:defcvar ("R_curErrorBuf" :read-only t) :string)

#-ALTREP (r::defcfun "Rf_allocVector" SEXP (type :unsigned-int) (length :int32))
#+ALTREP (r::defcfun "Rf_allocVector" SEXP (type :unsigned-int) (length :int64))
(r::defcfun "Rf_mkChar" SEXP (string :string))
(r::defcfun "Rf_mkCharLen" SEXP (string :string) (len :int))
(r::defcfun "Rf_mkString" SEXP (string :string))

;; SEXP Rf_mkCharLen(const char *, int);
;; http://stat.ethz.ch/R-manual/R-devel/doc/manual/R-exts.html#Character-encoding-issues
;; SEXP Rf_mkCharCE(const char *, cetype_t);
;; SEXP Rf_mkCharLenCE(const char *, int, cetype_t);  //new in 2.8.0 

(r::defcfun "Rf_protect" SEXP (expr SEXP))
(r::defcfun "Rf_unprotect" :void (n :int))
(r::defcfun "Rf_unprotect_ptr" :void (expr SEXP))
;; INLINE_PROTECT
;; (r::defcfun "R_ProtectWithIndex" :void (expr SEXP, index :pointer))
;; (r::defcfun "R_Reprotect" :void (expr SEXP, index :int))

(r::defcfun "R_gc" :void)

;; R_ext/eventloop.h - used in process-events defined in events.lisp
#-windows (cffi:defcvar ("R_InputHandlers" :read-only t) SEXP)
#-windows (r::defcfun "R_checkActivity" :pointer (usec :int) (ignore-stdin :int))
#-windows (r::defcfun "R_runHandlers" :void (handler :pointer) (what :pointer))


(r::defcfun "Rf_conformable" :bool (sexp SEXP) (sexp2 SEXP))
(r::defcfun "Rf_elt" SEXP (sexp SEXP) (index :int))
(r::defcfun "Rf_inherits" :bool (sexp SEXP) (class :string))
(r::defcfun "Rf_isArray" :bool (sexp SEXP))
(r::defcfun "Rf_isFactor" :bool (sexp SEXP))
(r::defcfun "Rf_isFrame" :bool (sexp SEXP))
(r::defcfun "Rf_isFunction" :bool (sexp SEXP))
(r::defcfun "Rf_isInteger" :bool (sexp SEXP))
(r::defcfun "Rf_isLanguage" :bool (sexp SEXP))
(r::defcfun "Rf_isList" :bool (sexp SEXP))
(r::defcfun "Rf_isMatrix" :bool (sexp SEXP))
(r::defcfun "Rf_isNewList" :bool (sexp SEXP))
(r::defcfun "Rf_isNumber" :bool (sexp SEXP))
(r::defcfun "Rf_isNumeric" :bool (sexp SEXP))
(r::defcfun "Rf_isPairList" :bool (sexp SEXP))
(r::defcfun "Rf_isPrimitive" :bool (sexp SEXP))
(r::defcfun "Rf_isTs" :bool (sexp SEXP))
(r::defcfun "Rf_isUserBinop" :bool (sexp SEXP))
(r::defcfun "Rf_isValidString" :bool (sexp SEXP))
(r::defcfun "Rf_isValidStringF" :bool (sexp SEXP))
(r::defcfun "Rf_isVector" :bool (sexp SEXP))
(r::defcfun "Rf_isVectorAtomic" :bool (sexp SEXP))
(r::defcfun "Rf_isVectorList" :bool (sexp SEXP))
(r::defcfun "Rf_isVectorizable" :bool (sexp SEXP))
(r::defcfun "Rf_isNull" :bool (sexp SEXP))
(r::defcfun "Rf_isSymbol" :bool (sexp SEXP))
(r::defcfun "Rf_isLogical" :bool (sexp SEXP))
(r::defcfun "Rf_isReal" :bool (sexp SEXP))
(r::defcfun "Rf_isComplex" :bool (sexp SEXP))
(r::defcfun "Rf_isExpression" :bool (sexp SEXP))
(r::defcfun "Rf_isEnvironment" :bool (sexp SEXP))
(r::defcfun "Rf_isString" :bool (sexp SEXP))
(r::defcfun "Rf_isObject" :bool (sexp SEXP))
(r::defcfun "Rf_isOrdered" :bool (sexp SEXP))
(r::defcfun "Rf_isUnordered" :bool (sexp SEXP))
(r::defcfun "Rf_isUnsorted" :bool (sexp SEXP))

(r::defcfun "Rf_length" :int (sexp SEXP))
(r::defcfun "Rf_ncols" :int (sexp SEXP))
(r::defcfun "Rf_nrows" :int (sexp SEXP))

;; (r::defcfun "Rf_printwhere" :void)
(r::defcfun "Rf_PrintValue" :void (sexp SEXP))
;; (rf-printvalue (pointer (r%-parse-eval "1:4")))

(r::defcfun "R_ParseEvalString" SEXP (str :string) (env :pointer))
;; (rf-printvalue (r-parseevalstring "1+2" *r-globalenv*))

;; Rinternals.h 1074
;; Type coercions

(r::defcfun "Rf_asChar" SEXP (x SEXP))
(r::defcfun "Rf_coerceVector" SEXP (x SEXP) (type :unsigned-int))
(r::defcfun "Rf_PairToVectorList" SEXP (x SEXP))
(r::defcfun "Rf_VectorToPairList" SEXP (x SEXP))
(r::defcfun "Rf_asCharacterFactor" SEXP (x SEXP))
(r::defcfun "Rf_asLogical" :int (x SEXP))
(r::defcfun "Rf_asLogical2" :int (x SEXP) (checking :int) (call SEXP) (rho SEXP))
(r::defcfun "Rf_asInteger" :int (x SEXP))
(r::defcfun "Rf_asReal" :double (x SEXP))
;; (r::defcfun "Rf_asComplex" (:struct Rcomplex) (x SEXP)) ;; FIXME: cffi-libffi

(r::defcfun "Rf_PrintVersionString" :void (s :string) (len :int64))

