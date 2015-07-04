(use-modules (oop goops)
             (aiscm element)
             (aiscm int)
             (aiscm jit)
             (aiscm sequence)
             (aiscm op)
             (guile-tap))
(planned-tests 80)
(ok (equal? '(3 3 3) (to-list (fill <byte> '(3) 3)))
    "fill byte sequence")
(ok (equal? '(3 3 3) (to-list (fill <int> '(3) 3)))
    "fill integer sequence")
(ok (equal? '(-3 -3 -3) (to-list (- (fill <int> '(3) 3))))
    "negate integer sequence")
(ok (equal? '(-3 -3 -3) (to-list (- (fill <sint> '(3) 3))))
    "negate short integer sequence")
(ok (equal? '(-3 -3 -3) (to-list (- (fill <byte> '(3) 3))))
    "negate byte sequence")
(ok (equal? '(-3 -3 -3) (to-list (- (fill <long> '(3) 3))))
    "negate long integer sequence")
(ok (equal? '(1 -2 -3) (to-list (- (seq -1 2 3))))
    "negate sequence")
(ok (equal? '(4 4 4) (to-list (+ (fill <int> '(3) 3) 1)))
    "add integer to integer sequence")
(ok (equal? '(2 2 2) (to-list (+ (fill <int> '(3) 3) (- 1))))
    "add negative integer to integer sequence")
(ok (equal? '(257 257 257) (to-list (+ (fill <byte> '(3) 1) 256)))
    "add integer to byte sequence")
(ok (equal? '(257 257 257) (to-list (+ 256 (fill <byte> '(3) 1))))
    "add byte sequence to integer")
(ok (equal? '(4 4 4) (to-list (+ 1 (fill <int> '(3) 3))))
    "add integer sequence to integer")
