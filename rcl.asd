;; Copyright (c) 2006-2020 Carlos Ungil

(eval-when (:load-toplevel :compile-toplevel :execute)
  (pushnew :rcl *features*))

(in-package #:asdf)

(defsystem #:rcl
    :name "RCL"
    :author "Carlos Ungil <ungil@mac.com>"
    :license "MIT"
    :description "http://common-lisp.net/project/rcl"
    :in-order-to ((test-op (load-op "rcl/test") (test-op "rcl/test")))
    ;; :in-order-to ((test-op (load-op "rcl/prove") (test-op "rcl/prove")))
    :depends-on (:cffi :trivial-garbage :bordeaux-threads :simple-tasks
		       #+sbcl :sb-posix #-cmucl :named-readtables)
    :components ((:file "defpackage")
                 (:file "config" :depends-on ("defpackage"))
                 (:file "init" :depends-on ("config"))
                 (:file "math" :depends-on ("init"))
                 (:file "funtab" :depends-on ("init"))
                 (:file "alien-helper")
                 (:file "alien-defs" :depends-on ("init" "alien-helper"))
 		 (:file "alien-R" :depends-on ("alien-defs"))
		 (:file "alien-Rembedded" :depends-on ("alien-defs"))
		 (:file "alien-altrep" :depends-on ("alien-defs"))
		 (:file "events" :depends-on ("alien-defs"))
		 (:file "types" :depends-on ("alien-defs"))	
                 (:file "alien-macros" :depends-on ("types"))	
                 (:file "vectors" :depends-on ("alien-macros"))
                 (:file "symbol" :depends-on ("alien-macros"))
                 (:file "promise" :depends-on ("alien-macros"))
                 (:file "language" :depends-on ("alien-macros"))
                 (:file "environment" :depends-on ("alien-macros"))
                 (:file "matrix" :depends-on ("defpackage"))
		 (:file "debug" :depends-on ("alien-macros"))
                 (:file "attributes" :depends-on ("symbol"))
		 (:file "dataframe" :depends-on ("defpackage"))
		 (:file "r-pointer" :depends-on ("defpackage"))
                 (:file "decode" :depends-on ("vectors" "attributes" "types" "r-pointer" "dataframe"))
                 (:file "encode" :depends-on ("vectors" "r-pointer"))
		 (:file "funcall" :depends-on ("encode" "decode"))
                 (:file "streams" :depends-on ("funcall"))	
                 #-cmucl (:file "reader" :depends-on ("funcall"))
                 (:file "high-level" :depends-on ("streams"))
                 (:file "devices" :depends-on ("high-level"))))

(defsystem #:rcl/test
    :name "RCL test suite"
    :author "Carlos Ungil <ungil@mac.com>"
    :license "MIT"
    :description "http://common-lisp.net/project/rcl"
    :depends-on (:fiveam :rcl)
    ;;:defsystem-depends-on (:fiveam-asdf)  
    :components ((:file "test"))
    :perform (test-op (o s) (uiop:symbol-call :rcl.test '#:run-tests)))

(defsystem  #:rcl/prove
    :name "RCL test suite"
    :author "Carlos Ungil <ungil@mac.com>"
    :license "MIT"
    :depends-on (:prove :rcl)
    :defsystem-depends-on (:prove-asdf)
    :components ((:test-file "prove"))
    :perform  (test-op (o s) :after (uiop:symbol-call :prove '#:run s)))
