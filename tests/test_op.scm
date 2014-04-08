(use-modules (oop goops)
             (aiscm element)
             (aiscm int)
             (aiscm sequence)
             (aiscm op)
             (guile-tap))
(planned-tests 23)
(define s1 (make <sint> #:value (random (ash 1 14))))
(define s2 (make <sint> #:value (random (ash 1 14))))
(define i1 (make <int> #:value (random (ash 1 29))))
(define i2 (make <int> #:value (random (ash 1 29))))
(define i3 (make <int> #:value (random (ash 1 29))))
(define l1 (make <long> #:value (random (ash 1 62))))
(define l2 (make <long> #:value (random (ash 1 62))))
(define seqb1 (make (sequence <byte>) #:size 3))
(define seqs1 (make (sequence <sint>) #:size 3))
(define seqi1 (make (sequence <int>) #:size 3))
(define seql1 (make (sequence <long>) #:size 3))
(ok (eqv? (+ (get-value i1) (get-value i2)) (get-value (+ i1 i2)))
    "add two integers")
(ok (eqv? (+ (get-value l1) (get-value l2)) (get-value (+ l1 l2)))
    "add two long integers")
(ok (eqv? (+ (get-value i1) (get-value l2)) (get-value (+ i1 l2)))
    "add integer and long integer")
(ok (eqv? 64 (bits (class-of (+ i1 l1))))
    "check type coercion of addition")
(ok (eqv? (+ (get-value i1) (get-value i2) (get-value i3)) (get-value (+ i1 i2 i3)))
    "add three integers")
(ok (eqv? (+ (get-value i1)) (get-value (+ i1)))
    "unary plus")
(ok (eqv? (- (get-value i1) (get-value i2)) (get-value (- i1 i2)))
    "subtract two integers")
(ok (eqv? (+ (get-value i1) (get-value i2)) (get-value (+ i1 (get-value i2))))
    "add integer and Guile integer")
(ok (eqv? (+ (get-value i1) (get-value i2)) (get-value (+ (get-value i1) i2)))
    "add Guile integer and integer")
(ok (eqv? (- (get-value i1) (get-value i2)) (get-value (- i1 (get-value i2))))
    "subtract integer and Guile integer")
(ok (eqv? (- (get-value i1) (get-value i2)) (get-value (- (get-value i1) i2)))
    "subtract Guile integer and integer")
(ok (eqv? (- (get-value i1)) (get-value (- i1)))
    "negate integer")
(ok (equal? '(3 3 3) (sequence->list (fill! seqi1 3)))
    "fill integer sequence")
(ok (equal? '(3 3 3) (sequence->list (fill! seqs1 3)))
    "fill short integer sequence")
(ok (equal? '(3 3 3) (sequence->list (fill! seqb1 3)))
    "fill byte sequence")
(ok (equal? '(3 3 3) (sequence->list (fill! seql1 3)))
    "fill long integer sequence")
(ok (equal? '(-3 -3 -3) (sequence->list (- (fill! seqi1 3))))
    "negate integer sequence")
(ok (equal? '(-3 -3 -3) (sequence->list (- (fill! seqs1 3))))
    "negate short integer sequence")
(ok (equal? '(-3 -3 -3) (sequence->list (- (fill! seqb1 3))))
    "negate byte sequence")
(ok (equal? '(-3 -3 -3) (sequence->list (- (fill! seql1 3))))
    "negate long integer sequence")
(ok (equal? '(1 -2 -3) (sequence->list (- (list->sequence '(-1 2 3)))))
    "negate sequence")
(ok (equal? '(4 4 4) (sequence->list (+ (fill! seqi1 3) 1)))
    "add integer to integer sequence")
(ok (equal? '(4 4 4) (sequence->list (+ 1 (fill! seqi1 3))))
    "add integer sequence to integer")
(format #t "~&")
