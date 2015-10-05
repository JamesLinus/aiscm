(use-modules (oop goops)
             (system foreign)
             (aiscm element)
             (aiscm rgb)
             (aiscm int)
             (aiscm float)
             (aiscm sequence)
             (aiscm jit)
             (guile-tap))
(planned-tests 33)
(define a (make <var> #:type <int> #:symbol 'a))
(define b (make <var> #:type <int> #:symbol 'b))
(define c (make <var> #:type <int> #:symbol 'c))
(define colour (make <ubytergb> #:value (rgb 1 2 3)))
(ok (equal? "(rgb 1 2 3)" (call-with-output-string (lambda (port) (write (rgb 1 2 3) port))))
    "display untyped RGB value")
(ok (eq? (rgb (integer 8 unsigned)) (rgb (integer 8 unsigned)))
    "equality of RGB types")
(ok (eqv? 3 (size-of (rgb <ubyte>)))
    "storage size of unsigned byte RGB")
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
(ok (equal? (list <ubyte> <ubyte> <ubyte>) (types <ubytergb>))
    "'types' returns the scalar base type 3 times")
(ok (equal? (list 2 3 5) (content (rgb 2 3 5)))
    "'content' extracts the channels of an RGB value")
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
(ok (eq? <int> (base <int>))
    "base type of integer is integer")
(ok (eq? <intrgb> (typecode (rgb a b c)))
    "typecode of RGB value is RGB type of base type")
