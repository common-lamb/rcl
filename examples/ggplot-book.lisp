(in-package :rcl)

(named-readtables:in-readtable rcl)

[library 'ggplot2]

[_print [qplot 'carat 'price :data 'diamonds]]
;; (RCL:R% "print" (RCL:R% "qplot" '|carat| '|price| :|data| '|diamonds|))

[_print #?|qplot(log(carat),log(price),data=diamonds)|#]
;; (RCL:R% "print" (RCL:R-PARSE-EVAL "qplot(log(carat),log(price),data=diamonds)"))

(progn 
  [attach 'diamonds]
  [_print [_qplot [_log 'carat] [_log 'price]]]
  [detach 'diamonds])

;; this is not very nice, the name of the axes is not 
;; "log(carat)" and "log(price)"

(progn 
  [attach 'diamonds]
  [_print [qplot 'carat [* [* 'x 'y] 'z]]]
  [detach 'diamonds])

;; (let ((dsmall [_\[ 'diamonds [_sample [_nrow 'diamonds] 1000]]))
;;   [print [_qplot 'carat 'price :data dsmall :colour 'color]])

[_print [qplot 'carat 'price :geom '("smooth" "point") :data 'diamonds]]
;; (RCL:R% "print" (RCL:R% "qplot" '|carat| '|price| :|geom| '("smooth" "point") :|data| '|diamonds|))

[_print [qplot [$ 'economics "date"] [/ [$ 'economics "unemploy"] [$ 'economics "pop"]] :geom "line"]]
;; (RCL:R% "print" (RCL:R% "qplot" (RCL:R% "$" '|economics| "date")
;;                                 (RCL:R% "/" (RCL:R% "$" '|economics| "unemploy")
;;                                             (RCL:R% "$" '|economics| "pop")) :|geom| "line"))





