(use-modules (oop goops)
             (system foreign)
             (aiscm element)
             (aiscm rgb)
             (aiscm int)
             (aiscm float)
             (aiscm jit)
             (guile-tap))
(planned-tests 22)
(define c (make <ubytergb> #:value (rgb 1 2 3)))
(ok (equal? "(rgb 1 2 3)" (call-with-output-string (lambda (port) (write (rgb 1 2 3) port))))
    "display untyped RGB value")
(ok (equal? (rgb (integer 8 unsigned)) (rgb (integer 8 unsigned)))
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
(ok (equal? #vu8(#x01 #x02 #x03) (pack c))
    "pack RGB value")
(ok (equal? c (unpack <ubytergb> #vu8(#x01 #x02 #x03)))
    "unpack RGB value")
(ok (null? (shape c))
    "RGB has no dimensions")
(ok (equal? "#<<rgb<int<16,signed>>> (rgb 1 2 3)>"
            (call-with-output-string (lambda (port) (display (make <sintrgb> #:value (rgb 1 2 3)) port))))
    "display short integer RGB object")
(ok (equal? "#<<rgb<int<16,signed>>> (rgb 1 2 3)>"
            (call-with-output-string (lambda (port) (write (make <sintrgb> #:value (rgb 1 2 3)) port))))
    "write short integer RGB object")
(ok (equal? <ubytergb> (coerce <ubytergb> <ubyte>))
    "coerce RGB and scalar type")
(ok (equal? <ubytergb> (coerce <ubyte> <ubytergb>))
    "coerce scalar type and RGB")
(ok (equal? <intrgb> (coerce <uintrgb> <bytergb>))
    "coerce different RGB types")
(ok (equal? (list <ubyte> <ubyte> <ubyte>) (types <ubytergb>))
    "'types' returns the scalar base type 3 times")
(ok (equal? (list 2 3 5) (content (rgb 2 3 5)))
    "'content' extracts the channels of an RGB value")
(ok (equal? <ubytergb> (match (rgb 2 3 5)))
    "type matching for (rgb 2 3 5)")
(ok (equal? (rgb <double>) (match (rgb 2 3.5 5)))
    "type matching for (rgb 2 3.5 5)")
(ok (equal? (rgb <double>) (match (rgb 2 3 5) 1.2))
    "type matching for RGB value and scalar")
(ok (equal? (rgb <double>) (match 1.2 (rgb 2 3 5)))
    "type matching for scalar and RGB value")
(ok (let [(a (make <var> #:type <int> #:symbol 'a))
          (b (make <var> #:type <int> #:symbol 'b))
          (c (make <var> #:type <int> #:symbol 'c))]
      (equal? (rgb a b c) (param <intrgb> (list a b c))))
    "'param' passes RGB variables through")
