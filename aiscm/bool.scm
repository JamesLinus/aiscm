(define-module (aiscm bool)
  #:use-module (oop goops)
  #:use-module (srfi srfi-1)
  #:use-module (rnrs bytevectors)
  #:use-module (aiscm util)
  #:use-module (aiscm element)
  #:use-module (aiscm scalar)
  #:export (<bool> <meta<bool>>
            && || ! !=)
  #:re-export (=))
(define-class* <bool> <scalar> <meta<bool>> <meta<scalar>>)
(define-method (size-of (self <meta<bool>>)) 1)
(define-method (pack (self <bool>))
  (u8-list->bytevector (list (if (get self) 1 0))))
(define-method (unpack (self <meta<bool>>) (packed <bytevector>))
  (make <bool> #:value (if (eq? (car (bytevector->u8-list packed)) 0) #f #t)))
(define-method (coerce (a <meta<bool>>) (b <meta<bool>>)) <bool>)
(define-method (write (self <bool>) port)
  (format port "#<<bool> ~a>" (get self)))
(define-method (native-type (b <boolean>) . args) (if (every boolean? args) <bool> (next-method)))
(define-method (build (self <meta<bool>>) value) (make self #:value (not (zero? value))))
(define-method (unbuild (type <meta<bool>>) self) (list (if self 1 0)))
(define-method (&& a) a)
(define-method (&& (a <boolean>) (b <boolean>)) (and a b))
(define-method (&& a b c . args) (apply && (&& (&& a b) c) args))
(define-method (|| a) a)
(define-method (|| (a <boolean>) (b <boolean>)) (or a b))
(define-method (|| a b c . args) (apply || (|| (|| a b) c) args))
(define-generic !=)
(define-generic =)
(define-method (! (a <boolean>)) (not a))
