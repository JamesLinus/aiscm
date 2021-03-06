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
(define-module (aiscm xorg)
  #:use-module (oop goops)
  #:use-module (srfi srfi-26)
  #:use-module (ice-9 optargs)
  #:use-module (aiscm util)
  #:use-module (aiscm element)
  #:use-module (aiscm int)
  #:use-module (aiscm sequence)
  #:use-module (aiscm pointer)
  #:use-module (aiscm image)
  #:export (<xdisplay> <meta<xdisplay>>
            <xwindow> <meta<xwindow>>
            process-events event-loop quit? quit=
            show hide title= resize IO-XIMAGE IO-OPENGL IO-XVIDEO)
  #:re-export (destroy write-image))
(load-extension "libguile-aiscm-xorg" "init_xorg")
(define-class* <xdisplay> <object> <meta<xdisplay>> <class>
  (display #:init-keyword #:display #:getter get-display))
(define-method (initialize (self <xdisplay>) initargs)
  (let-keywords initargs #f (name)
    (let [(name (or name ":0.0"))]
      (next-method self (list #:display (make-display name))))))
(define-method (shape (self <xdisplay>)) (display-shape (get-display self)))
(define-method (process-events (self <xdisplay>)) (display-process-events (get-display self)))
(define-method (event-loop (self <xdisplay>) timeout) (display-event-loop (get-display self) timeout))
(define-method (event-loop (self <xdisplay>)) (cut event-loop self <>))
(define-method (destroy (self <xdisplay>)) (display-destroy (get-display self)))
(define-method (quit? (self <xdisplay>)) (display-quit? (get-display self)))
(define-method (quit= (self <xdisplay>) (value <boolean>)) (display-quit= (get-display self) value))
(define-class* <xwindow> <object> <meta<xwindow>> <class>
              (window #:init-keyword #:window #:getter get-window))
(define-method (initialize (self <xwindow>) initargs)
  (let-keywords initargs #f (display shape io)
    (let [(io (or io IO-XIMAGE))]
      (next-method self (list #:window (make-window (get-display display) (car shape) (cadr shape) io))))))
(define-method (show (self <xwindow>)) (window-show (get-window self)))
(define-method (show (self <image>)) (show (list self)) self)
(define-method (show (self <sequence<>>)) (show (list self)) self)
(define-method (show (self <list>))
  (let* [(dsp     (make <xdisplay>))
         (images  (map to-image self))
         (shapes  (map shape images))
         (window  (cut make <xwindow> #:display dsp #:shape <> #:io IO-XIMAGE))
         (windows (map window shapes))]
    (for-each (cut title= <> "AIscm") windows)
    (for-each write-image images windows)
    (for-each show windows)
    (event-loop dsp #f)
    (for-each hide windows)
    (destroy dsp)
    self))
(define-method (show (self <sequence<>>)) (show (to-image self)) self)
(define-method (show (self <procedure>))
  (let* [(dsp     (make <xdisplay>))
         (result  (self dsp))
         (results (if (list? result) result (list result)))
         (io      (if (null? (cdr results)) IO-XVIDEO IO-XIMAGE))
         (images  (map to-image results))
         (shapes  (map shape images))
         (window  (cut make <xwindow> #:display dsp #:shape <> #:io io))
         (windows (map window shapes))]
    (for-each (cut title= <> "AIscm") windows)
    (for-each write-image images windows)
    (for-each show windows)
    (while (not (quit? dsp))
      (set! result (self dsp))
      (if result
        (begin
          (set! results (if (list? result) result (list result)))
          (set! images (map to-image results))
          (for-each write-image images windows)
          (process-events dsp))
        (quit= dsp #t)))
    (for-each hide windows)
    (destroy dsp)
    result))
(define-method (hide (self <xwindow>)) (window-hide (get-window self)))
(define-method (destroy (self <xwindow>)) (window-destroy (get-window self)))
(define-method (title= (self <xwindow>) (title <string>)) (window-title= (get-window self) title))
(define-method (resize (self <xwindow>) (shape <list>))
  (window-resize (get-window self) (car shape) (cadr shape)))
(define-method (write-image (image <image>) (self <xwindow>)) (window-write (get-window self) image))
(define-method (write-image (arr <sequence<>>) (self <xwindow>)) (show self (to-image arr)) arr)
