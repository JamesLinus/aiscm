(use-modules (oop goops)
             (rnrs bytevectors)
             (srfi srfi-1)
             (srfi srfi-26)
             (aiscm util)
             (aiscm asm)
             (aiscm mem)
             (aiscm jit)
             (aiscm element)
             (aiscm int)
             (aiscm pointer)
             (aiscm sequence)
             (aiscm bool)
             (aiscm rgb)
             (aiscm complex)
             (guile-tap))
(define ctx (make <context>))
(ok (equal? '(6 9 15) (to-list (* (seq 2 3 5) 3)))
    "multiply sequence with a number")
(let [(s (var <int>))
      (u (var <uint>))
      (n (var <byte>))]
  (ok (equal? RCX (get-reg (shl s n)))
      "shl blocks RCX register")
  (ok (equal? (list (mov-unsigned CL n) (SHL u CL)) (filter-blocks (shl u n)))
      "shl uses SHL for unsigned input")
  (ok (equal? (list (mov-unsigned CL n) (SAL s CL)) (filter-blocks (shl s n)))
      "shl uses SAL for signed input")
  (ok (equal? (list (mov-unsigned CL n) (SHR u CL)) (filter-blocks (shr u n)))
      "shl uses SHR for unsigned input")
  (ok (equal? (list (mov-unsigned CL n) (SAR s CL)) (filter-blocks (shr s n)))
      "shl uses SAR for signed input"))
(ok (equal? '(2 4 6) (to-list (<< (seq 1 2 3) 1)))
    "left-shift sequence")
(ok (equal? '(1 2 3) (to-list (>> (seq 4 8 12) 2)))
    "right-shift sequence")
(ok (equal? '(1 4) (to-list (duplicate (project (roll (arr (1 2 3) (4 5 6)))))))
    "'duplicate' creates copy of slice")
(ok (let [(m (make (multiarray <int> 2) #:shape '(6 4)))] (eq? m (ensure-default-strides m)))
    "'ensure-default-strides' should do nothing by default")
(ok (let [(m (make (multiarray <int> 2) #:shape '(6 4)))] (equal? '(1 4) (strides (ensure-default-strides (roll m)))))
    "'ensure-default-strides' should create a compact clone if the input is not contiguous")
(ok (equal? '(3 0 1) (to-list (& (seq 3 4 5) 3)))
    "element-wise bit-wise and")
(ok (equal? '(3 7 7) (to-list (| 3 (seq 3 4 5))))
    "element-wise bit-wise or")
(ok (equal? '(1 7 1) (to-list (^ (seq 2 3 4) (seq 3 4 5))))
    "element-wise bit-wise xor")
(let [(a (var <int>))
      (r (var <bool>))]
  (ok (equal? (list (TEST a a) (SETE r)) (test-zero r a))
      "generate code for comparing with zero"))
(ok (eq? <int> (to-type <int> <byte>))
    "typecast for scalar type")
(ok (eq? (sequence <int>) (to-type <int> (sequence <byte>)))
    "typecast element-type of array type")
(ok (equal? '(#f #t #f) (to-list (=0 (seq -1 0 1))))
    "compare bytes with zero")
(ok (equal? '(#t #f #t) (to-list (!=0 (seq -1 0 1))))
    "check whether bytes are not zero")
(ok (equal? '(#f #t #f #f) (to-list (&& (seq #f #t #t #t) (seq #t #t #t #f) (seq #t #t #f #f))))
    "element-wise and with three arguments")
(ok (equal? '(#f #t) (to-list (&& (seq #f #t) #t)))
    "element-wise and with array and boolean argument")
(ok (equal? '(#f #t #t #t) (to-list (|| (seq #f #t #f #t) (seq #f #f #t #t))))
    "element-wise or")
(ok (equal? '(#f #t #f) (to-list (! (seq #t #f #t))))
    "element-wise not for booleans")
(ok (equal? '(#f #t #f) (to-list (= (seq <int> 1 2 3) 2)))
    "element-wise array-scalar comparison")
(ok (equal? '(#f #t #f) (to-list (= 2 (seq <int> 1 2 3))))
    "Element-wise scalar-array comparison")
(ok (equal? '(#f #t #f) (to-list (= (seq <int> 3 2 1) (seq <int> 1 2 3))))
    "Element-wise array-array comparison")
(ok (equal? '(#f #t #f) (to-list (= (seq <int> 3 2 1) (seq <byte> 1 2 3))))
    "Element-wise comparison with integers of different size (first case)")
(ok (equal? '(#f #t #f) (to-list (= (seq <byte> 3 2 1) (seq <int> 1 2 3))))
    "Element-wise comparison with integers of different size (second case)")
(ok (equal? '(#t #f #t) (to-list (!= (seq <int> 1 2 3) 2)))
    "element-wise array-scalar non-equal comparison")
(ok (equal? '(#t #f #f) (to-list (< (seq 3 4 255) 4)))
    "element-wise lower-than")
(ok (equal? '(#t #f #f) (to-list (< (seq -1 0 1) 0)))
    "element-wise lower-than with signed values")
(ok (equal? '(#f #f #t) (to-list (< 0 (seq -1 0 1))))
    "element-wise lower-than with signed values")
(ok (equal? '(#t #t #f) (to-list (<= (seq 3 4 255) 4)))
    "element-wise lower-equal with unsigned values")
(ok (equal? '(#t #t #f) (to-list (<= (seq -1 0 1) 0)))
    "element-wise lower-equal with signed values")
(ok (equal? '(#f #f #t) (to-list (> (seq 3 4 255) 4)))
    "element-wise greater-than with signed values")
(ok (equal? '(#f #f #t) (to-list (> (seq -1 0 1) 0)))
    "element-wise lower-equal with signed values")
(ok (equal? '(#f #t #t) (to-list (>= (seq 3 4 255) 4)))
    "element-wise greater-equal with unsigned values")
(ok (equal? '(#f #t #t) (to-list (>= (seq -1 0 1) 0)))
    "element-wise greater-equal with signed values")
(ok (equal? '(#f #f #f) (to-list (< (seq 1 2 128) -1)))
   "element-wise lower-than with unsigned and signed byte")
(ok (equal? (list (CBW) (CWD) (CDQ) (CQO)) (map sign-extend-ax '(1 2 4 8)))
   "sign-extend AL, AX, EAX, and RAX")
(let [(r (var <byte>)) (a (var <byte>)) (b (var <byte>))]
  (ok (equal? (list (MOV AL a) (CBW) (IDIV b) (MOV r AL)) (flatten-code (filter-blocks (div r a b))))
      "generate code for 8-bit signed division")
  (ok (equal? (list (MOV AL a) (CBW) (IDIV b) (MOV AL AH) (MOV r AL)) (flatten-code (filter-blocks (mod r a b))))
      "generate code for 8-bit signed remainder")
  (ok (eq? RAX (get-reg (div r a b)))
      "block RAX register when dividing"))
(let [(r (var <ubyte>)) (a (var <ubyte>)) (b (var <ubyte>))]
  (ok (equal? (list (MOVZX AX a) (DIV b) (MOV r AL)) (flatten-code (filter-blocks (div r a b))))
      "generate code for 8-bit unsigned division"))
(let [(r (var <sint>)) (a (var <sint>)) (b (var <sint>))]
  (ok (equal? (list (MOV AX a) (CWD) (IDIV b) (MOV r AX)) (flatten-code (filter-blocks (div r a b))))
      "generate code for 16-bit signed division")
  (ok (eq? RDX (get-reg (car (get-code (div r a b)))))
      "16-bit signed division blocks RDX register"))
(let [(r (var <usint>)) (a (var <usint>)) (b (var <usint>))]
  (ok (equal? (list (MOV AX a) (MOV DX 0) (DIV b) (MOV r AX)) (flatten-code (filter-blocks (div r a b))))
      "generate code for 16-bit unsigned division")
  (ok (equal? (list (MOV AX a) (MOV DX 0) (DIV b) (MOV r DX)) (flatten-code (filter-blocks (mod r a b))))
      "generate code for 16-bit unsigned modulo"))
(ok (equal? '(1 2 -3) (to-list (/ (seq 3 6 -9) 3)))
    "element-wise signed byte division")
(ok (equal? '(2 0 1) (to-list (% (seq 2 3 4) 3)))
    "element-wise modulo")
(ok (eq? <int> (type (to-type <int> (parameter <ubyte>))))
    "check result type of parameter type conversion")
(ok (equal? 42 ((jit ctx (list <byte>) (cut to-type <int> <>)) 42))
    "compile and run type conversion of scalar")
(ok (equal? '(2 3 5) (to-list ((jit ctx (list (sequence <byte>)) (cut to-type <int> <>)) (seq <byte> 2 3 5))))
    "compile and run element-wise conversion of array to integer")
(ok (eq? <int> (typecode (to-type <int> (seq 2 3 5))))
    "type conversion uses specified element type for return value")
(ok (equal? '(2 3 5) (to-list (to-type <int> (seq 2 3 5))))
    "type conversion preserves content")
(ok (equal? '(2 3 5) (to-list ((jit ctx (list (sequence <int>)) (cut to-type <byte> <>)) (seq <int> 2 3 5))))
    "compile and run element-wise conversion of array to byte")
(ok (equal? '(255 0 1) (to-list (to-type <ubyte> (seq 255 256 257))))
    "typecasting to smaller integer type")
(let [(a   (skeleton <sint>))
      (tmp (skeleton <sint>))]
  (ok (equal? (attach (code tmp a) tmp) (insert-intermediate a tmp list))
      "Use intermediate value")
  (ok (equal? (code tmp a) (insert-intermediate a tmp (const '())))
      "Use empty code"))
(let* [(a   (parameter <sint>))
       (tmp (parameter <sint>))
       (f   (~ a))]
  (ok ((need-intermediate-param? <sint>) f)
      "Compilation of function require intermediate value")
  (ok (not ((need-intermediate-param? <sint>) a))
      "Value does not require intermediate value")
  (ok ((need-intermediate-param? <int>) a)
      "Value of different size requires intermediate value"))



(let [(a (parameter <int>))
      (b (parameter <sint>))
      (c (parameter <ubyte>))
      (r (parameter <long>))]
  (ok (equal? (list (SUB RSP 8) (MOVSX RSI EDX) (MOVSX RDX CX) (ADD RSI RDX) (MOVZX RCX AL) (ADD RSI RCX) (ADD RSP 8) (RET))
              (register-allocate (attach ((term (+ a b c)) r) (RET))))
      "Coerce to output value when using multiple mutating operations"))
(ok (equal? 9 ((jit ctx (list <int> <int> <int>) +) 2 3 4))
    "Compiling and run plus operation with three numbers")
(ok (equal? 9 ((jit ctx (list <int> <int> <int>) (lambda (x y z) (+ x (+ y z)))) 2 3 4))
    "Compile and run binary mutating operating with nested second parameter")
(ok ((jit ctx (list <int> <int>) (lambda (x y) (=0 (+ x y)))) -3 3)
    "compile and run unary functional operation with nested parameter")
(ok ((jit ctx (list <int> <int> <int>) (lambda (a b c) (= a (+ b c)))) 5 2 3)
    "compile and run binary functional operation with nested first parameter")
(ok ((jit ctx (list <int> <int> <int>) (lambda (a b c) (= (+ a b) c))) 2 3 5)
    "compile and run binary functional operation with nested first parameter")
(let [(i (parameter <int>))]
  (ok (equal? i (decompose-value <int> i))
      "Integer decomposes to itself"))
(ok (equal? 2 ((jit ctx (list <usint> <usint>) min) 2 3))
    "get minor number of two integers (first case)")
(ok (equal? 2 ((jit ctx (list <usint> <usint>) min) 3 2))
    "get minor number of two integers (second case)")
(ok (equal? 32767 ((jit ctx (list <usint> <usint>) min) 32767 32768))
    "get minor number of two unsigned integers (first case)")
(ok (equal? 32767 ((jit ctx (list <usint> <usint>) min) 32768 32767))
    "get minor number of two unsigned integers (second case)")
(ok (equal? -1 ((jit ctx (list <sint> <sint>) min) -1 1))
    "get minor number of two signed integers")
(ok (equal? 32768 ((jit ctx (list <usint> <usint>) max) 32767 32768))
    "get major number of two unsigned integers (first case)")
(ok (equal? 32768 ((jit ctx (list <usint> <usint>) max) 32768 32767))
    "get major number of two unsigned integers (second case)")
(ok (equal? 1 ((jit ctx (list <sint> <sint>) max) -1 1))
    "get major number of two signed integers")
(ok (equal? 32768 ((jit ctx (list <sint> <usint>) max) -1 32768))
    "get major number of signed and unsigned short integers")
(ok (equal? 2 ((jit ctx (list <ubyte> <ubyte>) min) 2 3))
    "get minor number of two unsigned bytes (first case)")
(ok (equal? 2 ((jit ctx (list <ubyte> <ubyte>) min) 3 2))
    "get minor number of two unsigned bytes (second case)")
(ok (equal? 3 ((jit ctx (list <ubyte> <ubyte>) max) 2 3))
    "get major number of two unsigned bytes (first case)")
(ok (equal? 3 ((jit ctx (list <ubyte> <ubyte>) max) 3 2))
    "get major number of two unsigned bytes (second case)")
(ok (equal? -1 ((jit ctx (list <byte> <byte>) min) -1 1))
    "get minor number of two bytes (first case)")
(ok (equal? -1 ((jit ctx (list <byte> <byte>) min) 1 -1))
    "get minor number of two bytes (second case)")
(ok (equal? 1 ((jit ctx (list <byte> <byte>) max) -1 1))
    "get major number of two bytes (first case)")
(ok (equal? 1 ((jit ctx (list <byte> <byte>) max) 1 -1))
    "get major number of two bytes (second case)")
(let [(r (parameter <ubyte>))
      (a (parameter <ubyte>))
      (b (parameter <ubyte>))]
  (ok (equal? (list (SUB RSP 8) (MOV DL CL) (CMP DL AL) (JNBE #x2) (MOV DL AL) (ADD RSP 8) (RET))
              (resolve-jumps (register-allocate (attach (flatten-code ((term (max a b)) r)) (RET)))))
      "handle lack of support for 8-bit conditional move"))
(ok (equal? -1 ((jit ctx (list <byte> <byte>) min) -1 1))
    "get minor number of signed bytes")
(run-tests)
