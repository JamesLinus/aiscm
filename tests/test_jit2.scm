;; AIscm - Guile extension for numerical arrays and tensors.
;; Copyright (C) 2013, 2014, 2015, 2016 Jan Wedekind <jan@wedesoft.de>
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
(define b1 (random (ash 1  6)))
(define b2 (random (ash 1  6)))
(define w1 (random (ash 1 14)))
(define w2 (random (ash 1 14)))
(define i1 (random (ash 1 30)))
(define i2 (random (ash 1 30)))
(define l1 (random (ash 1 62)))
(define l2 (random (ash 1 62)))
(define mem (make <mem> #:size 256))
(define bptr (make (pointer <byte>) #:value mem))
(define wptr (make (pointer <sint>) #:value mem))
(define iptr (make (pointer <int>) #:value mem))
(define lptr (make (pointer <long>) #:value mem))
(define (idata) (begin
                  (store iptr       i1)
                  (store (+ iptr 1) i2)
                  iptr))
(ok (equal? '(9 10 12) (to-list ((jit ctx (list <int> (sequence <int>)) +) 7 (seq <int> 2 3 5))))
    "compile and run scalar-array operation")
(ok (equal? '(9 10 12) (to-list ((jit ctx (list <int> (sequence <byte>)) +) 7 (seq <byte> 2 3 5))))
    "sign-extend second number when adding value from pointer")
(ok (equal? '(9 14 18) (to-list ((jit ctx (list (sequence <int>) (sequence <int>)) +) (seq <int> 2 3 5) (seq <int> 7 11 13))))
    "compile and run array-array operation")
(ok (equal? '((7) (8)) (to-list ((jit ctx (list (multiarray <int> 2) <int>) +) (arr <int> (2) (3)) 5)))
    "compile and run 2D array-scalar operation")
(ok (equal? '((7) (8)) (to-list ((jit ctx (list <int> (multiarray <int> 2)) +) 5 (arr <int> (2) (3)))))
    "compile and run 2D scale-array operation")
(ok (equal? '((0 1 3) (0 2 4))
            (to-list ((jit ctx (list (sequence <byte>) (multiarray <ubyte> 2)) +) (seq -2 -3) (arr (2 3 5) (3 5 7)))))
    "compile and run operation involving 1D and 2D array")
(let [(out (skeleton <int>))
      (a   (skeleton <int>))]
  (ok (equal? (list (list (mov-signed (get out) (get a))) (NEG (get out)))
              (code (parameter out) (- (parameter a))))
      "generate code for negating number"))
(let [(a (parameter (sequence <int>)))]
  (ok (equal? (delegate (car (arguments (body (- a))))) (delegate (car (arguments (- (body a))))))
      "body of array negation should have same argument as negation of array body"))
(ok (equal? -42 ((jit ctx (list <int>) (lambda (x) (make-function 'name identity (mutating-code NEG) (list x)))) 42))
    "Create function object mapping to NEG")
(ok (equal? -42 ((jit ctx (list <int>) -) 42))
    "Negate integer")
(ok (equal? '(-2 3 -5) (to-list ((jit ctx (list (sequence <int>)) -) (seq <int> 2 -3 5))))
    "compile and run function for negating array")
(ok (equal? 42 ((jit ctx (list <int>) +) 42))
    "plus passes through values")
(ok (equal? 3 ((jit ctx (list <int> <sint> <ubyte>) +) 2 -3 4))
    "Compiling a plus operation with different types creates an equivalent machine program")
(ok (equal? i1 ((jit ctx (list (pointer <int>)) identity) (idata)))
    "Compile and run code for fetching data from a pointer")
(ok (equal? '(253 252 250) (to-list ((jit ctx (list (sequence <ubyte>)) ~) (seq 2 3 5))))
    "Bitwise not of sequence")
(ok (equal? '(0 1 2) (to-list ((jit ctx (list (sequence <int>) <byte>) -) (seq <int> 1 2 3) 1)))
    "Subtract byte from integer sequence")
(ok (equal? '(2 4 6) (to-list ((jit ctx (list (sequence <int>) <int>) *) (seq <int> 1 2 3) 2)))
    "Multiply integer sequence with an integer")
(ok (equal? '(-2 -3 -5) (to-list (- (seq <int> 2 3 5))))
    "negate integer sequence")
(ok (equal? '((-1 2) (3 -4)) (to-list (- (arr (1 -2) (-3 4)))))
    "negate 2D array")
(ok (equal? 42 ((jit ctx (list <int>) (compose - -)) 42))
    "Negate integer twice")
(ok (equal? '(2 4) (to-list (+ (downsample 2 (seq 1 2 3 4)) 1)))
    "add 1 to downsampled array")
(ok (equal? '(2 4) (to-list (+ 1 (downsample 2 (seq 1 2 3 4)))))
    "add downsampled array to 1")
(ok (equal? '(2 6) (let [(s (downsample 2 (seq 1 2 3 4)))] (to-list (+ s s))))
    "add two downsampled arrays")
(ok (equal? '(2 3 5) (to-list (+ (seq <int> 2 3 5))))
    "unary plus for sequence")
(ok (equal? '(253 252 250) (to-list (~ (seq 2 3 5))))
    "bitwise negation of array")
(ok (equal? '(3 4 6) (to-list (+ (seq 2 3 5) 1)))
    "add integer to integer sequence")
(ok (equal? '(3 4 6) (to-list (+ 1 (seq 2 3 5))))
    "add integer sequence to integer")
(ok (equal? '(3 5 9) (to-list (+ (seq 2 3 5) (seq 1 2 4))))
    "add two sequences")
(ok (equal? '(-3 -2 -1) (to-list (- (seq -1 0 1) 2)))
    "element-wise subtract integer from a sequence")
(ok (equal? '((0 1 2) (3 4 5)) (to-list (- (arr (1 2 3) (4 5 6)) 1)))
    "subtract 1 from a 2D array")
(ok (equal? '((6 5 4) (3 2 1)) (to-list (- 7 (arr (1 2 3) (4 5 6)))))
    "subtract 2D array from integer")
(run-tests)
