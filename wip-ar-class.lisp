R> (r "attributes" (r% "ar" (r-variable  "lh")))
;R. Attributes for GENERIC-VECTOR:
;R. (:NAMES "names" "class")
;R. Attributes for SCALAR-STRING-TYPE:
;R. ("nsim")
((:|class| "ar")
 (:|names| "order" "ar" "var.pred" "x.mean" "aic" "n.used" "order.max"
  "partialacf" "resid" "method" "series" "frequency" "call" "asy.var.coef"))


R> (r% "print" (r% "ar" (r-variable  "lh")))
;R# 
;R# Call:
;R# (function (x, aic = TRUE, order.max = NULL, method = c("yule-walker",     "burg", "ols", "mle", "yw"), na.action = na.fail, series = deparse(substitute(x)),     ...) {    res <- switch(match.arg(method), yw = , `yule-walker` = ar.yw(x,         aic = aic, order.max = order.max, na.action = na.action,         series = series, ...), burg = ar.burg(x, aic = aic, order.max = order.max,         na.action = na.action, series = series, ...), ols = ar.ols(x,         aic = aic, order.max = order.max, na.action = na.action,         series = series, ...), mle = ar.mle(x, aic = aic, order.max = order.max,         na.action = na.action, series = series, ...))    res$call <- match.call()    res})(x = structure(c(2.4, 2.4, 2.4, 2.2, 2.1, 1.5, 2.3, 2.3, 2.5, 2, 1.9, 1.7, 2.2, 1.8, 3.2, 3.2, 2.7, 2.2, 2.2, 1.9, 1.9, 1.8, 2.7, 3, 2.3, 2, 2, 2.9, 2.9, 2.7, 2.7, 2.3, 2.6, 2.4, 1.8, 1.7, 1.5, 1.4, 2.1, 3.3, 3.5, 3.5, 3.1, 2.6, 2.1, 3.4, 3, 2.9), .Tsp = c(1, 48, 1), class = "ts"))
;R# 
;R# Coefficients:
;R#       1        2        3  
;R#  0.6534  -0.0636  -0.2269  
;R# 
;R# Order selected 3  sigma^2 estimated as  0.1959
#<R-POINTER :GENERIC-VECTOR #.(SB-SYS:INT-SAP #X634FC158) {1009C50B33}>


R> (r "names" (r% "ar" (r-variable  "lh")))
;R. Attributes for SCALAR-STRING-TYPE:
;R. ("nsim")
("order" "ar" "var.pred" "x.mean" "aic" "n.used" "order.max" "partialacf"
 "resid" "method" "series" "frequency" "call" "asy.var.coef")


R> (r "class" (r% "ar" (r-variable  "lh")))
("ar")


R> (r "\$" (r% "ar" (r-variable  "lh")) "asy.var.coef")
;R. Attributes for REAL-VECTOR:
;R. (:DIM 3 3)
#<R-MATRIX #2A((0.021556776019885177d0 -0.01517817736505647d0
                0.004815998745644286d0)
               (-0.015178177365056472d0 0.03116782472289846d0
                -0.01517817736505647d0)
               (0.004815998745644287d0 -0.015178177365056472d0
                0.02155677601988518d0)) NIL {100A2BFDC3}>


R> (r "\$" (r% "ar" (r-variable  "lh")) "partialacf")
;R. Attributes for REAL-VECTOR:
;R. (:DIM 16 1 1)
#<R-MATRIX #3A(((0.5755244755244756d0))
               ((-0.22340997286429742d0))
               ((-0.22694020165024148d0))
               ((0.10276837700622231d0))
               ((-0.07593441965331013d0))
               ((0.06755793452596624d0))
               ((-0.10417025122780985d0))
               ((0.012013676148550544d0))
               ((-0.18768722846113864d0))
               ((0.0025510411197388885d0))
               ((0.06560201323373414d0))
               ((0.03196795336021604d0))
               ((0.021882098359407208d0))
               ((-0.09312452837866995d0))
               ((0.2297876294427684d0))
               ((0.04443989018953477d0))) NIL {100A380CC3}>

