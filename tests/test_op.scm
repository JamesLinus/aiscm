(use-modules (oop goops)
             (aiscm element)
             (aiscm int)
             (aiscm sequence)
             (aiscm op)
             (guile-tap))
(planned-tests 53)
(define i1 (make <int> #:value (random (ash 1 29))))
(define i2 (make <int> #:value (random (ash 1 29))))
(define i3 (make <int> #:value (random (ash 1 29))))
(define l1 (make <long> #:value (random (ash 1 62))))
(define l2 (make <long> #:value (random (ash 1 62))))
(skip (eqv? (+ (get-value i1) (get-value i2)) (get-value (+ i1 i2)))
    "add two integers")
(skip (eqv? (+ (get-value l1) (get-value l2)) (get-value (+ l1 l2)))
    "add two long integers")
(skip (eqv? (+ (get-value i1) (get-value l2)) (get-value (+ i1 l2)))
    "add integer and long integer")
(skip (eqv? 64 (bits (class-of (+ i1 l1))))
    "check type coercion of addition")
(skip (eqv? (+ (get-value i1) (get-value i2) (get-value i3)) (get-value (+ i1 i2 i3)))
    "add three integers")
(skip (eqv? 0 (get-value (+ (make <byte> #:value -1) (make <sint> #:value 1))))
    "add negative byte and positive short integer")
(skip (eqv? 0 (get-value (+ (make <sint> #:value 1) (make <byte> #:value -1))))
    "add positive short integer and negative byte")
(skip (eqv? (+ (get-value i1)) (get-value (+ i1)))
    "unary plus")
(skip (eqv? (- (get-value i1) (get-value i2)) (get-value (- i1 i2)))
    "subtract two integers")
(skip (eqv? (+ (get-value i1) (get-value i2)) (get-value (+ i1 (get-value i2))))
    "add integer and Guile integer")
(skip (eqv? (+ (get-value i1) (get-value i2)) (get-value (+ (get-value i1) i2)))
    "add Guile integer and integer")
(skip (eqv? (- (get-value i1) (get-value i2)) (get-value (- i1 (get-value i2))))
    "subtract integer and Guile integer")
(skip (eqv? (- (get-value i1) (get-value i2)) (get-value (- (get-value i1) i2)))
    "subtract Guile integer and integer")
(skip (eqv? (- (get-value i1)) (get-value (- i1)))
    "negate integer")
(skip (equal? '(3 3 3) (multiarray->list (fill <byte> 3 3)))
    "fill byte sequence")
(skip (equal? '(3 3 3) (multiarray->list (fill <int> 3 3)))
    "fill integer sequence")
(skip (equal? '(-3 -3 -3) (multiarray->list (- (fill <int> 3 3))))
    "negate integer sequence")
(skip (equal? '(-3 -3 -3) (multiarray->list (- (fill <sint> 3 3))))
    "negate short integer sequence")
(skip (equal? '(-3 -3 -3) (multiarray->list (- (fill <byte> 3 3))))
    "negate byte sequence")
(skip (equal? '(-3 -3 -3) (multiarray->list (- (fill <long> 3 3))))
    "negate long integer sequence")
(skip (equal? '(1 -2 -3) (multiarray->list (- (list->multiarray '(-1 2 3)))))
    "negate sequence")
(skip (equal? '(4 4 4) (multiarray->list (+ (fill <int> 3 3) 1)))
    "add integer to integer sequence")
(skip (equal? '(257 257 257) (multiarray->list (+ (fill <byte> 3 1) 256)))
    "add integer to byte sequence")
(skip (equal? '(257 257 257) (multiarray->list (+ 256 (fill <byte> 3 1))))
    "add byte sequence to integer")
(skip (equal? '(4 4 4) (multiarray->list (+ 1 (fill <int> 3 3))))
    "add integer sequence to integer")
(skip (equal? '(4 4 4) (multiarray->list (+ (fill <int> 3 1) (fill <int> 3 3))))
    "add integer sequences")
(skip (equal? '(4 4 4) (multiarray->list (+ (fill <byte> 3 1) (fill <sint> 3 3))))
    "add byte and short integer sequences")
(skip (equal? '(4 4 4) (multiarray->list (+ (fill <sint> 3 1) (fill <byte> 3 3))))
    "add short integer and byte sequences")
(skip (equal? '(255 254 253) (multiarray->list (+ (list->multiarray '(-1 -2 -3)) 256)))
    "sign-expand negative values when adding byte sequence and short integer")
(skip (equal? '(255 254 253) (multiarray->list (+ 256 (list->multiarray '(-1 -2 -3)))))
    "sign-expand negative byte values when adding short integer and byte sequence")
(skip (equal? '(255) (multiarray->list (+ (list->multiarray '(-1)) (list->multiarray '(256)))))
    "sign-expand negative byte values when adding byte sequence and short integer sequence")
(skip (equal? '(255) (multiarray->list (+ (list->multiarray '(256)) (list->multiarray '(-1)))))
    "sign-expand negative byte values when adding short integer sequence and byte sequence")
(skip (equal? '(255) (multiarray->list (+ (list->multiarray '(256)) -1)))
    "sign-expand negative byte value when adding it to short integer sequence")
(skip (equal? '(255) (multiarray->list (+ (list->multiarray '(256)) -1)))
    "sign-expand negative value when short integer sequence is added to it")
(skip (equal? '(-257 -256 -255) (multiarray->list (- (list->multiarray '(-1 0 1)) 256)))
    "element-wise subtract 1 from an array")
(skip (equal? '(256 255 254) (multiarray->list (- 256 (list->multiarray '(0 1 2)))))
    "element-wise subtract array from 256")
(skip (equal? '(2 1 0) (multiarray->list (- (list->multiarray '(4 5 6)) (list->multiarray '(2 4 6)))))
    "subtract an array from another")
(skip (equal? '(2 4) (multiarray->list (+ (downsample 2 (list->multiarray '(1 2 3 4))) 1)))
    "add 1 to downsampled array")
(skip (equal? '(2 4) (multiarray->list (+ 1 (downsample 2 (list->multiarray '(1 2 3 4))))))
    "add downsampled array to 1")
(skip (equal? '(2 6) (let [(s (downsample 2 (list->multiarray '(1 2 3 4))))] (multiarray->list (+ s s))))
    "add two downsampled arrays")
