;;; Copyright (c) 2007-2015, Carlos Ungil
;;; Based on the file of the same name in RDNZL
;;; Copyright (c) 2004-2007, Dr. Edmund Weitz.  All rights reserved.

;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions
;;; are met:
;;;   * Redistributions of source code must retain the above copyright
;;;     notice, this list of conditions and the following disclaimer.
;;;   * Redistributions in binary form must reproduce the above
;;;     copyright notice, this list of conditions and the following
;;;     disclaimer in the documentation and/or other materials
;;;     provided with the distribution.
;;; THIS SOFTWARE IS PROVIDED BY THE AUTHOR 'AS IS' AND ANY EXPRESSED
;;; OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;;; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;;; ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
;;; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
;;; GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
;;; WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;;; NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;;; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

(in-package :rcl)

(defun r-reader (stream char1 char2)
  (declare (ignore char1 char2))
  `(,(if (member (peek-char nil stream) '(#\% #\_))
	 (progn (read-char stream) 'r%-parse-eval)
	 'r-parse-eval)
     ,(string-trim " "
		   (if (eq (peek-char nil stream) #\|)
		       (progn
			 (read-char stream)
			 (map 'string #'identity
			      (loop for previous = nil then current
				 for current = (read-char stream)
				 until (and (eq previous #\|) (eq current #\#))
				 when previous collect previous)))
		       (read-line stream nil nil)))))

(defun whitespacep (chr)
  "Tests whether a character is whitespace."
  (member chr '(#\Space #\Tab #\Linefeed #\Newline #\Return #\Page) :test #'char=))

(define-condition rcl-reader-error (simple-condition reader-error)
  ()
  (:report (lambda (condition stream)
             (format stream "RCL reader error: ~?"
                     (simple-condition-format-control condition)
                     (simple-condition-format-arguments condition))))
  (:documentation "A reader error which can be signalled by ERROR."))

(defmacro signal-reader-error (stream format-control &rest format-arguments)
  "Like ERROR but signals a SIMPLE-READER-ERROR for the stream
STREAM."
  `(error 'rcl-reader-error
          :stream ,stream
          :format-control ,format-control
          :format-arguments (list ,@format-arguments)))

(defun read-rcl-token (stream)
  "Tries to emulate how the Lisp reader reads a token with standard
syntax, but is case-sensitive.  Returns a string."
  (let ((collector (make-array 0
                               :element-type 'character
                               :fill-pointer t
                               :adjustable t))
        in-multiple-escape-p
        in-single-escape-p
        char-seen-p)
    (loop
      (let ((char (peek-char nil stream nil nil t)))
        (cond (in-multiple-escape-p
               ;; in multiple escape mode, read everything as is but
               ;; don't accept EOF
               (unless char
                 (signal-reader-error stream
                                      "End of file while in multiple~
escape mode \(i.e. after pipe character)."))
               (read-char stream nil nil t)
               (cond ((char= char #\|)
                      ;; end of multiple escape mode
                      (setq in-multiple-escape-p nil))
                     (t
                      (vector-push-extend char collector))))
              (in-single-escape-p
               ;; single escape mode, i.e. last char was backslash -
               ;; read next char as is but don't accept EOF
               (unless char
                 (signal-reader-error stream
                                      "End of file while in single~
escape mode \(i.e. after backslash character)."))
               (setq in-single-escape-p nil)
               (read-char stream nil nil t)
               (vector-push-extend char collector))
              ((null char)
               ;; EOF - return what has been read so far
               (return-from read-rcl-token collector))
              ((and (not char-seen-p)
                    (whitespacep char))
               ;; skip whitespace after #\[
               (read-char stream nil nil t))
              ((char= char #\|)
               ;; switch to multiple escape mode
               (setq in-multiple-escape-p t
                     char-seen-p t)
               (read-char stream nil nil t))
              ((char= char #\\)
               ;; switch to single escape mode
               (setq in-single-escape-p t
                     char-seen-p t)
               (read-char stream nil nil t))
              ((or (whitespacep char)
                   (member char '(#\" #\' #\( #\) #\[ #\] #\, #\; #\`)
                           :test #'char=))
               ;; whitespace or terminating macro character, stop
               ;; parsing this token
               (return-from read-rcl-token collector))
              (t
               ;; otherwise just consume the character
               (setq char-seen-p t)
               (read-char stream nil nil t)
               (vector-push-extend char collector)))))))

(defvar *return-pointer* nil)

(defun read-and-parse-rcl-token (stream)
  "Reads a token like \"_print \" with READ-RCL-TOKEN and returns the
R funcion to call, and the lisp funcion used to do so (r o r%).
A pointer is returned if there is a leading underscore or percent sign."
  (let ((token (read-rcl-token stream))
        (function-name (if *return-pointer* 'r% 'r)))
    (when (string= token "")
      (signal-reader-error stream
			   "Empty token after #\[ character."))
    (when (and (= (length token) 1)
	       (member (char token 0) '(#\% #\_)))
      (signal-reader-error stream
			       "Illegal token \"~C\" after #\[ character."
			       token))
    (when (member (char token 0) '(#\% #\_))
      (setq function-name 'r%
	    token (subseq token 1)))
    (values token function-name)))

(defun rcl-list-reader (stream char)
  (declare (ignore char))
  "The reader function for the RCL \[] notation."
  ;; read the first token after the opening bracket with
  ;; READ-RCL-TOKEN, then use READ-RCL-TOKEN to read keywords and
  ;; quoted symbols only
  (multiple-value-bind (r-function interface-function)
      (read-and-parse-rcl-token stream)
    (let ((*return-pointer* t))
      (list* interface-function r-function
	     (loop for char = (peek-char t stream nil nil)
		until (when (char= char #\]) (read-char stream))
		collect (case char
			  (#\: (intern (progn (read-char stream)
					      (read-rcl-token stream)) 
				       "KEYWORD"))
			  (#\' (list 'quote 
				     (if (char= (progn (read-char stream)
						       (peek-char nil stream)) #\()
					 (read stream)
					 (intern (read-rcl-token stream)))))
			  (t (read stream))))))))
  
(named-readtables:defreadtable rcl
  (:merge :standard)
  (:dispatch-macro-char #\# #\? #'r-reader)
  ;; make #\[ non-terminating
  (:macro-char #\[ #'rcl-list-reader)
  (:syntax-from :standard #\) #\]))

;; #? ...
;; #?% ...
;; #?| ... |#  
;; #?%| ... |#
