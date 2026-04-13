;; Copyright (c) 2006-2017 Carlos Ungil

(in-package :cl-user)

(defpackage "RCL"
  (:nicknames "R") 
  (:use "CL")
  (:export "R-INIT" "R-QUIT" "ENSURE-R"
	   "R" "R%" "R-PRINT" "R-SUMMARY"
	   "*R-STREAMS*"
	   "R%-PARSE-EVAL" "R-PARSE-EVAL"
	   "*DEBUG-ATTRIBUTES*" "*DOWNCASE-ARGNAMES*"
	   "WITH-DEVICE" "WITH-PDF" "WITH-PAR" "X11" "*USE-QUARTZ*"
	   "ENABLE-RCL-SYNTAX"
	   "LISP-TO-R" "R-TO-LISP" "R-MATRIX"
	   "NEW-STRING" "NEW-STRING-SINGLE"))

(defpackage "RCL.FFI"
  (:use)
  (:nicknames "RF"))

