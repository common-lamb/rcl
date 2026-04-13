(in-package :rcl.ffi)

;; include/R.h

;; void R_FlushConsole(void);
;; /* always declared, but only usable under Win32 and Aqua */
;; void R_ProcessEvents(void);
;; #ifdef Win32
;; void R_WaitEvent(void);
;; #endif

(r::defcfun "R_FlushConsole" :void)
(r::defcfun "R_ProcessEvents" :void) 
#+windows (r::defcfun "R_WaitEvent" :void)
