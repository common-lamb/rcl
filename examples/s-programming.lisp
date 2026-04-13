R> (ql:quickload :rcl)

R> (in-package :rcl)

R> (r-init)

R> (enable-rcl-syntax)

;; 2.1

;; page 8

R> [attributes 'mdeaths]
((:|class| "ts") (:|tsp| 1974.0d0 1979.91666666667d0 12.0d0))

R> [print [_attributes 'mdeaths]]
;R# $tsp
;R# [1] 1974.000 1979.917   12.000
;R# 
;R# $class
;R# [1] "ts"
;R# 
((:|class| "ts") (:|tsp| 1974.0d0 1979.91666666667d0 12.0d0))

;; page 9

R> [> '(2.9 3.4 3.4 3.7 3.7 2.8 2.5 2.4 2.4) 3]
(NIL T T T T NIL NIL NIL NIL)

R> [%% 32 3]
2

R> [search]
(".GlobalEnv" "package:stats" "package:graphics" "package:grDevices"
 "package:utils" "package:datasets" "package:methods" "Autoloads"
 "package:base")

R> [rpois 3 2]
(2 2 3)
