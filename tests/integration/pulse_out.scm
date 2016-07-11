(use-modules (oop goops) (aiscm element) (aiscm int) (aiscm pointer) (aiscm sequence) (aiscm pulse) (aiscm util))
(define samples (to-array <sint> (map (lambda (t) (round (* (sin (/ (* t 1000 2 3.1415926) 44100)) 20000))) (iota 441))))
(define play (make <pulse-play> #:type <sint> #:channels 1 #:rate 44100))
(channels play)
;1
(rate play)
;44100
(for-each (lambda (i) (write-samples samples play)) (iota 300))
(drain play)
(destroy play)
