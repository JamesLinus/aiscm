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

(define (partial-sort lst less)
  "Sort the list LST. LESS is a partial order used for comparing elements."
  (if (null? lst)
      '()
      (if (every (compose not (cut less <> (car lst))) (cdr lst))
          (cons (car lst) (partial-sort (cdr lst) less))
          (partial-sort (cycle lst) less))))

(define (need-to-copy-first initial targets a b)
  "Check whether parameter A needs to be copied before B given INITIAL and TARGETS locations"
  (eq? (assq-ref initial a) (assq-ref targets b)))

(define (update-parameter-locations parameters locations offset)
  "Generate the required code to update the parameter locations according to the register allocation"
  (let* [(initial            (parameter-locations parameters offset))
         (ordered-parameters (partial-sort parameters (cut need-to-copy-first initial locations <...>)))]
    (apply compact
      (map (lambda (parameter)
             (let [(source (assq-ref initial parameter))
                   (destination (assq-ref locations parameter))
                   (adapt (cut to-type (typecode parameter) <>))]
               (and destination (not (equal? source destination)) (MOV (adapt destination) (adapt source)))))
           ordered-parameters))))

(ok (null? (partial-sort '() <))
    "partial sorting of empty list")
(ok (equal? '(2 3) (partial-sort '(2 3) <))
    "list of integers already sorted")
(ok (equal? '(3 5) (partial-sort '(5 3) <))
    "order list of two integers")
(ok (equal? '(5 5) (partial-sort '(5 5) <))
    "order list of two equal integers")
(ok (equal? '(7 3) (partial-sort '(7 3) (const #f)))
    "return items if order is not defined")
(ok (equal? '(3 1 2) (partial-sort '(1 2 3) (lambda (x y) (eqv? x 3))))
    "perform partial ordering")

(ok (not (need-to-copy-first (list (cons 'a RSI) (cons 'b RDX)) (list (cons 'a RAX) (cons 'b RCX)) 'a 'b))
    "no need to copy RSI to RAX before RDX to RCX")
(ok (need-to-copy-first (list (cons 'a RSI) (cons 'b RDX)) (list (cons 'a RAX) (cons 'b RSI)) 'a 'b)
    "RSI needs to be copied to RAX before copying RDX to RSI")

(define a (var <int>))
(define b (var <int>))
(define c (var <int>))
(define d (var <int>))
(define e (var <int>))
(define f (var <int>))
(define g (var <int>))
(define r (var <int>))

(let [(a (var <int>))
      (b (var <int>))
      (c (var <int>))
      (d (var <int>))
      (e (var <int>))
      (f (var <int>))
      (g (var <int>))
      (r (var <int>))]
  (ok (null? (update-parameter-locations '() '() 0))
      "no parameters to move arround")
  (ok (equal? (list (MOV (ptr <int> RSP -8) EDI))
              (update-parameter-locations (list a) (list (cons a (ptr <long> RSP -8))) 0))
      "spill a register parameter")
  (ok (null? (update-parameter-locations (list a) '() 0))
      "ignore parameters which are not used")
  (diagnostics "load a stack parameter")
  (ok (equal? (list (MOV EAX (ptr <int> RSP 8)))
              (update-parameter-locations (list a b c d e f g)
                                          (map cons (list a b c d e f g) (list RDI RSI RDX RCX R8 R9 RAX))
                                          0))
      "load a stack parameter")
  (ok (equal? (list (MOV EAX (ptr <int> RSP 24)))
              (update-parameter-locations (list a b c d e f g)
                                          (map cons (list a b c d e f g) (list RDI RSI RDX RCX R8 R9 RAX))
                                          16))
      "load a stack parameter taking into account the stack pointer offset")
  (ok (null? (update-parameter-locations (list a b c d e f g)
                                         (map cons (list a b c d e f g) (list RDI RSI RDX RCX R8 R9 (ptr <long> RSP 24)))
                                         16))
      "leave parameter on stack")

  (ok (equal? (list (MOV EAX ESI) (MOV ESI EDI))
              (update-parameter-locations (list a b) (map cons (list a b) (list RSI RAX)) 0))
      "adjust order of copy operations to avoid overwriting parameters"))

(run-tests)
