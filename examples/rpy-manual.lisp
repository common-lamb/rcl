;;; 2.2 Invocation

;; >>> from rpy import *

(ql:quickload :rcl)

(in-package :rcl)

(named-readtables:in-readtable rcl)

(r-init)

;; >>> r.wilcox_test
;; <Robj object at 0x8a9e120>

(r-function "wilcox.test")
;; #<R-POINTER :CLOSURE #.(SB-SYS:INT-SAP #X012B2CB0) {100F819AE3}> 


;; >>> r.wilcox_test([1,2,3], [4,5,6])
;; {'p.value': 0.10000000000000001, 'statistic': {'W': 0.0},
;; 'null.value': {'mu': 0.0}, 'data.name': 'c(1, 2, 3) and c(4, 5, 6)',
;; 'alternative': 'two.sided', 'parameter': None, 'method':
;; 'Wilcoxon rank sum test'}

[wilcox.test '(1 2 3) '(4 5 6)]
;; = (R "wilcox.test" '(1 2 3) '(4 5 6))
;; ((:|data.name| "1:3 and 4:6") (:|method| "Wilcoxon rank sum test")
;;  (:|alternative| "two.sided") (:|null.value| (:|location shift| . 0.0d0))
;;  (:|p.value| 0.1d0) (:|parameter|) (:|statistic| (:W . 0.0d0)))

[print [wilcox.test '(1 2 3) '(4 5 6)]]
;; = (R "print" (R% "wilcox.test" '(1 2 3) '(4 5 6)))
;;; will also print the following
;R# 
;R# 	Wilcoxon rank sum test
;R# 
;R# data:  1:3 and 4:6
;R# W = 0, p-value = 0.1
;R# alternative hypothesis: true location shift is not equal to 0
;R# 


;; >>> r.seq(1, 3, by=0.5)
;; [1.0, 1.5, 2.0, 2.5, 3]

[seq 1 3 :by 0.5]
;; = (r "seq" 1 3 :by 0.5)  
;; also (r "seq" 1 3 '(:by 0.5))
;;> (1.0d0 1.5d0 2.0d0 2.5d0 3.0d0)


;; >>> r.plot()
;; Traceback (most recent call last):
;; File "<stdin>", line 1, in ?
;; rpy.RException: Error in function (x, ...)  : Argument "x" is missing,
;; with no default

(r "plot")
;R! Error in xy.coords(x, y, xlabel, ylabel, log) : 
;R!   argument "x" is missing, with no default
;R! Calls: <Anonymous> -> plot.default -> xy.coords


;;; 2.3 Small example

; >>> from rpy import *
; >>>
; >>> degrees = 4
; >>> grid = r.seq(0, 10, length=100)
; >>> values = [r.dchisq(x, degrees) for x in grid]
; >>> r.par(ann=0)
; >>> r.plot(grid, values, type='lines')

(let* ((degrees 4)
       (grid (r "seq" 0 10 :length 100))
       (values (loop for x in grid collect (r% "dchisq" x degrees))))
  (x11)
  (r "par" :ann 0)
  (r "plot" grid values :type "lines"))

(let* ((degrees 4)
       (grid [_seq 0 10 :length 100])
       (values [_dchisq grid degrees]))
  [x11]
  [par :ann 0]
  [plot grid values :type "lines"])
