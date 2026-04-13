(in-package :rcl)

(r-parse-eval "lm(Fertility ~ . , data = swiss)")

(r "lm" (r%-parse-eval "Fertility ~ .") :data (r-symbol "swiss"))

;; * FORMULA HANDLING *

(r-to-lisp (r%-parse-eval "Fertility ~ ."))
;; (LANGUAGE-CONSTRUCT #<R-SYMBOL "~" {1005FFE563}>
;;  (#<R-SYMBOL "Fertility" {1006005E03}> (#<R-SYMBOL "." {100600D663}> NIL NIL)
;;   NIL)
;;  NIL)

(r-to-lisp (r%-parse-eval "response ~ this + that"))

;;;; (~ response (+ this that))

[_print [lm (r%-parse-eval "Fertility ~ .") :data 'swiss]]
[_print [lm [as.formula "Fertility ~ ."] :data 'swiss]]
[_print [lm [~ 'Fertility '.] :data 'swiss]] ;; not working
