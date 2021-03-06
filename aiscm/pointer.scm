;; AIscm - Guile extension for numerical arrays and tensors.
;; Copyright (C) 2013, 2014, 2015, 2016, 2017 Jan Wedekind <jan@wedesoft.de>
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;
(define-module (aiscm pointer)
  #:use-module (oop goops)
  #:use-module (ice-9 optargs)
  #:use-module (aiscm element)
  #:use-module (aiscm util)
  #:use-module (aiscm mem)
  #:use-module (aiscm int)
  #:use-module (system foreign)
  #:use-module (rnrs bytevectors)
  #:export (<pointer<>> <meta<pointer<>>>
            <pointer<element>> <meta<pointer<element>>>
            <pointer<int<>>> <meta<pointer<int<>>>>
            pointer fetch store rebase pointer-cast pointer-offset set-pointer-offset))
(define-class* <pointer<>> <element> <meta<pointer<>>> <meta<element>>)
(define-class* <pointer<element>> <pointer<>> <meta<pointer<element>>> <meta<pointer<>>>)
(define-method (pointer (target <meta<element>>))
  (template-class (pointer target) (pointer (super target))
    (lambda (class metaclass)
      (define-method (initialize (self class) initargs)
        (let-keywords initargs #t (value)
          (let [(value (or value (make <mem> #:size (size-of target) #:pointerless (pointerless? target))))]
            (next-method self (list #:value value)))))
      (define-method (typecode (self metaclass)) target))))
(define-method (write (self <pointer<>>) port)
  (if (is-a? (get self) <mem>)
    (format port "#<~a #x~16,'0x>"
                 (class-name (class-of self))
                 (pointer-address (get-memory (get self))))
    (format port "#<~a ~a>" (class-name (class-of self)) (get self))))
(define-method (fetch (self <pointer<>>))
  (let [(t (typecode self))]
    (unpack t (read-bytes (get self) (size-of t)))))
(define-method (store (self <pointer<>>) value)
  (write-bytes (get self) (pack (make (typecode self) #:value value))))
(define-method (+ (self <pointer<>>) (offset <integer>))
  (make (class-of self)
        #:value (+ (get self)
                   (* offset ((compose size-of typecode) self)))))
(define-method (pack (self <pointer<>>))
  (pack (make <native-int>
              #:value ((compose pointer-address get-memory get) self))))
(define-method (unbuild (type <meta<pointer<>>>) self) (list (pointer-address (get-memory (get self)))))
(define-method (content (type <meta<pointer<>>>) (self <pointer<>>)) (list (make <ulong> #:value (get self))))
(define-method (rebase value (self <pointer<>>)) (make (class-of self) #:value value))
(define (pointer-cast target self) (make (pointer target) #:value (get self)))
(define pointer-offset (make-object-property))
(define (set-pointer-offset p offset)
  (let [(retval (make (class-of p) #:value (get p)))]
    (set! (pointer-offset retval) offset)
    retval))
(define-method (pointerless? (self <meta<pointer<>>>)) (pointerless? (typecode self)))
(pointer <int<>>)
