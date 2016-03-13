(use-modules (oop goops)
             (aiscm util)
             (aiscm element)
             (aiscm pointer)
             (aiscm int)
             (aiscm asm)
             (aiscm jit)
             (aiscm sequence)
             (aiscm op)
             (guile-tap))
(planned-tests 31)
(ok (equal? '(3 3 3) (to-list (fill <byte> '(3) 3)))
    "fill byte sequence")
(ok (equal? '(3 3 3) (to-list (fill <int> '(3) 3)))
    "fill integer sequence")
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
(ok (equal? '(12345678901234567890)
             (to-list (+ (seq 12345678900000000000) 1234567890)))
    "add unsigned long integer and unsigned integer")
(skip (equal? '(-257 -256 -255) (to-list (- (seq -1 0 1) 256)))
    "element-wise subtract 256 from an array")
(skip (equal? '(256 255 254) (to-list (- 256 (seq 0 1 2))))
    "element-wise subtract array from 256")
(skip (equal? '(2 1 0) (to-list (- (seq 4 5 6) (seq 2 4 6))))
    "subtract an array from another")
(ok (equal? '(2 4) (to-list (+ (downsample 2 (seq 1 2 3 4)) 1)))
    "add 1 to downsampled array")
(ok (equal? '(2 4) (to-list (+ 1 (downsample 2 (seq 1 2 3 4)))))
    "add downsampled array to 1")
(ok (equal? '(2 6) (let [(s (downsample 2 (seq 1 2 3 4)))] (to-list (+ s s))))
    "add two downsampled arrays")
(ok (equal? '((-1 2) (3 -4)) (to-list (- (arr (1 -2) (-3 4)))))
    "negate 2D array")
(skip (equal? '((0 1 2) (3 4 5)) (to-list (- (arr (1 2 3) (4 5 6)) 1)))
    "subtract 1 from a 2D array")
(skip (equal? '((6 5 4) (3 2 1)) (to-list (- 7 (arr (1 2 3) (4 5 6)))))
    "subtract 2D array from integer")
(skip (equal? '((1 1 2) (3 4 5)) (to-list (- (arr (2 3 5) (7 9 11)) (arr (1 2 3) (4 5 6)))))
    "subtract 2D array from each other")
(ok (equal? '(((-1 2 -3) (4 -5 6))) (to-list (- (arr ((1 -2 3) (-4 5 -6))))))
    "negate 3D array")
(ok (equal? '(((2 3 4) (5 6 7))) (to-list (+ (arr ((1 2 3) (4 5 6))) 1)))
    "add scalar to 3D array")
(ok (equal? '(((2 3 4) (5 6 7))) (to-list (+ 1 (arr ((1 2 3) (4 5 6))))))
    "add 3D array to scalar")
(ok (equal? '(((2 4 6) (8 10 12))) (let [(m (arr ((1 2 3) (4 5 6))))] (to-list (+ m m))))
    "add two 3D arrays")
