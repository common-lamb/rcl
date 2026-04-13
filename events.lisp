;; Copyright (c) 2006-2015 Carlos Ungil

(in-package :rcl)

(defvar *use-quartz* #+(or (and cocoa lispworks)) t
	#+ccl (boundp 'ccl::*cocoa-event-process*)
	#-(or ccl (and cocoa lispworks)) nil
  "On MacOSX open Quartz windows by default when possible, instead of using X11")

;; May be required in MacOSX if there are issues with fonts in X11
;;  export LC_CTYPE=en_US.UTF-8
;;  export LC_ALL=en_US.UTF-8

(defun process-events ()
  #-windows (rf::r-runhandlers rf::*r-inputhandlers* (rf::r-checkactivity 0 1))
  (rf::r-processevents))

(defvar *event-loop* nil)

(defun event-loop ()
  (bt:make-thread
   (lambda ()
     (loop while (eq (values) (process-events)) do (sleep 0.1)))
   :name "event loop"))

(defun x11 (&optional (quartz #+(or :macosx :darwin) *use-quartz*))
  (ensure-r)
  (r (if quartz "quartz" "x11"))
  #+bordeaux-threads
  (unless (and *event-loop* (bt:thread-alive-p *event-loop*))
    (setf *event-loop* (event-loop))))

