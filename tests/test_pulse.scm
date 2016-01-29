(use-modules (oop goops)
             (aiscm pulse)
             (guile-tap))
(planned-tests 5)
(ok (not (throws? (check-audio-sample-shape '(100) 1)))
    "check one-dimensional audio sample")
(ok (throws? (check-audio-sample-shape '(100) 2))
    "one-dimensional audio sample only works with one audio channel")
(ok (not (throws? (check-audio-sample-shape '(2 100) 2)))
    "check two-dimensional audio sample")
(ok (throws? (check-audio-sample-shape '(3 100) 2))
    "first dimension of 2D array must match number of channels")
(ok (throws? (check-audio-sample-shape '(2 2 100) 3))
    "audio sample array must not have more than 2 dimensions")
