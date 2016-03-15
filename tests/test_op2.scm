(use-modules (oop goops)
             (aiscm util)
             (aiscm element)
             (aiscm bool)
             (aiscm int)
             (aiscm complex)
             (aiscm rgb)
             (aiscm pointer)
             (aiscm asm)
             (aiscm jit)
             (aiscm sequence)
             (aiscm op)
             (guile-tap))
(planned-tests 53)
(skip (equal?  '((((2 2) (2 2)) ((2 2) (2 2))) (((2 2) (2 2)) ((2 2) (2 2))))
             (to-list (+ 1 (fill <int> '(2 2 2 2) 1))))
    "add 1 to 4D array")
(skip (equal? '(-2 3 5) (to-list (to-type <byte> (seq -2 3 5))))
    "trivial type conversion")
(skip (eq? <int> (typecode (to-type <int> (seq 2 3 5))))
    "element-wise type conversion converts to target type")
(skip (equal? '(2 3 5) (to-list (to-type <uint> (seq 2 3 5))))
    "element-wise conversion preserves values when increasing integer size")
(skip (equal? '(-2 3 5) (to-list (to-type <int> (seq -2 3 5))))
    "element-wise conversion preserves sign when increasing integer size")
(skip (equal? '(254 3 5) (to-list (to-type <ubyte> (seq -2 3 5))))
    "typecasting to corresponding signed integer type")
(skip (equal? '(255 0 1) (to-list (to-type <ubyte> (seq 255 256 257))))
    "typecasting to smaller integer type")
(skip (equal? '(#f #t #f) (to-list (=0 (seq -1 0 1))))
    "compare bytes with zero")
(skip (equal? '(#f #t #f) (to-list (=0 (seq <int> -1 0 1))))
    "compare integers with zero")
(skip (equal? '(#t #f #t) (to-list (!=0 (seq -1 0 1))))
    "check whether bytes are not zero")
(skip (equal? '(#f #t #f) (to-list (! (seq #t #f #t))))
    "element-wise not for booleans")
(skip (equal? '(#f #t) (to-list (= (seq 3 4) (seq 5 4))))
    "element-wise array-array comparison")
(skip (equal? '(#f #t) (to-list (= 4 (seq 5 4))))
    "element-wise scalar-array comparison")
(skip (equal? '(#f #t #f) (to-list (= (seq 3 4 5) 4)))
    "element-wise array-scalar comparison")
(skip (equal? '(#t #f #t) (to-list (!= (seq 3 4 5) 4)))
    "element-wise not-equal")
(skip (equal? '(#t #f #f) (to-list (< (seq 3 4 5) 4)))
    "element-wise lower-than")
(skip (equal? '(#t #t #f) (to-list (<= (seq 3 4 5) 4)))
    "element-wise lower-equal")
(skip (equal? '(#f #f #t) (to-list (> (seq 3 4 5) 4)))
    "element-wise greater-than")
(skip (equal? '(#f #t #t) (to-list (>= (seq 3 4 5) 4)))
    "element-wise greater-equal")
(skip (equal? '(#t #f #f) (to-list (< (seq -1 0 1) 0)))
    "element-wise lower-than of signed and unsigned bytes")
(skip (equal? '(#t #t #f) (to-list (<= (seq -1 0 1) 0)))
    "element-wise lower-equal of signed and unsigned bytes")
(skip (equal? '(#f #f #t) (to-list (> (seq -1 0 1) 0)))
    "element-wise greater-than of signed and unsigned bytes")
(skip (equal? '(#f #t #t) (to-list (>= (seq -1 0 1) 0)))
    "element-wise greater-equal of signed and unsigned bytes")
(skip (equal? '(#f #f #f) (to-list (< (seq 1 2 128) -1)))
    "element-wise lower-than of unsigned and signed bytes")
(skip (equal? '(#f #f #f) (to-list (<= (seq 1 2 128) -1)))
    "element-wise lower-equal of unsigned and signed bytes")
(skip (equal? '(#t #t #t) (to-list (> (seq 1 2 128) -1)))
    "element-wise greater-than of unsigned and signed bytes")
(skip (equal? '(#t #t #t) (to-list (>= (seq 1 2 128) -1)))
    "element-wise greater-equal of unsigned and signed bytes")
; ------------------------------------------------------------------------------

(skip (equal? '(#f #f #f #t) (to-list (&& (seq #f #t #f #t) (seq #f #f #t #t))))
    "element-wise and")
(skip (equal? '(#f #t #f #f) (to-list (&& (seq #f #t #t #t) (seq #t #t #t #f) (seq #t #t #f #f))))
    "element-wise and with three arguments")
(skip (equal? '(#f #t) (to-list (&& (seq #f #t) #t)))
    "element-wise and with array and boolean argument")
(skip (equal? '(#f #t) (to-list (&& #t (seq #f #t))))
    "element-wise and with boolean argument and array")
(skip (equal? '(#f #t #t #t) (to-list (|| (seq #f #t #f #t) (seq #f #f #t #t))))
    "element-wise or")
(skip (equal? '(2 3)  (to-list (red (seq <intrgb> (rgb 2 3 5) (rgb 3 5 7)))))
    "extract red channel of RGB array")
(skip (equal? '(3 5)  (to-list (green (seq <intrgb> (rgb 2 3 5) (rgb 3 5 7)))))
    "extract green channel of RGB array")
(skip (equal? '(5 7)  (to-list (blue (seq <intrgb> (rgb 2 3 5) (rgb 3 5 7)))))
    "extract blue channel of RGB array")
(ok (equal? '(2 3 5) (to-list (red (seq 2 3 5))))
    "extract red channel of scalar array")
(ok (equal? '(2 3 5) (to-list (green (seq 2 3 5))))
    "extract green channel of scalar array")
(ok (equal? '(2 3 5) (to-list (blue (seq 2 3 5))))
    "extract blue channel of scalar array")
(skip (equal? (list (rgb 1 2 3)) (to-list (+ (seq (rgb 0 1 2)) 1)))
    "RGB array plus integer")
(skip (equal? (list (rgb 3 2 1)) (to-list (- 4 (seq (rgb 1 2 3)))))
    "subtract RGB array from integer")
(skip (equal? (list (rgb 2 4 9)) (to-list (* (rgb 2 2 3) (seq (rgb 1 2 3)))))
    "multiply RGB array")
(skip (equal? (list (rgb 1 2 3)) (to-list (>> (seq (rgb 2 4 6)) 1)))
    "right-shift RGB values")
(skip (equal? (list (rgb 1 2 3)) (to-list (/ (seq (rgb 2 4 6)) 2)))
    "divide RGB values")
(skip (equal? '(2 2 3 4) (to-list (max (seq <int> 1 2 3 4) 2)))
    "major value")
(skip (equal? '(1 2 2 2) (to-list (min (seq <int> 1 2 3 4) 2)))
    "minor value")
(skip (equal? (list 2+3i) (to-list (+ (seq 1+2i) 1+i)))
    "complex array plus complex value")
(skip (equal? (list 2-3i) (to-list (- (seq -2+3i))))
    "negate complex array")
(skip (equal? '(2 5) (to-list (real-part (seq 2+3i 5+7i))))
    "element-wise real part of complex array")
(skip (equal? '(3 7) (to-list (imag-part (seq 2+3i 5+7i))))
    "element-wise imaginary part of complex array")
(ok (equal? '(2 5) (to-list (real-part (seq 2 5))))
    "element-wise real part of real array")
(ok (equal? '(0 0) (to-list (imag-part (seq 2 5))))
    "element-wise imaginary part of real array")
(skip (equal? '(2 5) (to-list (conj (seq 2 5))))
    "complex conjugate of real array")
(skip (equal? '(2-3i 4-5i) (to-list (conj (seq (complex <byte>) 2+3i 4+5i))))
    "complex conjugate of complex array")
