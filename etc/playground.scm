(use-modules (oop goops)
             (srfi srfi-1)
             (srfi srfi-26)
             (system foreign)
             (aiscm element)
             (aiscm int)
             (aiscm sequence)
             (aiscm mem)
             (aiscm pointer)
             (aiscm rgb)
             (aiscm obj)
             (aiscm asm)
             (aiscm jit)
             (aiscm method)
             (aiscm util)
             (guile-tap))


; remove predefinitions where register is blocked
; add code for moving values

(define (blocked-predefined predefined intervals blocked)
  "Get blocked predefined registers"
  (filter (compose not null? (overlap-interval blocked) (cut assq-ref intervals <>) car) predefined))

(define (move-blocked-predefined blocked-predefined)
  "Generate code for blocked predefined variables"
  (map (compose MOV car+cdr) blocked-predefined))

(ok (null? (blocked-predefined '() '() '()))
    "no predefined variables")
(ok (equal? (list (cons 'a RDI))
            (blocked-predefined (list (cons 'a RDI)) '((a . (0 . 2))) (list (cons RDI '(1 . 3)))))
    "detect predefined variable with blocked register")
(ok (null? (blocked-predefined (list (cons 'a RDI)) '((a . (0 . 2))) '()))
    "ignore predefined variables if no registers are blocked")
(ok (null? (blocked-predefined (list (cons 'a RDI)) '((a . (0 . 2))) (list (cons RDI '(3 . 4)))))
    "ignore predefined variables if the associated register is not blocked")

(define a (var <int>))

(ok (null? (move-blocked-predefined '()))
    "no predefined variables with blocked registers to move")
(ok (equal? (list (MOV a RAX)) (move-blocked-predefined (list (cons a RAX))))
    "copy variable from blocked register")

(run-tests)
