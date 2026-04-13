;; Copyright (c) 2006-2020 Carlos Ungil

(in-package :rcl)

;; include/Rinternals.h

(defvar NILSXP	0	  "nil = NULL")
(defvar SYMSXP	1	  "symbols")
(defvar LISTSXP 2	  "lists of dotted pairs")
(defvar CLOSXP 3	  "closures")
(defvar ENVSXP 4	  "environments")
(defvar PROMSXP 5	  "promises: [un]evaluated closure arguments")
(defvar LANGSXP 6	  "language constructs (special lists)")
(defvar SPECIALSXP 7	  "special forms")
(defvar BUILTINSXP 8	  "builtin non-special forms")
(defvar CHARSXP 9	  "\"scalar\" string type (internal only)")
(defvar LGLSXP 10	  "logical vectors")
;; /* 11 and 12 were factors and ordered factors in the 1990s */
(defvar INTSXP 13	  "integer vectors")
(defvar REALSXP 14	  "real variables")
(defvar CPLXSXP 15	  "complex variables")
(defvar STRSXP 16	  "string vectors")
(defvar DOTSXP 17	  "dot-dot-dot object")
(defvar ANYSXP 18	  "make \"any\" args work. Used in specifying types for symbol registration to mean anything is okay")
(defvar VECSXP 19	  "generic vectors")
(defvar EXPRSXP 20	  "expressions vectors")
(defvar BCODESXP 21       "byte code")
(defvar EXTPTRSXP 22      "external pointer")
(defvar WEAKREFSXP 23     "weak reference")
(defvar RAWSXP 24         "raw bytes")
(defvar S4SXP 25          "S4 classes not of simple type")

;; /* used for detecting PROTECT issues in memory.c */
(defvar NEWSXP 30         "fresh node created in new page")
(defvar FREESXP 31        "node released by GC")

(defvar FUNSXP 99         "Closure or Builtin")

(defvar *r-vector-types* '(:real-vector :integer-vector :complex-vector :string-vector
			   :logical-vector :generic-vector :expressions-vector
			   :scalar-string-type :weak-reference :raw-bytes))

(defvar *r-types* `((,NILSXP . :null)
		    (,SYMSXP . :symbol)
		    (,LISTSXP . :list-of-dotted-pairs)
		    (,CLOSXP . :closure)
		    (,ENVSXP . :environments)
		    (,PROMSXP . :promise)
		    (,LANGSXP . :language-construct)
		    (,SPECIALSXP . :special-form)
		    (,BUILTINSXP . :builtin-non-special-forms)
		    (,CHARSXP . :scalar-string-type)
		    (,LGLSXP . :logical-vector)
		    (,INTSXP . :integer-vector)
		    (,REALSXP . :real-vector)
		    (,CPLXSXP . :complex-vector)
		    (,STRSXP . :string-vector)
		    (,DOTSXP . :dot-dot-dot)
		    (,ANYSXP . :any)
		    (,VECSXP . :generic-vector)
		    (,EXPRSXP . :expressions-vector)
		    (,BCODESXP . :byte-code)
		    (,EXTPTRSXP . :external-pointer)
		    (,WEAKREFSXP . :weak-reference)
		    (,RAWSXP . :raw-bytes)
		    (,S4SXP . :s4-class-not-simple)
		    (,NEWSXP . :fresh-node-created-in-new-page)
		    (,FREESXP . :node-released-by-GC)
		    (,FUNSXP . :closure-or-builtin)))