(ok (equal? '(4 4 4) (to-list (+ (fill <int> '(3) 1) (fill <int> '(3) 3))))
    "add integer sequences")
(ok (equal? '(4 4 4) (to-list (+ (fill <byte> '(3) 1) (fill <sint> '(3) 3))))
    "add byte and short integer sequences")
(ok (equal? '(4 4 4) (to-list (+ (fill <sint> '(3) 1) (fill <byte> '(3) 3))))
    "add short integer and byte sequences")
(ok (equal? '(255 254 253) (to-list (+ (seq -1 -2 -3) 256)))
    "sign-expand negative values when adding byte sequence and short integer")
(ok (equal? '(255 254 253) (to-list (+ 256 (seq -1 -2 -3))))
    "sign-expand negative byte values when adding short integer and byte sequence")
(ok (equal? '(255) (to-list (+ (seq -1) (seq 256))))
    "sign-expand negative byte values when adding byte sequence and short integer sequence")
(ok (equal? '(255) (to-list (+ (seq 256) (seq -1))))
    "sign-expand negative byte values when adding short integer sequence and byte sequence")
(ok (equal? '(255) (to-list (+ (seq 256) -1)))
    "sign-expand negative byte value when adding it to short integer sequence")
(ok (equal? '(255) (to-list (+ -1 (seq 256))))
    "sign-expand negative value when short integer sequence is added to it")
(ok (equal? '(-257 -256 -255) (to-list (- (seq -1 0 1) 256)))
    "element-wise subtract 256 from an array")
(ok (equal? '(256 255 254) (to-list (- 256 (seq 0 1 2))))
    "element-wise subtract array from 256")
(ok (equal? '(2 1 0) (to-list (- (seq 4 5 6) (seq 2 4 6))))
    "subtract an array from another")
(ok (equal? '(2 4) (to-list (+ (downsample 2 (seq 1 2 3 4)) 1)))
    "add 1 to downsampled array")
(ok (equal? '(2 4) (to-list (+ 1 (downsample 2 (seq 1 2 3 4)))))
    "add downsampled array to 1")
(ok (equal? '(2 6) (let [(s (downsample 2 (seq 1 2 3 4)))] (to-list (+ s s))))
    "add two downsampled arrays")
(ok (equal? '((-1 2) (3 -4)) (to-list (- (arr (1 -2) (-3 4)))))
    "negate 2D array")
(ok (equal? '((0 1 2) (3 4 5)) (to-list (- (arr (1 2 3) (4 5 6)) 1)))
    "subtract 1 from a 2D array")
(ok (equal? '((6 5 4) (3 2 1)) (to-list (- 7 (arr (1 2 3) (4 5 6)))))
    "subtract 2D array from integer")
(ok (equal? '((1 1 2) (3 4 5)) (to-list (- (arr (2 3 5) (7 9 11)) (arr (1 2 3) (4 5 6)))))
    "subtract 2D array from each other")
(ok (equal? '(((-1 2 -3) (4 -5 6))) (to-list (- (arr ((1 -2 3) (-4 5 -6))))))
    "negate 3D array")
(ok (equal? '(((2 3 4) (5 6 7))) (to-list (+ (arr ((1 2 3) (4 5 6))) 1)))
    "add scalar to 3D array")
(ok (equal? '(((2 3 4) (5 6 7))) (to-list (+ 1 (arr ((1 2 3) (4 5 6))))))
    "add 3D array to scalar")
(ok (equal? '(((2 4 6) (8 10 12))) (let [(m (arr ((1 2 3) (4 5 6))))] (to-list (+ m m))))
    "add two 3D arrays")
(ok (equal? '((3 4 5) (7 8 9)) (to-list (+ (seq 0 1) (arr (3 4 5) (6 7 8)))))
    "add 1D and 2D array")
(ok (equal? '((3 4 5) (7 8 9)) (to-list (+ (arr (3 4 5) (6 7 8)) (seq 0 1))))
    "add 2D and 1D array")
(ok (equal?  '((((2 2) (2 2)) ((2 2) (2 2))) (((2 2) (2 2)) ((2 2) (2 2))))
             (to-list (+ 1 (fill <int> '(2 2 2 2) 1))))
    "add 1 to 4D array")
(ok (equal? '((2 4) (6 8)) (to-list (* 2 (arr (1 2) (3 4)))))
    "scalar-array multiplication")
(ok (equal? '((256 256) (256 256)) (to-list (* 256 (arr (1 1) (1 1)))))
    "correct handling of strides with 2D short integer array")
(ok (equal? '(1 4) (to-list (duplicate (project (roll (arr (1 2 3) (4 5 6)))))))
    "'duplicate' creates copy of slice")
(ok (equal? '((1 3) (2 4)) (to-list (duplicate (roll (arr (1 2) (3 4))))))
    "'duplicate' creates copy of 2D array")
(ok (equal? '(1 2) (strides (duplicate (roll (arr (1 2) (3 4))))))
    "'duplicate' creates a compact copy of the array")
(ok (equal? '(-2 3 5) (to-list (to-type (seq -2 3 5) <byte>)))
    "trivial type conversion")
(ok (eq? <int> (typecode (to-type (sequence <byte>) <int>)))
    "cast element-type to integer")
(ok (eq? <int> (typecode (to-type (seq 2 3 5) <int>)))
    "element-wise type conversion converts to target type")
(ok (equal? '(2 3 5) (to-list (to-type (seq 2 3 5) <uint>)))
    "element-wise conversion preserves values when increasing integer size")
(ok (equal? '(-2 3 5) (to-list (to-type (seq -2 3 5) <int>)))
    "element-wise conversion preserves sign when increasing integer size")
(ok (equal? '(254 3 5) (to-list (to-type (seq -2 3 5) <ubyte>)))
    "typecasting to corresponding signed integer type")
(ok (equal? '(255 0 1) (to-list (to-type (seq 255 256 257) <ubyte>)))
    "typecasting to smaller integer type")
(ok (equal? '(253 252 250) (to-list (~ (seq 2 3 5))))
    "bitwise negation of array")
(ok (equal? '(#f #t #f) (to-list (=0 (seq -1 0 1))))
    "compare bytes with zero")
(ok (equal? '(#f #t #f) (to-list (=0 (to-type (seq -1 0 1) <int>))))
    "compare integers with zero")
(ok (equal? '(#t #f #t) (to-list (!=0 (seq -1 0 1))))
    "check whether bytes are not zero")
(ok (equal? '(#f #t #f) (to-list (! (seq #t #f #t))))
    "element-wise not for booleans")
(ok (equal? '(#f #t) (to-list (= (seq 3 4) (seq 5 4))))
    "element-wise array-array comparison")
(ok (equal? '(#f #t) (to-list (= 4 (seq 5 4))))
    "element-wise scalar-array comparison")
(ok (equal? '(#f #t #f) (to-list (= (seq 3 4 5) 4)))
    "element-wise array-scalar comparison")
(ok (equal? '(#t #f #t) (to-list (!= (seq 3 4 5) 4)))
    "element-wise not-equal")
(ok (equal? '(#t #f #f) (to-list (< (seq 3 4 5) 4)))
    "element-wise lower-than")
(ok (equal? '(#t #t #f) (to-list (<= (seq 3 4 5) 4)))
    "element-wise lower-equal")
(ok (equal? '(#f #f #t) (to-list (> (seq 3 4 5) 4)))
    "element-wise greater-than")
(ok (equal? '(#f #t #t) (to-list (>= (seq 3 4 5) 4)))
    "element-wise greater-equal")
(ok (equal? '(#t #f #f) (to-list (< (seq -1 0 1) 0)))
    "element-wise lower-than of signed and unsigned bytes")
(ok (equal? '(#t #t #f) (to-list (<= (seq -1 0 1) 0)))
    "element-wise lower-equal of signed and unsigned bytes")
(ok (equal? '(#f #f #t) (to-list (> (seq -1 0 1) 0)))
    "element-wise greater-than of signed and unsigned bytes")
(ok (equal? '(#f #t #t) (to-list (>= (seq -1 0 1) 0)))
    "element-wise greater-equal of signed and unsigned bytes")
(ok (equal? '(#f #f #f) (to-list (< (seq 1 2 128) -1)))
    "element-wise lower-than of unsigned and signed bytes")
(ok (equal? '(#f #f #f) (to-list (<= (seq 1 2 128) -1)))
    "element-wise lower-equal of unsigned and signed bytes")
(ok (equal? '(#t #t #t) (to-list (> (seq 1 2 128) -1)))
    "element-wise greater-than of unsigned and signed bytes")
(ok (equal? '(#t #t #t) (to-list (>= (seq 1 2 128) -1)))
    "element-wise greater-equal of unsigned and signed bytes")
(ok (equal? '(3 0 1) (to-list (& (seq 3 4 5) 3)))
    "element-wise bit-wise and")
(ok (equal? '(3 7 7) (to-list (| 3 (seq 3 4 5))))
    "element-wise bit-wise or")
(ok (equal? '(1 7 1) (to-list (^ (seq 2 3 4) (seq 3 4 5))))
    "element-wise bit-wise xor")
(ok (equal? '(#f #f #f #t) (to-list (&& (seq #f #t #f #t) (seq #f #f #t #t))))
    "element-wise and")
(ok (equal? '(#f #t #t #t) (to-list (|| (seq #f #t #f #t) (seq #f #f #t #t))))
    "element-wise or")
(ok (equal? '(1 2 -3) (to-list (/ (seq 3 6 -9) 3)))
    "element-wise signed byte division")
(ok (equal? '(1200 -800 600) (to-list (/ 24000 (seq 20 -30 40))))
    "element-wise signed short integer division")
(ok (equal? '(120000 -80000 60000) (to-list (/ 2400000 (seq 20 -30 40))))
    "element-wise signed integer division")
(ok (equal? '(1428571428) (to-list (/ (seq 10000000000) (seq 7))))
    "element-wise long integer division")
