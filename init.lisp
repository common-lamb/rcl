;; Copyright (c) 2006-2015 Carlos Ungil

(in-package :rcl)

(eval-when (:compile-toplevel :load-toplevel :execute)
  
  (defun getenv (var)
    #+sbcl (sb-posix:getenv var)                    
    #+abcl (ext:getenv var)
    #+ecl (ext:getenv var)
    #+openmcl (ccl::getenv var)                   
    #+allegro (sys:getenv var)
    #+clisp (ext:getenv var)
    #+lispworks (lispworks:environment-variable var)
    #+cmu (cffi:foreign-funcall "getenv" :string var :string))
  
  (defun setenv (var val)
    #+sbcl (sb-posix:putenv (concatenate 'string var "=" val))
    #+abcl (cerror "continue, but this might be a problem later" "cannot set ~A = ~A" var val)
    #+ecl (ext:setenv var val)
    #+openmcl (ccl:setenv var val)
    #+allegro (setf (sys:getenv var) val)
    #+clisp (setf (ext:getenv var) val)
    #+lispworks (setf (lispworks:environment-variable var) val)
    #+cmu (cffi:foreign-funcall "setenv" :string var :string val :boolean t :int)))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (let ((variable-name #+windows "PATH" #-windows "LD_LIBRARY_PATH")
        (separator #+windows ";" #-windows ":"))
    (let ((current (getenv variable-name)))
      (unless (search (subseq *r-lib-path* 0 (1- (length *r-lib-path*))) current)
	;; search without trailing slash (not a reliable search, anyway)
        (let ((new (concatenate 'string current
                                (when current separator) *r-lib-path*)))
	  (setenv variable-name new))))))

(defun set-r-home (r-home)
  #+sbcl (sb-posix:putenv (concatenate 'string "R_HOME=" r-home))
  #+abcl (unless (ext:getenv "R_HOME") (warn "R_HOME is not set"))
  #+ecl (ext:setenv "R_HOME" r-home)
  #+openmcl (ccl::setenv "R_HOME" r-home)
  #+allegro (setf (sys:getenv "R_HOME") r-home)
  #+clisp (setf (ext:getenv "R_HOME") r-home)
  #+lispworks (setf (lispworks:environment-variable "R_HOME") r-home)
  #+cmu (cffi:foreign-funcall "setenv" :string "R_HOME" :string r-home :boolean t :int))

#+(and ecl (not dffi))
(defvar *r-lib-loaded* (ffi:load-foreign-library "/Library/Frameworks/R.framework/Resources/lib/libR.dylib"))

#-(and ecl (not dffi))
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defvar *r-lib-loaded* nil)
  (unless *r-lib-loaded*
    (pushnew *r-lib-path* cffi:*foreign-library-directories*)
    (setf *r-lib-loaded* (cffi:load-foreign-library *r-lib*))))

(defvar *r-session* :inactive)

(cffi:defcvar "R_SignalHandlers" 
    #-cffi-features:x86-64 :unsigned-long 
    #+cffi-features:x86-64 :unsigned-long-long)
(cffi:defcvar "R_CStackLimit"
    #-cffi-features:x86-64 :unsigned-long 
    #+cffi-features:x86-64 :unsigned-long-long)
(cffi:defcvar "R_Interactive"
    #-cffi-features:x86-64 :unsigned-long 
    #+cffi-features:x86-64 :unsigned-long-long)

(defun disable-stack-checking ()
  (setf *r-cstacklimit* 
	#-cffi-features:x86-64 (1- (expt 2 32))
	#+cffi-features:x86-64 (1- (expt 2 64))))

(defun disable-signal-handling ()
  (setf *r-signalhandlers* 0))

(defun ensure-non-interactive ()
  ;; defaults to interactive depending on isatty()
  (setf *r-interactive* 0))

(defun version ()
  (cffi:with-foreign-object (version :unsigned-char 100)
    (rf::rf-printversionstring version 100)
    (cffi::foreign-string-to-lisp version)))

(defun r-init ()
  (ecase *r-session*
    (:running (warn "R already running"))
    (:stopped (error "R was already stopped, restarting is not supported"))
    (:inactive
     ;;(start-r-runner)
     (start-unprotect-runner)
     (set-r-home *r-home*)
     (disable-signal-handling)
     (cffi:with-foreign-object (argv :pointer 5)
       (setf (cffi:mem-aref argv :pointer 0)
	     (cffi:foreign-string-alloc "rcl")
	     ;; slave: make R run as quietly as possible (>quiet/silent?)
	     (cffi:mem-aref argv :pointer 1) 
	     (cffi:foreign-string-alloc "--slave") 
	     ;; vanilla: no-save, no-restore, no-environ, no-site-file, no-init-file
	     (cffi:mem-aref argv :pointer 2) 
	     (cffi:foreign-string-alloc "--vanilla")
	     (cffi:mem-aref argv :pointer 3)
	     (cffi:foreign-string-alloc "--no-readline")
	     (cffi:mem-aref argv :pointer 4) 
	     (cffi:foreign-string-alloc "--max-ppsize=50000"))
       (rf::rf-initialize-r 5 argv))
     ;; the first version called rf-initembeddedr, resulting in
     ;; "C stack usage too close to the limit" messages in
     ;; ClozureCL, CMUCL, SBCL, and Lispworks on Linux/MacOSX
     ;; and nothing worked afterwards (... not a valid function, 
     ;; and *globalenv* had named=0 and mark=0 instead of 2 and 1)
     ;; As it's done in RCLG we need to disable stack-checking
     ;; inside that function, which is defined in Rembedded.c as
     ;; Rf_initialize_R, R_Interactive=TRUE (Unix), setup_Rmainloop
     (disable-stack-checking)
     (ensure-non-interactive)
     (rf::setup-rmainloop)
     ;;(run-rmainloop)
     ;;(r-repldllinit)
     (setf *r-session* :running)))
  *r-session*)

(defun ensure-r (&rest libraries)
  "Starts an R session if required and loads all the specified packages."
  (unless (eq rcl::*r-session* :running) (r-init))
  (loop for lib in libraries do (r "library" lib)))


;; stopping and restarting the embedded instance is not supported in R

(defun r-quit ()
  (if (eq *r-session* :running)
      (progn
	(rf::rf-endembeddedr 1)
	(setf *r-session* :stopped))
      (warn "R was not running!"))
  *r-session*)

;;https://stat.ethz.ch/pipermail/r-help/2010-September/252039.html
;; void Rf_endEmbeddedR(int fatal)
;; {
;;     R_RunExitFinalizers();
;;     CleanEd();
;;     if(!fatal) KillAllDevices();
;;     R_CleanTempDir();
;;     if(!fatal && R_CollectWarnings)
;; 	PrintWarnings();	/* from device close and .Last */
;;     fpu_setup(FALSE);
;; }

#+lispworks ;;; "When quitting image" is too late
(lispworks:define-action "Confirm when quitting image"
    "Stop R process"
  #'r-quit)

;; seems to run in CCL but it doesn't stop R and it may hang...
;; maybe because we are using trivial-main-thread ?
#+ccl (pushnew #'r-quit ccl:*lisp-cleanup-functions*)

#+cmucl (pushnew #'r-quit lisp::*cleanup-functions*)

#+sbcl (pushnew #'r-quit sb-ext:*exit-hooks*)

#+ecl (pushnew #'r-quit si:*exit-hooks*)

#+clisp (pushnew #'r-quit custom:*fini-hooks*)

#+allegro (pushnew '(r:r-quit) sys:*exit-cleanup-forms*)

