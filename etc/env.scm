(use-modules (oop goops) (srfi srfi-1) (srfi srfi-26) (ice-9 optargs) (ice-9 curried-definitions) (aiscm util) (aiscm element) (aiscm pointer) (aiscm mem) (aiscm sequence) (aiscm asm) (aiscm jit) (aiscm op) (aiscm int) (aiscm float) (aiscm rgb))

(define ctx (make <context>))

(define-method (red (frag <fragment<rgb<>>>))
  (let [(tmp (skel (type frag)))]
    (make (fragment (base (type frag)))
          #:args (list frag)
          #:name red
          #:code (lambda (result) (MOV result (red tmp))))))

((jit ctx (list <bytergb>) red) (rgb 1 2 3))


; macros: (jit-method [(x <int>) (y <float>)] (+ x y))

;(define-syntax let-vars
;  (syntax-rules ()
;    ((let-vars [(name type) vars ...] body ...)
;     (let [(name (make <var> #:type type #:symbol (quote name)))]
;       (let-vars [vars ...] body ...)))
;    ((let-vars [] body ...)
;     (begin body ...))))


(define-syntax test
  (syntax-rules ()
    ((test ((a b) args ...))
     (cons b (test (args ...))))
    ((test  ())
     '())))

(define-syntax tensor-list
  (syntax-rules ()
    ((_ arg args ...) (cons (tensor arg) (tensor-list args ...)))
    ((_) '())))

(define-syntax tensor
  (syntax-rules (*)
    ((_ (* args ...)) (cons '* (tensor-list args ...)))
    ((_ arg)          arg)))

(define s (seq 1 2 3 4))
(define-syntax-rule (tensor sym args ...)
  (if (is-a? sym <element>) (get sym args ...) (sym args ...)))
(tensor + s 1)
(tensor s 1)
(tensor (seq 1 2 3 4) 1)
(tensor + (s 1) 1)

; arrays
(make-array 0 2 3)
(make-typed-array 'u8 0 2 3)
#vu8(1 2 3)
#2((1 2 3) (4 5 6))

#2u32((1 2 3) (4 5 6))
(define m #2s8((1 -2 3) (4 5 6)))
(array-ref m 1 0)
(array-shape m)
(array-dimensions m)
(array-rank m)
(array->list m)

; monkey patching
(class-slots <x>)
(define m (car (generic-function-methods test)))
((method-procedure m) x)
(slot-ref test 'methods)
;(sort-applicable-methods test (compute-applicable-methods test (list x)) (list x))
(equal? (map class-of (list x)) (method-specializers m))
(define x (make <x>))
(test x)
(define-method (test (x <x>)) 'test2)
(test x)
