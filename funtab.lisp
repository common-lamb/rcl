(in-package :rcl)

(cffi:defcenum PPkind
  :INVALID :ASSIGN :ASSIGN2 :BINARY :BINARY2 :BREAK :CURLY
  :FOR :FUNCALL :FUNCTION :IF :NEXT :PAREN :RETURN :SUBASS
  :SUBSET :WHILE :UNARY :DOLLAR :FOREIGN :REPEAT)

(cffi:defcenum PPprec
  :FN :EQ :LEFT :RIGHT :TILDE :OR :AND :NOT :COMPARE :SUM
  :PROD :PERCENT :COLON :SIGN :POWER :SUBSET :DOLLAR :NS)

(cffi:defcstruct PPinfo
  (kind PPkind)
  (precedence PPprec)
  (rightassoc :unsigned-int))
	
(cffi:defcstruct FUNTAB
  (name :string)
  (cfun :pointer)
  (code :int)
  (eval :int)
  (arity :int)
  (gram (:struct PPinfo)))

(cffi:defcvar ("R_FunTab" :read-only t) FUNTAB) ;; how can we reference an array otherwise?

(defun get-builtin-name (offset)
  (getf (cffi:mem-aref *R-FUNTAB* '(:struct FUNTAB) offset) 'name))

;; (cffi:mem-aref *R-FUNTAB* '(:struct FUNTAB) 0)

;; (cffi:mem-aref *R-FUNTAB* '(:struct FUNTAB) 99)

;; CCODE cfun
;; /* The type of the do_xxxx functions. */
;; /* These are the built-in R functions. */
;; typedef SEXP (*CCODE)(SEXP, SEXP, SEXP, SEXP);
