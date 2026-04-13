(in-package :rcl)

(named-readtables:in-readtable rcl)

[\[ 'letters [: 4 6]]
;; (RCL:R "[" '|letters| (RCL:R% ":" 4 6))
;; => ("d" "e" "f")

(let ((matrix [_matrix [: 1 100] 10]))
  (print [dim matrix])
  (print [\[ matrix 2 2]))
;;; how can we get a column or row?

(let ((empl [_list :employee "Anna" :spouse "Fred" :children 3 :child.ages '(4 7 9)]))
  (list [$ empl "employee"] [$ empl "child.ages"]))

[library 'MASS]
[row.names 'painters]
[colnames 'painters]
[\[ 'painters [: 1 5] '(2 4)]

[methods "plot"]
    
[showMethods "plot"]
