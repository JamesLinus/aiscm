(define-module (aiscm obj)
  #:use-module (oop goops)
  #:use-module (system foreign)
  #:use-module (aiscm util)
  #:use-module (aiscm element)
  #:use-module (aiscm scalar)
  #:export (<obj> <meta<obj>>))
(define-class* <obj> <scalar> <meta<obj>> <meta<scalar>>)
;TODO: size-of
;TODO: pack
;TODO: unpack
(define-method (coerce (a <meta<obj>>) b) <obj>)
(define-method (coerce a (b <meta<obj>>)) <obj>)
;TODO: coerce
;TODO: write
;TODO: native-type
(define-method (build (self <meta<obj>>) value) (make self #:value (pointer->scm (make-pointer value))))
(define-method (content (type <meta<obj>>) self) (list (pointer-address (scm->pointer self))))