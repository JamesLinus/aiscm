(use-modules (oop goops)
             (system foreign)
             (srfi srfi-26)
             (aiscm element)
             (aiscm bool)
             (aiscm rgb)
             (aiscm int)
             (aiscm float)
             (aiscm sequence)
             (aiscm asm)
             (aiscm pointer)
             (aiscm jit)
             (guile-tap))
(define ctx (make <context>))
(define a (make <var> #:type <int> #:symbol 'a))
(define b (make <var> #:type <int> #:symbol 'b))
(define c (make <var> #:type <int> #:symbol 'c))
(define colour (make <ubytergb> #:value (rgb 1 2 3)))
(define grey (make <ubytergb> #:value 5))
(ok (equal? "(rgb 1 2 3)" (call-with-output-string (lambda (port) (write (rgb 1 2 3) port))))
    "display untyped RGB value")
(ok (eq? (rgb (integer 8 unsigned)) (rgb (integer 8 unsigned)))
    "equality of RGB types")
(ok (eqv? 3 (size-of (rgb <ubyte>)))
    "storage size of unsigned byte RGB")
(ok (eq? (rgb <int>) (rgb <sint> <uint> <byte>))
    "coercion for base types for RGB type")
(ok (eqv? 12 (size-of (rgb (floating-point single-precision))))
    "storage size of single-precision floating-point RGB")
(ok (eq? <int> (base <intrgb>))
    "base of RGB channel")
(ok (equal? (rgb 1 2 3) (rgb 1 2 3))
    "equal RGB objects")
(ok (not (equal? (rgb 1 2 3) (rgb 1 4 3)))
    "unequal RGB objects")
(ok (eqv? 2 (red (rgb 2 3 5)))
    "extract red channel of RGB value")
(ok (eqv? 3 (green (rgb 2 3 5)))
    "extract green channel of RGB value")
(ok (eqv? 5 (blue (rgb 2 3 5)))
    "extract blue channel of RGB value")
(ok (eqv? 42 (red 42))
    "red channel of scalar is itself")
(ok (eqv? 42 (green 42))
    "green channel of scalar is itself")
(ok (eqv? 42 (blue 42))
    "blue channel of scalar is itself")
(ok (equal? #vu8(#x01 #x02 #x03) (pack colour))
    "pack RGB value")
(ok (equal? #vu8(#x05 #x05 #x05) (pack grey))
    "pack grey RGB value")
(ok (equal? colour (unpack <ubytergb> #vu8(#x01 #x02 #x03)))
    "unpack RGB value")
(ok (null? (shape colour))
    "RGB has no dimensions")
(ok (equal? "#<<rgb<int<16,signed>>> (rgb 1 2 3)>"
            (call-with-output-string (lambda (port) (display (make <sintrgb> #:value (rgb 1 2 3)) port))))
    "display short integer RGB object")
(ok (equal? "#<<rgb<int<16,signed>>> (rgb 1 2 3)>"
            (call-with-output-string (lambda (port) (write (make <sintrgb> #:value (rgb 1 2 3)) port))))
    "write short integer RGB object")
(ok (eq? <ubytergb> (coerce <ubytergb> <ubyte>))
    "coerce RGB and scalar type")
(ok (eq? <ubytergb> (coerce <ubyte> <ubytergb>))
    "coerce scalar type and RGB")
(ok (eq? <intrgb> (coerce <uintrgb> <bytergb>))
    "coerce different RGB types")
(ok (eq? (sequence <intrgb>) (coerce (sequence <int>) (rgb <int>)))
    "coerce integer sequence and RGB type")
(ok (eq? (sequence <intrgb>) (coerce (rgb <int>) (sequence <int>)))
    "coerce RGB type and integer sequence")
(ok (eq? (multiarray <intrgb> 2) (coerce (rgb <int>) (multiarray <int> 2)))
    "coerce RGB type and 2D array")
(ok (equal? (list 2 3 5) (content (rgb 2 3 5)))
    "'content' extracts the channels of an RGB value")
(ok (equal? (list 2 3 5) (map get (content (make <intrgb> #:value (rgb 2 3 5)))))
    "'content' extracts values of typed RGB value")
(ok (eq? <ubytergb> (match (rgb 2 3 5)))
    "type matching for (rgb 2 3 5)")
(ok (eq? (rgb <double>) (match (rgb 2 3.5 5)))
    "type matching for (rgb 2 3.5 5)")
(ok (eq? (rgb <double>) (match (rgb 2 3 5) 1.2))
    "type matching for RGB value and scalar")
(ok (eq? (rgb <double>) (match 1.2 (rgb 2 3 5)))
    "type matching for scalar and RGB value")
(ok (eq? (sequence <int>) (base (sequence <intrgb>)))
    "base type of sequence applies to element type")
(ok (eq? <intrgb> (typecode (rgb a b c)))
    "typecode of RGB value is RGB type of base type")
(ok (equal? (rgb -2 -3 -5) (- (rgb 2 3 5)))
    "negate RGB value")
(ok (equal? (rgb -3 -4 -6) (~ (rgb 2 3 5)))
    "invert RGB value")
(ok (equal? (rgb 5 7 10) (+ (rgb 1 2 3) (rgb 4 5 7)))
    "add RGB values")
(ok (equal? (rgb 5 6 6) (- (rgb 7 9 11) (rgb 2 3 5)))
    "subtract RGB values")
(ok (equal? (rgb 2 4 6) (* 2 (rgb 1 2 3)))
    "multiply 2 with RGB value")
(ok (equal? (rgb 0 1 4) (& (rgb 2 3 4) 5))
    "bitwise and for RGB values")
(ok (equal? (rgb 7 7 5) (| (rgb 2 3 4) 5))
    "bitwise or for RGB values")
(ok (equal? (rgb 7 6 1) (^ (rgb 2 3 4) 5))
    "bitwise xor for RGB values")
(ok (equal? (rgb 2 4 8) (<< 1 (rgb 1 2 3)))
    "left shift for RGB values")
(ok (equal? (rgb 1 2 4) (>> (rgb 2 4 8) 1))
    "right shift for RGB values")
(ok (equal? (rgb 1 2 3) (/ (rgb 3 6 9) 3))
    "division for RGB values")
(ok (= (rgb 2 3 5) (rgb 2 3 5))
    "compare two RGB values (positive result)")
(ok (not (= (rgb 2 3 5) (rgb 2 4 5)))
    "compare two RGB values (negative result)")
(ok (!= (rgb 2 3 5) (rgb 2 3 6))
    "check two RGB values for unequal (positive result)")
(ok (not (!= (rgb 2 3 5) (rgb 2 3 5)))
    "check two RGB values for unequal (negative result)")
(ok (equal? (rgb 3 3 5) (max 3 (rgb 2 3 5)))
    "major number of RGB value and scalar")
(ok (equal? (rgb 2 2 1) (min (rgb 2 3 5) (rgb 4 2 1)))
    "minor RGB value")
(ok (is-a? (var <intrgb>) <rgb>)
    "RGB variable is an RGB value")
(let [(p (skeleton (pointer <sintrgb>)))
      (a (skeleton <sintrgb>))
      (b (skeleton <sintrgb>))]
  (ok (equal? (mov-signed (ptr <sint> (get p) 0) (get (red   a))) (car   (code p a)))
      "Writing RGB to memory copies red channel")
  (ok (equal? (mov-signed (ptr <sint> (get p) 2) (get (green a))) (cadr  (code p a)))
      "Writing RGB to memory copies green channel")
  (ok (equal? (mov-signed (ptr <sint> (get p) 4) (get (blue  a))) (caddr (code p a)))
      "Writing RGB to memory copies blue channel")
  (ok (equal? (mov-signed (get (red   a)) (ptr <sint> (get p) 0)) (car   (code a p)))
      "Reading RGB from memory copies red channel")
  (ok (equal? (mov-signed (get (green a)) (ptr <sint> (get p) 2)) (cadr  (code a p)))
      "Reading RGB from memory copies green channel")
  (ok (equal? (mov-signed (get (blue  a)) (ptr <sint> (get p) 4)) (caddr (code a p)))
      "Reading RGB from memory copies blue channel")
  (ok (equal? (mov-signed (get (red   a)) (get (red   b))) (car   (code a b)))
      "copy red channel")
  (ok (equal? (mov-signed (get (green a)) (get (green b))) (cadr  (code a b)))
      "copy green channel")
  (ok (equal? (mov-signed (get (blue  a)) (get (blue  b))) (caddr (code a b)))
      "copy blue channel"))
(ok (equal? (rgb 3 2 5) ((jit ctx (list <intrgb>) identity) (rgb 3 2 5)))
    "compile and run identity function for RGB value")
(ok (equal? (list (rgb 2 3 5) (rgb 3 5 7))
            (to-list ((jit ctx (list (sequence <ubytergb>)) identity) (seq (rgb 2 3 5) (rgb 3 5 7)))))
    "compile and run identity function for RGB array")
(ok (equal? 2 ((jit ctx (list <ubytergb>) red  ) (rgb 2 3 5)))
    "extract red channel of RGB value")
(ok (equal? 3 ((jit ctx (list <ubytergb>) green) (rgb 2 3 5)))
    "extract green channel of RGB value")
(ok (equal? 5 ((jit ctx (list <ubytergb>) blue ) (rgb 2 3 5)))
    "extract blue channel of RGB value")
(ok (equal? '(2 3) (to-list ((jit ctx (list (sequence <ubytergb>)) red  ) (seq (rgb 2 3 5) (rgb 3 5 7)))))
    "compile and run code for extracting red channel of RGB array")
(ok (equal? '(3 5) (to-list ((jit ctx (list (sequence <ubytergb>)) green) (seq (rgb 2 3 5) (rgb 3 5 7)))))
    "compile and run code for extracting green channel of RGB array")
(ok (equal? '(5 7) (to-list ((jit ctx (list (sequence <ubytergb>)) blue ) (seq (rgb 2 3 5) (rgb 3 5 7)))))
    "compile and run code for extracting blue channel of RGB array")
(ok (equal? '(2 3) (to-list (red   (seq (rgb 2 3 5) (rgb 3 5 7)))))
    "extract red channel of RGB array")
(ok (equal? '(3 5) (to-list (green (seq (rgb 2 3 5) (rgb 3 5 7)))))
    "extract green channel of RGB array")
(ok (equal? '(5 7) (to-list (blue  (seq (rgb 2 3 5) (rgb 3 5 7)))))
    "extract blue channel of RGB array")
(ok (equal? '(2 3 5 7) (to-list (red (seq 2 3 5 7))))
    "extract red channel of scalar array")
(ok (equal? '(2 3 5 7) (to-list (green (seq 2 3 5 7))))
    "extract green channel of scalar array")
(ok (equal? '(2 3 5 7) (to-list (blue (seq 2 3 5 7))))
    "extract blue channel of scalar array")
(ok (equal? (rgb 2 3 -5) ((jit ctx (list <bytergb>) -) (rgb -2 -3 5)))
    "compile and run code to negate RGB value")
(ok (equal? (rgb 5 6 6) ((jit ctx (list <bytergb> <bytergb>) -) (rgb 7 9 11) (rgb 2 3 5)))
    "compile and run code to subtract RGB values")
(ok (equal? (rgb 6 7 9) ((jit ctx (list <intrgb> <int>) +) (rgb 2 3 5) 4))
    "compile and run code to adding scalar to RGB value")
(ok (equal? (list (rgb 2 3 5) (rgb 3 4 6)) (to-list (+ (seq (rgb 1 2 4) (rgb 2 3 5)) 1)))
    "Add scalar value to RGB sequence")
(ok (equal? (list (rgb 2 3 5) (rgb 3 4 6)) (to-list (+ (seq 1 2) (rgb 1 2 4))))
    "Add scalar sequence and RGB value")
(ok (equal? (list (rgb 2 3 5) (rgb 3 4 6)) (to-list (+ (rgb 1 2 4) (seq 1 2))))
    "Add RGB value and scalar sequence")
(ok (equal? (list (rgb 2 3 5) (rgb 3 4 6)) (to-list (+ (seq 1 2) (rgb 1 2 4))))
    "Add scalar sequence and RGB value")
(ok (equal? (rgb 2 3 5) ((jit ctx (list <int> <int> <int>) rgb) 2 3 5))
    "compile and run function building an RGB value")
(ok (equal? (rgb 2 3 5) ((jit ctx (list <intrgb>) (cut to-type <bytergb> <>)) (rgb 2 3 5)))
    "convert integer RGB to byte RGB")
(ok (equal? (rgb 2 -3 256) ((jit ctx (list <ubyte> <byte> <usint>) rgb) 2 -3 256))
    "construct RGB value from differently typed values")
(let [(c (parameter <intrgb>))]
  (ok (is-a? (decompose-arg c) <rgb>)
      "Decompose RGB parameter into RGB object"))
(skip ((jit ctx (list <ubytergb> <ubytergb>) =) (rgb 2 3 5) (rgb 2 3 5))
    "Compare two RGB values (positive result)")
(skip (not ((jit ctx (list <ubytergb> <ubytergb>) =) (rgb 2 3 5) (rgb 2 4 5)))
    "Compare two RGB values (negative result)")
(skip ((jit ctx (list <ubytergb> <ubytergb>) !=) (rgb 2 3 5) (rgb 2 4 5))
    "Compare two RGB values (positive result)")
(skip (not ((jit ctx (list <ubytergb> <ubytergb>) !=) (rgb 2 3 5) (rgb 2 3 5)))
    "Compare two RGB values (negative result)")
(skip (not ((jit ctx (list <bytergb> <byte>) =) (rgb 2 3 5) 2))
    "Compare  RGB value with scalar (negative result)")
(skip ((jit ctx (list <byte> <bytergb>) =) 3 (rgb 3 3 3))
    "Compare  RGB value with scalar (positive result)")
(skip (equal? (list (rgb 2 2 3)) (to-list ((jit ctx (list <ubytergb> (sequence <byte>)) max)
                                         (rgb 1 2 3) (seq <byte> 2))))
    "major value of RGB and byte sequence")
(skip (equal? (list (rgb 1 2 2)) (to-list ((jit ctx (list <ubytergb> (sequence <byte>)) min)
                                         (rgb 1 2 3) (seq <byte> 2))))
    "minor value of RGB and byte sequence")
(run-tests)
