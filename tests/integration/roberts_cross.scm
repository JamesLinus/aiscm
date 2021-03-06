(use-modules (aiscm magick) (aiscm convolution) (aiscm tensor) (aiscm sequence) (aiscm image) (aiscm element) (aiscm int))
(define (to-gray img) (to-array (convert-image (to-image img) 'GRAY)))
(define (norm x y) (tensor (/ (+ (abs x) (abs y)) 2)))
(define (roberts-cross img) (/ (norm (convolve img (arr (+1 0) ( 0 -1))) (convolve img (arr ( 0 +1) (-1 0)))) 2))
(write-image (to-type <ubyte> (roberts-cross (to-gray (read-image "star-ferry.jpg")))) "roberts-cross.jpg")
