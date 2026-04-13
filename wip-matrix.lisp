R> (r "print" (r% "solve" (r% "matrix" '(3 4 1 5 1 5 2 3 5) :nrow 3)))
;R#            [,1]       [,2]        [,3]
;R# [1,]  0.1298701  0.1948052 -0.16883117
;R# [2,]  0.2207792 -0.1688312  0.01298701
;R# [3,] -0.2467532  0.1298701  0.22077922
;R. Attributes for REAL-VECTOR:
;R. (:DIM 3 3)
#<R-MATRIX #2A((0.12987012987012989d0 0.19480519480519481d0
                -0.16883116883116883d0)
               (0.22077922077922082d0 -0.16883116883116883d0
                0.012987012987012986d0)
               (-0.24675324675324678d0 0.12987012987012989d0
                0.22077922077922077d0)) NIL {100A515883}>


R> (r "library" "Matrix")
("Matrix" "zoo" "stats" "graphics" "grDevices" "utils" "datasets" "methods"
 "base")


R> (r "solve" (r% "Matrix" '(3 4 1 5 1 5 2 3 5) :nrow 3))
;R. Attributes for STRING-VECTOR:
;R. (:PACKAGE "Matrix")
;R. Attributes for SCALAR-STRING-TYPE:
;R. ("push.viewport")
;R. Attributes for SCALAR-STRING-TYPE:
;R. ("caption")
;R. Attributes for SCALAR-STRING-TYPE:
;R. ("push.viewport")
;R. Attributes for SCALAR-STRING-TYPE:
;R. ("caption")
;R. Attributes for NIL:
;R. (:X 0.1298701298701299d0 0.22077922077922077d0 -0.24675324675324678d0 0.19480519480519476d0 -0.16883116883116883d0 0.1298701298701299d0 -0.16883116883116886d0 0.012987012987013019d0 0.22077922077922077d0)
;R. (:DIM 3 3)
;R. (:DIMNAMES NIL NIL)
;R. (:FACTORS)
;R. (:CLASS "dgeMatrix")
(:UNKNOWN NIL)


R> (reduce #'+
	(r "as.vector" 
	   (r% "-" (r% "solve" (r% "matrix" '(3 4 1 5 1 5 2 3 5) :nrow 3))
	       (r% "as.matrix" (r% "solve" (r% "Matrix" '(3 4 1 5 1 5 2 3 5) :nrow 3))))))
5.0306980803327406d-17


R> (enable-rcl-syntax)
R> (reduce #'+
       [as.vector
           [_- [_solve [_matrix '(3 4 1 5 1 5 2 3 5) :nrow 3]]
	       [_as.matrix [_solve [_Matrix '(3 4 1 5 1 5 2 3 5) :nrow 3]]]]])
5.0306980803327406d-17

