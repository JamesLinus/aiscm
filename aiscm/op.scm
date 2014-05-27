(define-module (aiscm op)
  #:use-module (oop goops)
  #:use-module (system foreign)
  #:use-module (aiscm mem)
  #:use-module (aiscm jit)
  #:use-module (aiscm element)
  #:use-module (aiscm int)
  #:use-module (aiscm sequence)
  #:export (fill)
  #:re-export (+ -))
(define ctx (make <jit-context>))
(define-method (fill (t <meta<element>>) (n <integer>) value)
  (let* [(tr    (sequence t))
         (step  (storage-size (typecode tr)))
         (scale (assq-ref (list (cons 1 *1) (cons 2 *2) (cons 4  *4) (cons 8 *8)) step))
         (ptr   (assq-ref (list (cons 1 byte-ptr) (cons 2 word-ptr) (cons 4 dword-ptr) (cons 8 qword-ptr)) step))
         (dx    (assq-ref (list (cons 1 DL) (cons 2 DX) (cons 4 EDX) (cons 8 RDX)) step))
         (code  (asm ctx void (list (LEA RCX (ptr RDI RSI scale))
                                    (CMP RDI RCX)
                                    (JE 'ret)
                                    'loop
                                    (MOV (ptr RDI) dx)
                                    (ADD RDI step)
                                    (CMP RDI RCX)
                                    (JNE 'loop)
                                    'ret
                                    (RET))
                     int64 int int))
         (proc  (lambda (t n value)
                  (let* [(r  (make tr #:size n))
                         (pr ((compose pointer-address get-memory get-value get-value) r))]
                    (code pr n value)
                    r)))]
    (add-method! fill (make <method>
                            #:specializers (list (class-of t) <integer> (class-of value))
                            #:procedure proc))
    (fill t n value)))
(define-method (+ (a <element>)) a)
(define-method (+ (a <element>) (b <element>))
  (let* [(ta     (class-of a))
         (tb     (class-of b))
         (tr     (coerce ta tb))
         (fta    (foreign-type ta))
         (ftb    (foreign-type tb))
         (ftr    (foreign-type tr))
         (ax     (assq-ref (list (cons 8  AL) (cons 16 AX) (cons 32 EAX) (cons 64 RAX)) (bits tr)))
         (di     (assq-ref (list (cons 8 DIL) (cons 16 DI) (cons 32 EDI) (cons 64 RDI)) (bits tr)))
         (si     (assq-ref (list (cons 8 SIL) (cons 16 SI) (cons 32 ESI) (cons 64 RSI)) (bits tr)))
         (code   (asm ctx ftr (list (MOV ax di) (ADD ax si) (RET)) fta ftb))
         (proc   (lambda (a b) (make tr #:value (code (get-value a) (get-value b)))))]
    (add-method! + (make <method>
                         #:specializers (list ta tb)
                         #:procedure proc))
    (+ a b)))
(define-method (+ (a <element>) (b <integer>))
  (+ a (make (match b) #:value b)))
(define-method (+ (a <integer>) (b <element>))
  (+ (make (match a) #:value a) b))
(define-method (+ (a <sequence<>>) (b <element>))
  (let* [(ta    (class-of a))
         (tb    (class-of b))
         (tr    (coerce ta tb))
         (ftb   (foreign-type tb))
         (stepa (storage-size (typecode ta)))
         (stepr (storage-size (typecode tr)))
         (mova  (if (eq? (typecode ta) (typecode tr)) MOV (if (signed? (typecode ta)) MOVSX MOVZX)))
         (scale (assq-ref (list (cons 1 *1) (cons 2 *2) (cons 4  *4) (cons 8 *8)) stepr))
         (aptr  (assq-ref (list (cons 1 byte-ptr) (cons 2 word-ptr) (cons 4 dword-ptr) (cons 8 qword-ptr)) stepa))
         (rptr  (assq-ref (list (cons 1 byte-ptr) (cons 2 word-ptr) (cons 4 dword-ptr) (cons 8 qword-ptr)) stepr))
         (axa   (assq-ref (list (cons 1 AL) (cons 2 AX) (cons 4 EAX) (cons 8 RAX)) stepa))
         (axr   (assq-ref (list (cons 1 AL) (cons 2 AX) (cons 4 EAX) (cons 8 RAX)) stepr))
         (dx    (assq-ref (list (cons 8 DL) (cons 16 DX) (cons 32 EDX) (cons 64 RDX)) (bits (typecode tr))))
         (code  (asm ctx void (list (LEA R8 (rptr RDI RCX scale))
                                    (CMP RDI R8)
                                    (JE 'ret)
                                    'loop
                                    (mova axr (aptr RSI))
                                    (ADD axr dx)
                                    (MOV (rptr RDI) axr)
                                    (ADD RDI stepr)
                                    (ADD RSI stepa)
                                    (CMP R8 RDI)
                                    (JNE 'loop)
                                    'ret
                                    (RET)) int64 int64 ftb int))
         (proc  (lambda (a b)
                  (let* [(n (get-size a))
                         (r (make tr #:size n))
                         (pr ((compose pointer-address get-memory get-value get-value) r))
                         (pa ((compose pointer-address get-memory get-value get-value) a))]
                    (code pr pa (get-value b) n)
                    r)))]
    (add-method! + (make <method>
                         #:specializers (list ta tb)
                         #:procedure proc))
    (+ a b)))
(define-method (+ (a <element>) (b <sequence<>>))
  (let* [(ta    (class-of a))
         (tb    (class-of b))
         (tr    (coerce ta tb))
         (fta   (foreign-type ta))
         (stepb (storage-size (typecode tb)))
         (stepr (storage-size (typecode tr)))
         (movb  (if (eq? (typecode tb) (typecode tr)) MOV (if (signed? (typecode tb)) MOVSX MOVZX)))
         (scale (assq-ref (list (cons 1 *1) (cons 2 *2) (cons 4  *4) (cons 8 *8)) stepr))
         (bptr  (assq-ref (list (cons 1 byte-ptr) (cons 2 word-ptr) (cons 4 dword-ptr) (cons 8 qword-ptr)) stepb))
         (rptr  (assq-ref (list (cons 1 byte-ptr) (cons 2 word-ptr) (cons 4 dword-ptr) (cons 8 qword-ptr)) stepr))
         (axb   (assq-ref (list (cons 1 AL) (cons 2 AX) (cons 4 EAX) (cons 8 RAX)) stepb))
         (axr   (assq-ref (list (cons 1 AL) (cons 2 AX) (cons 4 EAX) (cons 8 RAX)) stepr))
         (si    (assq-ref (list (cons 8 SIL) (cons 16 SI) (cons 32 ESI) (cons 64 RSI)) (bits (typecode tr))))
         (code  (asm ctx void (list (LEA R8 (rptr RDI RCX scale))
                                    (CMP RDI R8)
                                    (JE 'ret)
                                    'loop
                                    (movb axr (bptr RDX))
                                    (ADD axr si)
                                    (MOV (rptr RDI) axr)
                                    (ADD RDI stepr)
                                    (ADD RDX stepb)
                                    (CMP R8 RDI)
                                    (JNE 'loop)
                                    'ret
                                    (RET)) int64 fta int64 int))
         (proc  (lambda (a b)
                  (let* [(n  (get-size b))
                         (r  (make tr #:size n))
                         (pr ((compose pointer-address get-memory get-value get-value) r))
                         (pb ((compose pointer-address get-memory get-value get-value) b))]
                    (code pr (get-value a) pb n)
                    r)))]
    (add-method! + (make <method>
                         #:specializers (list ta tb)
                         #:procedure proc))
    (+ a b)))
(define-method (+ (a <sequence<>>) (b <sequence<>>))
  (let* [(ta    (class-of a))
         (tb    (class-of b))
         (tr    (coerce ta tb))
         (stepa (storage-size (typecode ta)))
         (stepb (storage-size (typecode tb)))
         (stepr (storage-size (typecode tr)))
         (scale (assq-ref (list (cons 1 *1) (cons 2 *2) (cons 4  *4) (cons 8 *8)) stepr))
         (mova  (if (eq? (typecode ta) (typecode tr)) MOV (if (signed? (typecode ta)) MOVSX MOVZX)))
         (aptr  (assq-ref (list (cons 1 byte-ptr) (cons 2 word-ptr) (cons 4 dword-ptr) (cons 8 qword-ptr)) stepa))
         (bptr  (assq-ref (list (cons 1 byte-ptr) (cons 2 word-ptr) (cons 4 dword-ptr) (cons 8 qword-ptr)) stepb))
         (rptr  (assq-ref (list (cons 1 byte-ptr) (cons 2 word-ptr) (cons 4 dword-ptr) (cons 8 qword-ptr)) stepr))
         (axa   (assq-ref (list (cons 1 AL) (cons 2 AX) (cons 4 EAX) (cons 8 RAX)) stepa))
         (axr   (assq-ref (list (cons 1 AL) (cons 2 AX) (cons 4 EAX) (cons 8 RAX)) stepr))
         (bxr   (assq-ref (list (cons 1 BL) (cons 2 BX) (cons 4 EBX) (cons 8 RBX)) stepr))
         (code  (asm ctx void (list (LEA R8 (rptr RDI RCX scale))
                                    (CMP RDI R8)
                                    (JE 'ret)
                                    'loop
                                    (mova axr (aptr RSI))
                                    (if (eq? (typecode tb) (typecode tr))
                                      (ADD axr (bptr RDX))
                                      (append
                                        ((if (signed? (typecode tb)) MOVSX MOVZX) bxr (bptr RDX))
                                        (ADD axr bxr)))
                                    (MOV (rptr RDI) axr)
                                    (ADD RDI stepr)
                                    (ADD RSI stepa)
                                    (ADD RDX stepb)
                                    (CMP R8 RDI)
                                    (JNE 'loop)
                                    'ret
                                    (RET)) int64 int64 int64 int))
         (proc  (lambda (a b)
                  (let* [(na (get-size a)); TODO: size check
                         (nb (get-size b))
                         (r  (make tr #:size na))
                         (pr ((compose pointer-address get-memory get-value get-value) r))
                         (pa ((compose pointer-address get-memory get-value get-value) a))
                         (pb ((compose pointer-address get-memory get-value get-value) b))]
                    (if (not (= na nb)) (throw 'array-dimensions-different na nb))
                    (code pr pa pb na)
                    r)))]
    (add-method! + (make <method>
                         #:specializers (list ta tb)
                         #:procedure proc))
    (+ a b)))
(define-method (- (a <element>))
  (let* [(t      (class-of a))
         (ft     (foreign-type t))
         (ax     (if (eqv? (bits t) 64) RAX EAX))
         (di     (if (eqv? (bits t) 64) RDI EDI))
         (code   (asm ctx ft (list (MOV ax di) (NEG ax) (RET)) ft))
         (proc   (lambda (a) (make t #:value (code (get-value a)))))]
    (add-method! - (make <method>
                         #:specializers (list t)
                         #:procedure proc))
    (- a)))
(define-method (- (a <sequence<>>))
  (let* [(ta    (class-of a))
         (tr    ta)
         (step  (storage-size (typecode tr)))
         (scale (assq-ref (list (cons 1 *1) (cons 2 *2) (cons 4  *4) (cons 8 *8)) step))
         (ptr   (assq-ref (list (cons 1 byte-ptr) (cons 2 word-ptr) (cons 4 dword-ptr) (cons 8 qword-ptr)) step))
         (ax    (assq-ref (list (cons 1 AL) (cons 2 AX) (cons 4 EAX) (cons 8 RAX)) step))
         (code  (asm ctx void (list (LEA RCX (ptr RDI RDX scale))
                                    (CMP RDI RCX)
                                    (JE 'ret)
                                    'loop
                                    (MOV ax (ptr RSI))
                                    (NEG ax)
                                    (MOV (ptr RDI) ax)
                                    (ADD RDI step)
                                    (ADD RSI step)
                                    (CMP RCX RDI)
                                    (JNE 'loop)
                                    'ret
                                    (RET)) int64 int64 int))
         (proc (lambda (a)
                 (let* [(n  (get-size a))
                        (r  (make tr #:size n))
                        (pr ((compose pointer-address get-memory get-value get-value) r))
                        (pa ((compose pointer-address get-memory get-value get-value) a))]
                   (code pr pa n)
                   r)))]
    (add-method! - (make <method>
                         #:specializers (list ta)
                         #:procedure proc))
    (- a)))
(define-method (- (a <element>) (b <element>))
  (let* [(ta     (class-of a))
         (tb     (class-of b))
         (tr     (coerce ta tb))
         (fta    (foreign-type ta))
         (ftb    (foreign-type tb))
         (ftr    (foreign-type tr))
         (ax     (assq-ref (list (cons 8  AL) (cons 16 AX) (cons 32 EAX) (cons 64 RAX)) (bits tr)))
         (di     (assq-ref (list (cons 8 DIL) (cons 16 DI) (cons 32 EDI) (cons 64 RDI)) (bits tr)))
         (si     (assq-ref (list (cons 8 SIL) (cons 16 SI) (cons 32 ESI) (cons 64 RSI)) (bits tr)))
         (code   (asm ctx ftr (list (MOV ax di) (SUB ax si) (RET)) fta ftb))
         (proc   (lambda (a b) (make tr #:value (code (get-value a) (get-value b)))))]
    (add-method! - (make <method>
                         #:specializers (list ta tb)
                         #:procedure proc))
    (- a b)))
(define-method (- (a <element>) (b <integer>))
  (- a (make (match b) #:value b)))
(define-method (- (a <integer>) (b <element>))
  (- (make (match a) #:value a) b))
