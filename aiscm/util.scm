(define-module (aiscm util)
  #:use-module (oop goops)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-26)
  #:use-module (rnrs bytevectors)
  #:use-module (system foreign)
  #:export (toplevel-define! attach index all-but-last upto repeat depth
            flatten-n flatten cycle uncycle integral zipmap assoc-invert
            malloc destroy)
  #:export-syntax (def-once expand))
(define (toplevel-define! name val)
  (module-define! (current-module) name val))
(define-syntax-rule (def-once name value)
  (let [(sym (string->symbol name))]
    (if (not (defined? sym (current-module)))
      (toplevel-define! sym value))
    (primitive-eval sym)))
(define (attach lst x) (reverse (cons x (reverse lst))))
(define (index a b)
  (let [(tail (member a (reverse b)))]
    (if tail (length (cdr tail)) #f)))
(define (all-but-last lst) (reverse (cdr (reverse lst))))
(define (upto a b) (if (<= a b) (cons a (upto (1+ a) b)) '()))
(define (repeat x n) (if (zero? n) '() (cons x (repeat x (1- n)))))
(define-syntax-rule (expand n expr) (map (lambda (tmp) expr) (upto 1 n)))
(define (depth val)
  (if (list? val) (1+ (apply max (cons 0 (map depth val)))) 0))
(define (flatten-n val n)
  (if (> (depth val) n)
    (if (> (depth (car val)) (- n 1))
      (flatten-n (append (car val) (cdr val)) n)
      (cons (car val) (flatten-n (cdr val) n)))
    val))
(define (flatten val) (flatten-n val 1))
(define (cycle lst) (attach (cdr lst) (car lst)))
(define (uncycle lst) (cons (last lst) (all-but-last lst)))
(define (integral lst)
  (letrec [(accumulate (lambda (lst x)
                         (if (null? lst)
                           lst
                           (let [(xs (+ (car lst) x))]
                             (cons xs (accumulate (cdr lst) xs))))))]
    (accumulate lst 0)))
(define (zipmap keys vals)
  (if (or (null? keys) (null? vals))
    '()
    (cons (cons (car keys) (car vals)) (zipmap (cdr keys) (cdr vals)))))
(define (assoc-invert alist)
  (map (lambda (x) (cons (cdr x) (car x))) alist))
(define (malloc size)
  (bytevector->pointer (make-bytevector size)))
(define-generic destroy)
