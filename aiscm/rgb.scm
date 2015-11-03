(define-module (aiscm rgb)
  #:use-module (oop goops)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-26)
  #:use-module (rnrs bytevectors)
  #:use-module (ice-9 optargs)
  #:use-module (aiscm util)
  #:use-module (aiscm element)
  #:use-module (aiscm pointer)
  #:use-module (aiscm int)
  #:use-module (aiscm sequence)
  #:export (rgb
            <rgb>
            red green blue
            <rgb<>> <meta<rgb<>>>
            <ubytergb> <rgb<int<8,unsigned>>>  <meta<rgb<int<8,unsigned>>>>
            <bytergb>  <rgb<int<8,signed>>>    <meta<rgb<int<8,signed>>>>
            <usintrgb> <rgb<int<16,unsigned>>> <meta<rgb<int<16,unsigned>>>>
            <sintrgb>  <rgb<int<16,signed>>>   <meta<rgb<int<16,signed>>>>
            <uintrgb>  <rgb<int<32,unsigned>>> <meta<rgb<int<32,unsigned>>>>
            <intrgb>   <rgb<int<32,signed>>>   <meta<rgb<int<32,signed>>>>
            <ulonggb>  <rgb<int<64,unsigned>>> <meta<rgb<int<64,unsigned>>>>
            <longrgb>  <rgb<int<64,signed>>>   <meta<rgb<int<64,signed>>>>)
  #:re-export (+ -))
(define-class <rgb> ()
  (red   #:init-keyword #:red   #:getter red)
  (green #:init-keyword #:green #:getter green)
  (blue  #:init-keyword #:blue  #:getter blue))
(define-method (rgb r g b) (make <rgb> #:red r #:green g #:blue b))
(define-method (write (self <rgb>) port)
  (format port "(rgb ~a ~a ~a)" (red self) (green self) (blue self)))
(define-method (equal? (a <rgb>) (b <rgb>)) (equal? (content a) (content b)))
(define-method (red self) self)
(define-method (green self) self)
(define-method (blue self) self)
(define-class* <rgb<>> <element> <meta<rgb<>>> <meta<element>>)
(define-method (rgb (t <meta<element>>))
  (template-class (rgb t) <rgb<>>
    (lambda (class metaclass)
      (define-method (base (self metaclass))t)
      (define-method (size-of (self metaclass)) (* 3 (size-of t))))))
(define-method (write (self <rgb<>>) port)
  (format port "#<~a ~a>" (class-name (class-of self)) (get-value self)))
(define-method (base (self <meta<sequence<>>>)) (multiarray (base (typecode self)) (dimension self)))
(define-method (pack (self <rgb<>>))
  (let* [(vals     (content (get-value self)))
         (channels (map (cut make (base (class-of self)) #:value <>) vals))
         (size     (size-of (base (class-of self))))]
    (bytevector-concat (map pack channels))))
(define-method (unpack (self <meta<rgb<>>>) (packed <bytevector>))
  (let* [(size    (size-of (base self)))
         (vectors (map (cut bytevector-sub packed <> size) (map (cut * size <>) (iota 3))))]
    (make self #:value (apply rgb (map (lambda (vec) (get (unpack (base self) vec))) vectors)))))
(define <ubytergb> (rgb <ubyte>))
(define <bytergb>  (rgb <byte>))
(define <usintrgb> (rgb <usint>))
(define <sintrgb>  (rgb <sint>))
(define <uintrgb>  (rgb <uint>))
(define <intrgb>   (rgb <int>))
(define <ulongrgb> (rgb <ulong>))
(define <longrgb>  (rgb <long>))
(define-method (coerce (a <meta<rgb<>>>) (b <meta<sequence<>>>)) (multiarray (coerce a (typecode b)) (dimension b)))
(define-method (coerce (a <meta<rgb<>>>) (b <meta<element>>)) (rgb (coerce (base a) b)))
(define-method (coerce (a <meta<element>>) (b <meta<rgb<>>>)) (rgb (coerce a (base b))))
(define-method (coerce (a <meta<rgb<>>>) (b <meta<rgb<>>>)) (rgb (coerce (base a) (base b))))
(define-method (match (c <rgb>) . args)
  (let [(decompose-rgb (lambda (x) (if (is-a? x <rgb>) (content x) (list x))))]
    (rgb (apply match (concatenate (map decompose-rgb (cons c args)))))))
(define-method (match (c <number>) . args)
  (let [(decompose-rgb (lambda (x) (if (is-a? x <rgb>) (content x) (list x))))]
    (rgb (apply match (concatenate (map decompose-rgb (cons c args)))))))
(define-method (build (self <meta<rgb<>>>) value) (fetch value))
(define-method (content (self <rgb>)) (list (red self) (green self) (blue self)))
(define-method (typecode (self <rgb>))
  (rgb (reduce coerce #f (map typecode (content self)))))
(define-syntax-rule (unary-rgb-op op)
  (define-method (op (a <rgb>))
    (rgb (op (red a)) (op (green a)) (op (blue a)))))
(unary-rgb-op -)
(unary-rgb-op ~)
(define-syntax-rule (binary-rgb-op op)
  (begin
    (define-method (op (a <rgb>) b)
      (rgb (op (red a) b) (op (green a) b) (op (blue a) b)))
    (define-method (op a (b <rgb>))
      (rgb (op a (red b)) (op a (green b)) (op a (blue b))))
    (define-method (op (a <rgb>) (b <rgb>))
      (rgb (op (red a) (red b)) (op (green a) (green b)) (op (blue a) (blue b))))))
(binary-rgb-op +)
(binary-rgb-op -)
(binary-rgb-op *)
(binary-rgb-op &)
(binary-rgb-op |)
(binary-rgb-op ^)
(binary-rgb-op <<)
(binary-rgb-op >>)
(binary-rgb-op /)
(binary-rgb-op %)
