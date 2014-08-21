(define-module (aiscm op)
  #:use-module (oop goops)
  #:use-module (srfi srfi-1)
  #:use-module (aiscm util)
  #:use-module (aiscm jit)
  #:use-module (aiscm mem)
  #:use-module (aiscm element)
  #:use-module (aiscm pointer)
  #:use-module (aiscm int)
  #:use-module (aiscm sequence)
  #:export (fill)
  #:re-export (+ -))
(define ctx (make <jit-context>))

(define-method (unary-op (fun <jit-function>) (r_ <element>) (a_ <element>) op)
  (env fun
       [(r (reg (get-value r_) fun))
        (a (reg (get-value a_) fun))]
         (MOV r a)
         (op r)))
(define-method (unary-op (fun <jit-function>) (r_ <pointer<>>) (a_ <pointer<>>) op)
  (env fun
       [(*r (reg (get-value r_) fun))
        (*a (reg (get-value a_) fun))
        (r  (reg (typecode r_) fun))]
         (MOV r (ptr (typecode a_) *a))
         (op r)
         (MOV (ptr (typecode r_) *r) r)))
(define-method (unary-op (fun <jit-function>) (r_ <sequence<>>) (a_ <sequence<>>) op)
  (env fun
       [(r+  (reg (last (strides r_)) fun))
        (n   (reg (last (shape r_)) fun))
        (a+  (reg (last (strides a_)) fun))
        (*r  (reg <long> fun))
        (*a  (reg <long> fun))
        (*rx (reg <long> fun))]
       (IMUL n r+)
       (MOV *r (loc (get-value r_) fun))
       (MOV *a (loc (get-value a_) fun))
       (LEA *rx (ptr (typecode r_) *r n))
       (IMUL r+ r+ (size-of (typecode r_)))
       (IMUL a+ a+ (size-of (typecode a_)))
       (CMP *r *rx)
       (JE 'return)
       'loop
       (unary-op fun (project (rebase *r r_)) (project (rebase *a a_)) op)
       (ADD *r r+)
       (ADD *a a+)
       (CMP *r *rx)
       (JNE 'loop)
       'return))

(define-method (binary-op (fun <jit-function>) (r_ <element>) (a_ <element>) (b_ <element>) op)
  (env fun
       [(r  (reg (get-value r_) fun))
        (a  (reg (get-value a_) fun))
        (b  (reg (get-value b_) fun))
        (w  (reg (class-of r_) fun))]
       ((if (eqv? (size-of (class-of a_)) (size-of (class-of r_)))
          MOV
          (if (signed? (class-of a_)) MOVSX MOVZX)) r a)
       (if (eqv? (size-of (class-of b_)) (size-of (class-of r_)))
         (op r b)
         (append
           ((if (signed? (class-of b_)) MOVSX MOVZX) w b)
           (op r w)))))
(define-method (binary-op (fun <jit-function>) (r_ <pointer<>>) (a_ <pointer<>>) (b_ <element>) op)
  (env fun
       [(*r (reg (get-value r_) fun))
        (*a (reg (get-value a_) fun))
        (b  (reg (get-value b_) fun))
        (r  (reg (typecode r_) fun))
        (w  (reg (typecode r_) fun))]
       ((if (eqv? (size-of (typecode a_)) (size-of (typecode r_)))
          MOV
          (if (signed? (typecode a_)) MOVSX MOVZX)) r (ptr (typecode a_) *a))
       (if (eqv? (size-of (class-of b_)) (size-of (typecode r_)))
         (op r b)
         (append
           ((if (signed? (class-of b_)) MOVSX MOVZX) w b)
           (op r w)))
       (MOV (ptr (typecode r_) *r) r)))
(define-method (binary-op (fun <jit-function>) (r_ <pointer<>>) (a_ <element>) (b_ <pointer<>>) op)
   (env fun
       [(*r (reg (get-value r_) fun))
        (a  (reg (get-value a_) fun))
        (*b (reg (get-value b_) fun))
        (r  (reg (typecode r_) fun))
        (w  (reg (typecode r_) fun))]
       ((if (eqv? (size-of (class-of a_)) (size-of (typecode r_)))
          MOV
          (if (signed? (class-of a_)) MOVSX MOVZX)) r a)
       (if (eqv? (size-of (typecode b_)) (size-of (typecode r_)))
         (op r (ptr (typecode b_) *b))
         (append
           ((if (signed? (typecode b_)) MOVSX MOVZX) w (ptr (typecode b_) *b))
           (op r w)))
       (MOV (ptr (typecode r_) *r) r)))
(define-method (binary-op (fun <jit-function>) (r_ <pointer<>>) (a_ <pointer<>>) (b_ <pointer<>>) op)
  (env fun
       [(*r (reg (get-value r_) fun))
        (*a (reg (get-value a_) fun))
        (*b (reg (get-value b_) fun))
        (r  (reg (typecode r_) fun))
        (w  (reg (typecode r_) fun))]
       ((if (eqv? (size-of (typecode a_)) (size-of (typecode r_)))
          MOV
          (if (signed? (typecode a_)) MOVSX MOVZX)) r (ptr (typecode a_) *a))
       (if (eqv? (size-of (typecode b_)) (size-of (typecode r_)))
         (op r (ptr (typecode b_) *b))
         (append
           ((if (signed? (typecode b_)) MOVSX MOVZX) w (ptr (typecode b_) *b))
           (op r w)))
       (MOV (ptr (typecode r_) *r) r)))
(define-method (binary-op (fun <jit-function>) (r_ <sequence<>>) (a_ <sequence<>>) (b_ <element>) op)
  (env fun
       [(r+  (reg (last (strides r_)) fun))
        (n   (reg (last (shape r_)) fun))
        (a+  (reg (last (strides a_)) fun))
        (*r  (reg <long> fun))
        (*a  (reg <long> fun))
        (*rx (reg <long> fun))]
       (IMUL n r+)
       (MOV *r (loc (get-value r_) fun))
       (MOV *a (loc (get-value a_) fun))
       (LEA *rx (ptr (typecode r_) *r n))
       (IMUL r+ r+ (size-of (typecode r_)))
       (IMUL a+ a+ (size-of (typecode a_)))
       (CMP *r *rx)
       (JE 'return)
       'loop
       (binary-op fun (project (rebase *r r_)) (project (rebase *a a_)) b_ op)
       (ADD *r r+)
       (ADD *a a+)
       (CMP *r *rx)
       (JNE 'loop)
       'return))
(define-method (binary-op (fun <jit-function>) (r_ <sequence<>>) (a_ <element>) (b_ <sequence<>>) op)
  (env fun
       [(r+  (reg (last (strides r_)) fun))
        (n   (reg (last (shape r_)) fun))
        (a   (reg (get-value a_) fun))
        (b+  (reg (last (strides b_)) fun))
        (*r  (reg <long> fun))
        (*b  (reg <long> fun))
        (*rx (reg <long> fun))]
       (IMUL n r+)
       (MOV *r (loc (get-value r_) fun))
       (MOV *b (loc (get-value b_) fun))
       (LEA *rx (ptr (typecode r_) *r n))
       (IMUL r+ r+ (size-of (typecode r_)))
       (IMUL b+ b+ (size-of (typecode b_)))
       (CMP *r *rx)
       (JE 'return)
       'loop
       (binary-op fun (project (rebase *r r_)) a_ (project (rebase *b b_)) op)
       (ADD *r r+)
       (ADD *b b+)
       (CMP *r *rx)
       (JNE 'loop)
       'return))
(define-method (binary-op (fun <jit-function>) (r_ <sequence<>>) (a_ <sequence<>>) (b_ <sequence<>>) op)
  (env fun
       [(r+  (reg (last (strides r_)) fun))
        (a+  (reg (last (strides a_)) fun))
        (b+  (reg (last (strides b_)) fun))
        (n   (reg (last (shape r_)) fun))
        (*r  (reg <long> fun))
        (*a  (reg <long> fun))
        (*b  (reg <long> fun))
        (*rx (reg <long> fun))]
       (IMUL n r+)
       (MOV *r (loc (get-value r_) fun))
       (MOV *a (loc (get-value a_) fun))
       (MOV *b (loc (get-value b_) fun))
       (LEA *rx (ptr (typecode r_) *r n))
       (IMUL r+ r+ (size-of (typecode r_)))
       (IMUL a+ a+ (size-of (typecode a_)))
       (IMUL b+ b+ (size-of (typecode b_)))
       (CMP *r *rx)
       (JE 'return)
       'loop
       (binary-op fun (project (rebase *r r_)) (project (rebase *a a_)) (project (rebase *b b_)) op)
       (ADD *r r+)
       (ADD *a a+)
       (ADD *b b+)
       (CMP *r *rx)
       (JNE 'loop)
       'return))

(define-syntax-rule (define-unary-op name op)
  (define-method (name (a <element>))
    (add-method! name (jit-wrap ctx
                                (class-of a)
                                ((class-of a))
                                (lambda (fun r_ a_) (unary-op fun r_ a_ op))))
    (name a)))

(define-syntax-rule (define-binary-op name op)
  (begin
    (define-method (name (a <element>) (b <element>))
      (add-method! name (jit-wrap ctx
                                  (coerce (class-of a) (class-of b))
                                  ((class-of a) (class-of b))
                                  (lambda (fun r_ a_ b_) (binary-op fun r_ a_ b_ op))))
      (name a b))
    (define-method (name (a <element>) (b <integer>))
      (name a (make (match b) #:value b)))
    (define-method (name (a <integer>) (b <element>))
      (name (make (match a) #:value a) b))))

(define-method (+ (a <element>)) a)
(define-unary-op - NEG)

(define-binary-op + ADD)
(define-binary-op - SUB)

(define (fill t n value); TODO: replace with tensor operation
  (let [(retval (make (sequence t) #:size n))]
    (store retval value)
    retval))
