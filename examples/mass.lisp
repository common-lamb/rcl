(in-package :rcl)

(named-readtables:in-readtable rcl)

[: -2 2]
;; (R ":" -2 2)
;; = [seq -2 2]
;;(-2 -1 0 1 2)

(r-parse-eval "pi")
;;3.141592653589793d0

;; this won't work
;; [pi]

(r "class" (r-variable "pi"))
;; = (r-parse-eval "class(pi)")
;;"numeric"

[^ pi [: -2 2]]
;; (R "^" PI (R% ":" -2 2))
;; = (r-parse-eval "pi^(-2:2)")
;; = #?pi^(-2:2)
;;(0.10132118364233778d0 0.3183098861837907d0 1.0d0 3.141592653589793d0 9.869604401089358d0)

(r "factor" '("uk" "us" "no" "au" "uk" "us" "us"))
;;(3 4 2 1 3 4 4)

(r "library" "MASS")
;;("MASS" "stats" "graphics" "grDevices" "utils" "datasets" "methods" "base")

(defvar *painters* (r-variable "painters"))

(r-to-lisp *painters*)
;; #<R-DATAFRAME 54 rows, 5 columns, column names :|Composition| :|Drawing| :|Colour| :|Expression| :|School| {1004B79FA3}>

(r "head" *painters*)
;; #<R-DATAFRAME 6 rows, 5 columns, column names :|Composition| :|Drawing| :|Colour| :|Expression| :|School| {1004C49CA3}>


(describe *)
;; #<R-DATAFRAME 5 rows, column names :|Composition| :|Drawing| :|Colour|..
;;   [standard-object]
;; Slots with :INSTANCE allocation:
;;   DATA      = ((10 15 8 12 0 15) (8 16 13 16 15 16) (16 4 16 9 8 4) (3 14 7 8 0 14)..
;;   NAMES     = (:|Composition| :|Drawing| :|Colour| :|Expression| :|School|)
;;   ROWNAMES  = NIL
	       
(r "summary" *painters*)
;; #<R-MATRIX #2A(("Min.   : 0.00  " "Min.   : 6.00  " "Min.   : 0.00  "
;;                 "Min.   : 0.000  " "A      :10  ")
;;                ("1st Qu.: 8.25  " "1st Qu.:10.00  " "1st Qu.: 7.25  "
;;                 "1st Qu.: 4.000  " "D      :10  ")
;;                ("Median :12.50  " "Median :13.50  " "Median :10.00  "
;;                 "Median : 6.000  " "E      : 7  ")
;;                ("Mean   :11.56  " "Mean   :12.46  " "Mean   :10.94  "
;;                 "Mean   : 7.667  " "G      : 7  ")
;;                ("3rd Qu.:15.00  " "3rd Qu.:15.00  " "3rd Qu.:16.00  "
;;                 "3rd Qu.:11.500  " "B      : 6  ")
;;                ("Max.   :18.00  " "Max.   :18.00  " "Max.   :18.00  "
;;                 "Max.   :18.000  " "C      : 6  ")
;;                ("NA" "NA" "NA" "NA" "(Other): 8  "))
;;         (("" "" "" "" "" "" "")
;;          (" Composition" "   Drawing" "    Colour" "  Expression" "    School"))
;;         {100ED22813}>

