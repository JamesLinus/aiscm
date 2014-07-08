(use-modules (aiscm sequence)
             (aiscm element)
             (aiscm int)
             (oop goops)
             (guile-tap))
(define s1 (make (sequence <sint>) #:size 3))
(define s2 (make (sequence <sint>) #:size 3))
(define s3 (make (sequence <sint>) #:size 3))
(set s1 0 2) (set s1 1 3) (set s1 2 5)
(planned-tests 30)
(ok (equal? <sint> (typecode (sequence <sint>)))
    "Query element type of sequence class")
(ok (equal? (sequence <sint>) (sequence <sint>))
    "equality of classes")
(ok (eqv? 3 (size s1))
    "Query size of sequence")
(ok (equal? <sint> (typecode s1))
    "Query element type of sequence")
(ok (eqv? 9 (begin (set s2 2 9) (get s2 2)))
    "Write value to sequence")
(ok (eqv? 9 (set s2 2 9))
    "Write value returns input value")
(ok (eqv? 1 (dimension (sequence <sint>)))
    "Check number of dimensions of sequence type")
(ok (equal? '(3) (shape s1))
    "Query shape of sequence")
(ok (eqv? 2 (size (slice s1 1 2)))
    "Size of slice")
(ok (eqv? 5 (get (slice s1 1 2) 1))
    "Element of slice")
(ok (equal? '(2 3 5) (sequence->list s1))
    "Convert sequence to list")
(ok (equal? '(3 5)) (sequence->list (slice s1 1 2))
    "Extract slice of values from sequence")
(ok (equal? "<sequence<int<16,signed>>>" (class-name (sequence <sint>)))
    "Class name of 16-bit integer sequence")
(ok (equal? "#<sequence<int<16,signed>>>:\n(2 3 5)"
      (call-with-output-string (lambda (port) (write s1 port))))
    "Write lambda object")
(ok (equal? "#<sequence<int<16,signed>>>:\n(2 3 5)"
      (call-with-output-string (lambda (port) (display s1 port))))
    "Display lambda object")
(ok (equal? <ubyte> (typecode (list->sequence '(1 2 3))))
    "Typecode of converted list of unsigned bytes")
(ok (equal? <byte> (typecode (list->sequence '(1 -1))))
    "Typecode of converted list of signed bytes")
(ok (eqv? 3 (size (list->sequence '(1 2 3))))
    "Size of converted list")
(ok (equal? '(2 3 5) (begin (set s3 '(2 3 5)) (sequence->list s3)))
    "Assignment to sequence")
(ok (equal? '(2 3 5) (set s3 '(2 3 5)))
    "Return value of assignment to sequence")
(ok (equal? '(2 4 8) (sequence->list (list->sequence '(2 4 8))))
    "Content of converted list")
(ok (equal? (sequence <int>) (coerce <int> (sequence <sint>)))
    "Coercion of sequences")
(ok (equal? (sequence <int>) (coerce (sequence <int>) <byte>))
    "Coercion of sequences")
(ok (equal? (sequence <int>) (coerce (sequence <int>) (sequence <byte>)))
    "Coercion of sequences")
(ok (equal? "<multiarray<int<16,signed>>,2>" (class-name (sequence (sequence <sint>))))
    "Class name of 16-bit integer 2D array")
(ok (equal? (multiarray <sint> 2) (sequence (sequence (integer 16 signed))))
    "Multi-dimensional array is the same as a sequence of sequences")
(ok (null? (shape 1))
    "Shape of arbitrary object is empty list")
(ok (equal? '(3) (shape '(1 2 3)))
    "Shape of flat list")
(ok (equal? '(3 2) (shape '((1 2 3) (4 5 6))))
    "Shape of nested list")
(ok (equal? '(3 2) (shape (make (multiarray <int> 2) #:shape '(3 2))))
    "Query shape of multi-dimensional array")
(format #t "~&")
