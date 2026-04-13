;; Copyright (c) 2006-2007 Carlos Ungil

(in-package :rcl)

(defun device-details (type)
  "Returns for known types :ps, :pdf, :png, :jp[e]g, :xfig, :pictex 
a pair function,extension"
  (values-list (ecase type
		 (:ps '("postscript" "ps"))
		 (:pdf '("pdf" "pdf"))
		 (:png '("png" "png"))
		 ((or :jpeg :jpg) '("jpeg" "jpg"))
		 (:xfig '("xfig" "fig"))
		 (:pictex '("pictex" "tex")))))

(defmacro with-device ((filename type &rest options) &body body)
  "Executes the body after opening a graphical device that is closed at the end; 
options are passed to R (known types: :ps, :pdf, :png, :jp[e]g, :xfig, :pictex)"
  `(multiple-value-bind (device-name device-extension) (device-details ,type)
    (r% device-name (concatenate 'string ,filename "." device-extension) ,@options)
    (let ((device (r% "dev.cur")))
      (unwind-protect
	   (progn ,@body)
	(r% "dev.off" device)))))

(defmacro with-pdf ((filename paper) &body body)
  `(with-device (,filename :pdf :width 0 :height 0 :paper ,paper)
     ,@body))

(defmacro with-par ((&rest args) &body body)
  "Sets graphical parameters, giving a list of the form :key1 val1 :key2 val2
The number of rows and columns can be pased directly as the first and second arguments, 
but if those are the only args they will be ignored if already set (i.e. mfrow is not (1 1))."
  `(progn
     (when (eq :|null device| (caar (r "dev.cur"))) (x11))
     (let ((donothing (and (= 2 ,(length args))
			   (numberp ,(first args))
			   (not (equal '(1 1) (r "par" "mfrow")))))
	   (oldpar (r% "par" :no.readonly t)))
       (unless donothing
	 (if (numberp ,(first args))
	     (r% "par" :mfrow (list ,(first args) ,(second args)) ,@(rest (rest args)))
	     (r% "par" ,@args)))
       (unwind-protect
	    (progn ,@body)
	 (unless donothing (r% "par" oldpar))))))
