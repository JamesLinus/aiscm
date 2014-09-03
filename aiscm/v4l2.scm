(define-module (aiscm v4l2)
  #:use-module (oop goops)
  #:use-module (aiscm mem)
  #:use-module (aiscm int)
  #:use-module (aiscm sequence)
  #:use-module (system foreign)
  #:export (make-v4l2 v4l2-close v4l2-read))
(load-extension "libguile-v4l2" "init_v4l2")
(define (v4l2-read self)
  (let* [(ptr (v4l2-read-orig self))
         (mem (make <mem> #:memory ptr #:base ptr #:size (* 640 480 2)))]
    (make (multiarray <ubyte> 2)
          #:value mem
          #:shape '(640 480)
          #:strides '(2 1280))))
