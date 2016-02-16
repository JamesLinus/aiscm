(use-modules (srfi srfi-1)
             (oop goops)
             (rnrs bytevectors)
             (aiscm util)
             (guile-tap))
(planned-tests 57)
(toplevel-define! 'a 0)
(define-class* <test<>> <object> <meta<test<>>> <class>
  (t #:init-keyword #:t #:getter get-t))
(template-class (test 32) <test<>>)
(template-class (test 8) <test<>>
  (lambda (class metaclass)
    (define-method (tplus8 (self class)) (+ 8 (get-t self)))
    (define-method (is8? (self metaclass)) #t)))
(ok (eqv? 0 a)
    "'toplevel-define! should create a definition for the given symbol")
(ok (eq? <number> (super <complex>))
    "'super' returns the first direct superclass")
(ok (eq? <meta<test<>>> (class-of <test<>>))
    "'define-class*' should define class and meta-class")
(ok (eq? 42 (get-t (make <test<>> #:t 42)))
    "'define-class*' creates the specified slots")
(ok (eqv? 5 (toplevel-define! 'abc 5))
    "'toplevel-define! should return the value of the definition")
(ok (eq? <test<32>> (template-class (test 32) <test<>>))
    "retrieve template class by it's arguments")
(ok (eq? <meta<test<32>>> (class-of (template-class (test 32) <test<>>)))
    "meta class of template class")
(ok (equal? <test<>> (super (template-class (test 32) <test<>>)))
    "base class of template class")
(ok (equal? <meta<test<>>> (super (class-of (template-class (test 32) <test<>>))))
    "base class of meta class of template class")
(ok (eq? '<test<32>> (class-name <test<32>>))
    "class-name of template class")
(ok (eq? '<test<pair>> (class-name (template-class (test <pair>) <test<>>)))
    "class-name of template class with class arguments")
(ok (eq? '<test<32,pair>> (class-name (template-class (test 32 <pair>) <test<>>)))
    "class-name of template class with multiple arguments")
(ok (eqv? 42 (tplus8 (make <test<8>> #:t 34)))
    "template class can have methods")
(ok (is8? <test<8>>)
    "meta classes can have methods")
(ok (equal? '(1 2 3) (attach '(1 2) 3))
    "'attach' should add an element at the end of the list")
(ok (not (index-of 4 '(2 3 5 7)))
    "'index' returns #f if value is not element of list")
(ok (eqv? 2 (index-of 5 '(2 3 5 7)))
    "'index' returns index of first matching list element")
(ok (equal? '(2 3 5) (all-but-last '(2 3 5 7)))
    "'all-but-last' should return a list with the last element removed")
(ok (equal? '() (drop-up-to '(1 2 3) 4))
    "'drop-up-to' returns empty list if drop count is larger than length of list")
(ok (equal? '(5 6) (drop-up-to '(1 2 3 4 5 6) 4))
    "'drop-up-to' behaves like 'drop' otherwise")
(ok (equal? '(1 2 3) (take-up-to '(1 2 3 4 5) 3))
    "'take-up-to' returns first elements")
(ok (equal? '(1 2) (take-up-to '(1 2) 3))
    "'take-up-to' returns all elements if list is smaller")
(ok (equal? '(1 2 3 4) (flatten '(1 (2 3) ((4)))))
    "'flatten' flattens a list")
(ok (equal? '(2 3 4 1) (cycle '(1 2 3 4)))
    "'cycle' should cycle the elements of a list")
(ok (equal? '(4 1 2 3) (uncycle '(1 2 3 4)))
    "'uncycle' should reverse cycle the elements of a list")
(ok (equal? '(1 3 6 10) (integral '(1 2 3 4)))
    "'integral' should compute the accumulative sum of a list")
(ok (equal? '((1 . a) (2 . b)) (alist-invert '((a . 1) (b . 2))))
    "'alist-invert' should invert an association list")
(ok (equal? '((3 . c)) (assq-set '() 3 'c))
    "'assq-set' should work with empty association list")
(ok (equal? '((1 . a) (2 . b) (3 . c)) (assq-set '((1 . a) (2 . b)) 3 'c))
    "'assq-set' should append new associations")
(ok (equal? '((1 . a) (2 . c)) (assq-set '((1 . a) (2 . b)) 2 'c))
    "'assq-set' should override old associations")
(ok (equal? '((a . red) (c . blue))
            (assq-remove '((a . red) (b . green) (c . blue)) 'b))
    "'assq-remove' should remove entry with specified key")
(ok (equal? '((a . 1) (a . 2) (a . 3) (b . 1) (b . 2) (b . 3)) (product '(a b) '(1 2 3)))
    "'product' should create a product set of two lists")
(ok (equal? '((a . 1) (b . 2) (c . 3)) (sort-by '((c . 3) (a . 1) (b . 2)) cdr))
    "'sort-by' should sort arguments by the values of the supplied function")
(ok (equal? '(1 3 5 0 2 4) (sort-by-pred (iota 6) even?))
    "'sort-by-pred' sorts by boolean result of predicate")
(ok (equal? '(a . 1) (argmin cdr '((c . 3) (a . 1) (b . 2))))
    "Get element with minimum of argument")
(ok (equal? '(c . 3) (argmax cdr '((c . 3) (a . 1) (b . 2))))
    "Get element with maximum of argument")
(ok (equal? '((0 1) (2 3 4) (5 6 7 8 9)) (gather '(2 3 5) (iota 10)))
    "'gather' groups elements into groups of specified size")
(ok (< (abs (- (sqrt 2)
               (fixed-point 1
                            (lambda (x) (* 0.5 (+ (/ 2 x) x)))
                            (lambda (a b) (< (abs (- a b)) 1e-5)))))
       1e-5)
    "Fixed point iteration")
(ok (lset= eqv? '(1 2 3) (union '(1 2) '(2 3)))
    "'union' should merge two sets")
(ok (lset= eqv? '(1) (difference '(1 2) '(2 3)))
    "'difference' should return the set difference")
(ok (equal? '(a b) (pair->list '(a . b)))
    "Convert pair to list")
(ok (lset= equal?
           '((a . (0 . 1)) (b . (1 . 2)) (c . (2 . 2)))
           (live-intervals '((a) (a b) (b c) ()) '(a b c)))
    "Determine live intervals")
(ok (equal? '((a b) (a b c) (b c))
            (map (overlap '((a . (0 . 1)) (b . (1 . 2)) (c . (2 . 2)))) '(a b c)))
    "Determine overlap of live intervals")
(ok (equal? '((a . green) (b . red) (c . green) (d . red))
            (color-intervals '((a . (0 . 1)) (b . (1 . 2)) (c . (2 . 3)) (d . (3 . 3)))
                             '(a b c d) '(red green blue)))
    "'color-intervals' should color overlapping intervals differently")
(ok (equal? '((a . red) (b . green) (c . red) (d . blue))
            (color-intervals '((a . (0 . 1)) (b . (1 . 2)) (c . (2 . 3)) (d . (3 . 3)))
                             '(a b c)
                             '(red green blue)
                             #:predefined '((d . blue))))
    "'color-intervals' should respect predefined colors")
(ok (equal? '((a . #f) (b . red))
            (color-intervals '((a . (0 . 0)) (b . (0 . 0))) '(a b) '(red)))
    "'color-intervals' should bind variables to false when running out of registers")
(ok (equal? '((a . green) (b . red))
            (color-intervals '((a . (0 . 0)) (b . (1 . 1)))
                             '(a b)
                             '(red green)
                             #:blocked '((red . (0 . 0)))))
    "'color-intervals' should respect blocked registers")
(ok (equal? 2 (first-index (lambda (x) (> x 4)) '(2 3 5 7 0)))
    "Return index of first element for given predicate")
(ok (not (first-index (lambda (x) (> x 7)) '(2 3 5 7 0)))
    "Return false if there is no element for given predicate")
(ok (equal? 3 (last-index (lambda (x) (> x 4)) '(2 3 5 7 0)))
    "Return index of last element for given predicate")
(ok (not (last-index (lambda (x) (> x 7)) '(2 3 5 7 0)))
    "Return false if there is no element for given predicate")
(ok (equal? '(1 2 3) (compact 1 2 #f 3 #f))
    "Remove false elements from arguments")
(ok (equal? '((0 . 0) (1 . 2) (3 . 5) (6 . 6)) (index-groups '((x) (x x) (x x x) (x))))
    "Get index ranges for list of lists")
(ok (equal? '((a 0 . 0) (b 3 . 6))
            (update-intervals '((a 0 . 0) (b 2 . 3)) '((0 . 0) (1 . 2) (3 . 5) (6 . 6))))
    "Enlarging intervals according to list of consecutive ranges")
(ok (equal? #vu8(3 5) (bytevector-sub #vu8(2 3 5 7 11) 1 2))
    "Extract part of byte vector")
(ok (equal? #vu8(2 3 5 7 11 13) (bytevector-concat (list #vu8(2 3) #vu8(5 7 11) #vu8(13))))
    "concatenate byte vectors")
(ok (equal? '(1 -2 3 -4 5) (map-if even? - + '(1 2 3 4 5)))
    "conditional map")
