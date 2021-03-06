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
(use-modules (srfi srfi-64)
             (srfi srfi-1)
             (oop goops)
             (aiscm convolution)
             (aiscm element)
             (aiscm int)
             (aiscm rgb)
             (aiscm sequence))


(test-begin "aiscm convolution")
(test-begin "1D convolution")
  (test-equal "convolution with one-element array"
    '(4 6 10) (to-list (convolve (seq 2 3 5) (seq 2))))
  (test-equal "do not read over array boundaries"
    '(0 0 0) (to-list (convolve (crop 3 (dump 1 (seq 1 0 0 0 1))) (seq 1 2 4))))
  (test-equal "convolution with 3-element impulse kernel"
    '(1 2 3 4 5) (to-list (convolve (seq 1 2 3 4 5) (seq 0 1 0))))
  (test-equal "convolution with 32-bit integers"
    '(1 2 3 4 5) (to-list (convolve (seq <int> 1 2 3 4 5) (seq <int> 0 1 0))))
  (test-equal "convolution with 3-element shift-left kernel"
    '(2 3 0) (to-list (convolve (seq 1 2 3) (seq 1 0 0))))
  (test-equal "convolution with 3-element shift-right kernel"
    '(0 1 2) (to-list (convolve (seq 1 2 3) (seq 0 0 1))))
  (test-equal "use stride of data"
    '(1 2) (to-list (convolve (get (roll (arr (1 0) (2 0))) 0) (seq 1))))
  (test-equal "use stride of kernel"
    '(1 2) (to-list (convolve (seq 0 1) (get (roll (arr (1 0) (2 0))) 0))))
(test-end "1D convolution")

(test-begin "convolution with composite values")
  (test-equal "RGB-scalar convolution"
    (list (rgb 4 6 10)) (to-list (convolve (seq (rgb 2 3 5)) (seq 2))))
(test-end "convolution with composite values")

(test-begin "2D convolution")
  (test-equal "trivial 2D convolution"
    '((2 3 5) (7 11 13)) (to-list (convolve (arr (2 3 5) (7 11 13)) (arr (1)))))
  (test-equal "test impulse in last dimension"
    '((2 3 5) (7 11 13)) (to-list (convolve (arr (2 3 5) (7 11 13)) (arr (0 1 0)))))
  (test-equal "test impulse in first dimension"
    '((2 3) (5 7) (11 13)) (to-list (convolve (arr (2 3) (5 7) (11 13)) (arr (0) (1) (0)))))
  (test-equal "2D convolution with RGB values"
    (list (list (rgb 1 2 3))) (to-list (convolve (to-array (list (list (rgb 1 2 3)))) (arr (1)))))
(test-end "2D convolution")
(test-end "aiscm convolution")