(skip (equal? '((-1 2) (3 -4)) (multiarray->list (- (list->multiarray '((1 -2) (-3 4))))))
    "negate 2D array")
(skip (equal? '((0 1 2) (3 4 5)) (multiarray->list (- (list->multiarray '((1 2 3) (4 5 6))) 1)))
    "subtract 1 from a 2D array")
(skip (equal? '((0 1 2) (3 4 5)) (multiarray->list (- (list->multiarray '((1 2 3) (4 5 6))) 1)))
    "subtract integer from a 2D array")
(skip (equal? '((6 5 4) (3 2 1)) (multiarray->list (- 7 (list->multiarray '((1 2 3) (4 5 6))))))
    "subtract 2D array from integer")
(skip (equal? '((1 1 2) (3 4 5)) (multiarray->list (- (list->multiarray '((2 3 5) (7 9 11)))
                                                    (list->multiarray '((1 2 3) (4 5 6))))))
    "subtract 2D array from each other")
(skip (equal? '(((-1 2 -3) (4 -5 6))) (multiarray->list (- (list->multiarray '(((1 -2 3) (-4 5 -6)))))))
    "negate 3D array")
(skip (equal? '(((2 3 4) (5 6 7))) (multiarray->list (+ (list->multiarray '(((1 2 3) (4 5 6)))) 1)))
    "add scalar to 3D array")
(skip (equal? '(((2 3 4) (5 6 7))) (multiarray->list (+ 1 (list->multiarray '(((1 2 3) (4 5 6)))))))
    "add 3D array to scalar")
(skip (equal? '(((2 4 6) (8 10 12))) (let [(m (list->multiarray '(((1 2 3) (4 5 6)))))]
                                     (multiarray->list (+ m m))))
    "add two 3D arrays")
(skip (equal? '((2 4) (6 8)) (multiarray->list (* 2 (list->multiarray '((1 2) (3 4))))))
    "scalar-array multiplication")
(skip (equal? '((256 256) (256 256)) (multiarray->list (* 256 (list->multiarray '((1 1) (1 1))))))
    "correct handling of strides with 2D short integer array")
(skip (equal? '((1 3) (2 4)) (multiarray->list (duplicate (roll (list->multiarray '((1 2) (3 4)))))))
    "'duplicate' creates copy of array")
(skip (equal? '(1 2) (strides (duplicate (roll (list->multiarray '((1 2) (3 4)))))))
    "'duplicate' creates a compact copy of the array")
