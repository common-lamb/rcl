;; Copyright (c) 2006-2012 Carlos Ungil

(in-package :rcl)

(defvar *r-streams* :print
  "What to do when calling with-r-stream: :console (don't capture), :print, or :string")

(defvar *r-output* t
  "Default stream where R output will be sent if captured")

(defvar *r-message* t
  "Default stream where R messages will be sent if captured")

(defvar *r-output-prefix* ";R# "
  "Default prefix used to print lines of R output")

(defvar *r-message-prefix* ";R! "
  "Default prefix used to print lines of R messages")

(defmacro with-r-output ((&optional stream prefix) &body body)
  "Capture R output and send it to stream (default *r-output*),
adding a prefix to each line (default *r-output-prefix*)"
  (let ((sink (gensym "SINK-OUT"))
	(result (gensym "RESULT")))
  `(let ((,sink (r-funcall "textConnection" "tmpout" "w"))
	 ,result)
     (r-funcall "sink" :file ,sink :type "output")
     (unwind-protect
	  (setf ,result (progn ,@body))
       (r-funcall "sink" :type "output")
       (r-funcall "close" ,sink)
       (format ,(or stream '*r-output*) 
	       (concatenate 'string "~{"  ,(or prefix '*r-output-prefix*) "~A~&~}")
	       (r-to-lisp (r-variable "tmpout"))))
     ,result)))
  
(defmacro with-r-message ((&optional (stream *r-message*) (prefix *r-message-prefix*)) &body body)
  "Capture R messages and send them to stream (default *r-message*),
adding a prefix to each line (default *r-message-prefix*)"  
  (let ((sink (gensym "SINK-ERR"))
	(result (gensym "RESULT")))
  `(let ((,sink (r-funcall "textConnection" "tmperr" "w"))
	 ,result)
     (r-funcall "sink" :file ,sink :type "message")
     (unwind-protect
	  (setf ,result (progn ,@body))
       (r-funcall "sink" :type "message")
       (r-funcall "close" ,sink)
       (format ,stream (concatenate 'string "~{"  ,prefix "~A~&~}")
	       (r-to-lisp (r-variable "tmperr"))))
     ,result)))

(defmacro with-r-streams (&body body)
  `(ecase *r-streams*
     (:console ,@body)
     (:print (with-r-output () (with-r-message () ,@body)))
     (:values (let ((output (make-string-output-stream))
		    (message (make-string-output-stream)))
		(values (with-r-message (message "") (with-r-output (output "") ,@body))
			(get-output-stream-string output)
			(get-output-stream-string message))))))

