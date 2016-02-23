(define-module (aiscm element)
  #:use-module (oop goops)
  #:use-module (aiscm util)
  #:use-module (system foreign)
  #:export (<element>
            <meta<element>>
            value get set size-of foreign-type pack unpack
            typecode size shape strides dimensions coerce match get-size
            build content base))
(define-class* <element> <object> <meta<element>> <class>
               (value #:init-keyword #:value #:getter value))
(define-method (size-of (self <element>)) (size-of (class-of self)))
(define-method (foreign-type (t <class>)) void)
(define-generic pack)
(define-generic unpack)
(define-method (equal? (a <element>) (b <element>)) (equal? (get a) (get b)))
(define-method (size (self <element>)) 1)
(define-method (shape self) '())
(define-method (strides self) '())
(define-method (dimensions (self <meta<element>>)) 0)
(define-method (dimensions (self <element>)) (dimensions (class-of self)))
(define-method (typecode (self <meta<element>>)) self)
(define-method (typecode (self <element>)) (typecode (class-of self)))
(define-method (get (self <element>)) (value self))
(define-method (set (self <element>) value) (begin (slot-set! self 'value value)) value)
(define-generic slice)
(define-generic coerce)
(define-generic match)
(define-generic get-size)
(define-generic build)
(define-method (content self) (list self))
(define-method (content (self <element>)) (content (get self)))
(define-method (base self) self)