(r "as.matrix" *painters*)
;; #<R-MATRIX #2A(("10" " 8" "16" " 3" "A")
;;                ("15" "16" " 4" "14" "A")
;;                (" 8" "13" "16" " 7" "A")
;;                ("12" "16" " 9" " 8" "A")
;;                (" 0" "15" " 8" " 0" "A")
;;                ("15" "16" " 4" "14" "A")
;;                (" 8" "17" " 4" " 8" "A")
;;                ("15" "16" " 7" " 6" "A")
;;                (" 4" "12" "10" " 4" "A")
;;                ("17" "18" "12" "18" "A")
;;                ("10" "13" " 8" " 8" "B")
;;                ("13" "15" " 8" " 8" "B")
;;                ("10" "15" " 6" " 6" "B")
;;                ("15" "14" " 7" "10" "B")
;;                ("13" "14" "10" " 9" "B")
;;                ("12" "15" " 5" " 8" "B")
;;                ("14" "15" " 6" "10" "C")
;;                ("16" "14" "12" " 6" "C")
;;                ("10" "10" " 6" " 2" "C")
;;                ("13" "12" " 9" " 6" "C")
;;                ("11" "15" " 0" " 6" "C")
;;                ("15" "15" "12" "13" "C")
;;                (" 6" " 8" "17" " 0" "D")
;;                (" 4" " 6" "14" " 0" "D")
;;                (" 8" " 9" "18" " 4" "D")
;;                (" 6" " 8" "15" " 4" "D")
;;                ("12" " 9" "14" " 6" "D")
;;                (" 5" " 6" "16" " 0" "D")
;;                (" 8" "14" "17" " 5" "D")
;;                ("15" "14" "16" " 4" "D")
;;                ("12" "15" "18" " 6" "D")
;;                ("15" "10" "16" " 3" "D")
;;                ("14" "14" "10" " 6" "E")
;;                (" 6" " 6" "16" " 0" "E")
;;                ("13" "13" "15" "12" "E")
;;                ("15" "17" " 9" "17" "E")
;;                ("18" "10" "10" " 4" "E")
;;                ("14" "13" "10" " 5" "E")
;;                ("15" "17" "13" "13" "E")
;;                (" 8" "10" "10" " 8" "F")
;;                (" 9" "10" "16" "13" "F")
;;                (" 4" "15" " 6" " 6" "F")
;;                (" 8" " 6" " 6" " 4" "F")
;;                ("11" "10" "14" " 6" "G")
;;                ("10" " 8" "16" " 6" "G")
;;                ("13" "14" "10" "10" "G")
;;                ("15" " 6" "17" "12" "G")
;;                ("18" "13" "17" "17" "G")
;;                ("15" "12" "13" " 6" "G")
;;                ("15" "10" "17" "13" "G")
;;                ("10" " 8" " 8" " 4" "H")
;;                ("16" "16" " 8" "16" "H")
;;                ("15" "15" " 4" "15" "H")
;;                ("15" "17" " 6" "15" "H"))
;;             (("Da Udine" "Da Vinci" "Del Piombo" "Del Sarto" "Fr. Penni"
;; 	      "Guilio Romano" "Michelangelo" "Perino del Vaga" "Perugino"
;; 	      "Raphael" "F. Zucarro" "Fr. Salviata" "Parmigiano" "Primaticcio"
;; 	      "T. Zucarro" "Volterra" "Barocci" "Cortona" "Josepin" "L. Jordaens"
;; 	      "Testa" "Vanius" "Bassano" "Bellini" "Giorgione" "Murillo"
;; 	      "Palma Giovane" "Palma Vecchio" "Pordenone" "Tintoretto" "Titian"
;; 	      "Veronese" "Albani" "Caravaggio" "Corregio" "Domenichino" "Guercino"
;; 	      "Lanfranco" "The Carraci" "Durer" "Holbein" "Pourbus" "Van Leyden"
;; 	      "Diepenbeck" "J. Jordaens" "Otho Venius" "Rembrandt" "Rubens"
;; 	      "Teniers" "Van Dyck" "Bourdon" "Le Brun" "Le Suer" "Poussin")
;; 	     ("Composition" "Drawing" "Colour" "Expression" "School"))
;;            {100FBFFB63}>

;; ;; (defun group-elements (list dims)
;; ;;   (let ((size (first dims))
;; ;; 	(nested (rest dims)))
;; ;;     (when nested
;; ;;       (setf list (group-elements list nested)))
;; ;;     (unless (zerop (mod (length list) size)) 
;; ;;       (error "group size (~A) is not a divisor of list length (~A)" size (length list)))
;; ;;     (loop for i from 0 below (length list) by size
;; ;; 	  collect (subseq list i (+ i size)))))

;; ;; (defun r-obj-decode-array (r-pointer)
;; ;;   (multiple-value-bind (primary attributes)
;; ;;       (r-to-lisp r-pointer)
;; ;;     (let* ((dimensions (reverse (rest (find :dim attributes :key #'car)))))
;; ;;       (make-array dimensions :initial-contents 
;; ;; 		  (group-elements primary (rest dimensions))))))

(r "print" (r% "array" (loop for i from 1 to 12 collect i) '(4 3)))
;R#      [,1] [,2] [,3]
;R# [1,]    1    5    9
;R# [2,]    2    6   10
;R# [3,]    3    7   11
;R# [4,]    4    8   12
#<R-MATRIX #2A((1 5 9) (2 6 10) (3 7 11) (4 8 12)) NIL {10C8691D13}>

(r "print" (r% "array" (loop for i from 1 to 24 collect i) '(4 3 2)))
;R# , , 1
;R# 
;R#      [,1] [,2] [,3]
;R# [1,]    1    5    9
;R# [2,]    2    6   10
;R# [3,]    3    7   11
;R# [4,]    4    8   12
;R# 
;R# , , 2
;R# 
;R#      [,1] [,2] [,3]
;R# [1,]   13   17   21
;R# [2,]   14   18   22
;R# [3,]   15   19   23
;R# [4,]   16   20   24
;R# 
#<R-MATRIX #3A(((1 13) (5 17) (9 21))
               ((2 14) (6 18) (10 22))
               ((3 15) (7 19) (11 23))
               ((4 16) (8 20) (12 24))) NIL {10CB301213}>
