(in-package :rcl)

;; (named-readtables:in-readtable rcl)

(r "library" "shiny")

(defvar *ui* (r%-parse-eval "fluidPage()"))

(defvar *ui* (r%-parse-eval "fluidPage(
  titlePanel('Hello Shiny!'),
  sidebarLayout( 
    sidebarPanel( 
      sliderInput(inputId = 'bins', label = 'Number of bins:', min = 1, max = 50, value = 30),
      actionButton(inputId = 'quit', label = 'Quit')),
    mainPanel(
      plotOutput(outputId = 'distPlot'))))"))

(r "class" *ui*)
;; ("shiny.tag.list" "list")

(r "[" *ui* 1)
;; ((:||))
(r "[" *ui* 2)
;; ((:||))
(r "[" *ui* 3)


(r-to-lisp *ui*)

(r-print *ui*)



;; it's used (directly or the result if ui is a function) by renderPage in shiny/R/shinyui.R
;; which in turn calls htmlTemplate
;; fluidPage calls bootstrapPage in shiny/R/bootstrap.R
;; which returns a shiny.tag.list : title (opt), theme (opt), content

(defvar *server* (r%-parse-eval "function(input, output) {
  observeEvent(input$quit, { stopApp() })
  output$distPlot <- renderPlot({
    x    <- faithful$waiting
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    hist(x, breaks = bins, col = '#75AADB', border = 'white', 
         xlab = 'Waiting time to next eruption (in mins)', 
         main = 'Histogram of waiting times') }) }"))

(r-to-lisp *server*)

(r:r-print *server*)

(defvar *app* (r% "shinyApp" *ui* *server*))

(r-to-lisp *app*)

(r "ls" (r%-parse-eval "shiny:::.globals"))

(r "runApp" *app* :port 2222 :launch.browser T)

(r:r-print (r%-symbol "runApp"))

(r-to-lisp (r%-symbol "runApp"))


#+NIL(r "functionBody<-" (rf-findfun (rf-install "server") r::*r-globalenv*) :value "{
  observeEvent(input$quit, { stopApp() })
  output$distPlot <- renderPlot({
    x    <- faithful$waiting
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    hist(x, breaks = bins, col = '#75AADB', border = 'white', 
         xlab = 'Waiting again to next eruption (in mins)', 
         main = 'Histogram of waiting times') }) }")
