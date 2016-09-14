(use-modules (oop goops) (aiscm element) (aiscm v4l2) (aiscm xorg))
(define v (make <v4l2>))
(define d (make <xdisplay> #:name ":0.0"))
(define w (make <xwindow> #:display d #:shape '(640 480) #:io IO-XVIDEO))
(title= w "Test")
(show w)
(while (not (quit? d)) (show w (read-image v)) (process-events d))
(quit= d #f)
(hide w)
(destroy d)
(destroy v)
