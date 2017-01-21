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
(define-module (aiscm ffmpeg)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-26)
  #:use-module (oop goops)
  #:use-module (aiscm mem)
  #:use-module (aiscm element)
  #:use-module (aiscm int)
  #:use-module (aiscm sequence)
  #:use-module (aiscm float)
  #:use-module (aiscm mem)
  #:use-module (aiscm image)
  #:use-module (aiscm util)
  #:export (<ffmpeg> open-ffmpeg-input frame-rate video-pts audio-pts pts=
            ffmpeg-buffer-push ffmpeg-buffer-pop)
  #:re-export (read-image read-audio rate channels typecode))


(load-extension "libguile-aiscm-ffmpeg" "init_ffmpeg")

(define-class* <ffmpeg> <object> <meta<ffmpeg>> <class>
               (ffmpeg #:init-keyword #:ffmpeg)
               (audio-buffer #:init-value '())
               (video-buffer #:init-value '())
               (audio-pts #:init-value 0 #:getter audio-pts)
               (video-pts #:init-value 0 #:getter video-pts))

(define audio-types
  (list (cons AV_SAMPLE_FMT_U8P  <ubyte> )
        (cons AV_SAMPLE_FMT_S16P <sint>  )
        (cons AV_SAMPLE_FMT_S32P <int>   )
        (cons AV_SAMPLE_FMT_FLTP <float> )
        (cons AV_SAMPLE_FMT_DBLP <double>)))

(define (open-input file-name)
  (make <ffmpeg> #:ffmpeg (open-ffmpeg file-name (equal? "YES" (getenv "DEBUG")))))
(define (open-ffmpeg-input file-name) (open-input file-name))

(define-method (shape (self <ffmpeg>)) (ffmpeg-shape (slot-ref self 'ffmpeg)))
(define (frame-rate self) (ffmpeg-frame-rate (slot-ref self 'ffmpeg)))

(define (import-audio-frame self lst)
  (let [(memory     (lambda (data size) (make <mem> #:base data #:size size #:pointerless #t)))
        (array-type (lambda (type) (multiarray (assq-ref audio-types type) 2)))
        (array      (lambda (array-type shape memory) (make array-type #:shape shape #:value memory)))]
    (apply (lambda (pts type shape data size)
             (cons
               pts
               (array (array-type type) shape (memory data size))))
           lst)))

(define (import-video-frame self lst)
  (let [(memory (lambda (data size) (make <mem> #:base data #:size size #:pointerless #t)))]
    (apply (lambda (pts format shape offsets pitches data size)
             (cons
               pts
               (duplicate
                 (make <image>
                       #:format  (format->symbol format)
                       #:shape   shape
                       #:offsets offsets
                       #:pitches pitches
                       #:mem     (memory data size)))))
           lst)))

(define (ffmpeg-buffer-push self slot pts-and-frame)
  (slot-set! self slot (attach (slot-ref self slot) pts-and-frame)) #t)

(define (ffmpeg-buffer-pop self buffer clock)
  (let [(lst (slot-ref self buffer))]
    (and
      (not (null? lst))
      (begin
        (slot-set! self clock  (caar lst))
        (slot-set! self buffer (cdr lst))
        (cdar lst)))))

(define (buffer-audio/video self)
  (let [(lst (ffmpeg-read-audio/video (slot-ref self 'ffmpeg)))]
    (if lst
       (case (car lst)
         ((audio) (ffmpeg-buffer-push self 'audio-buffer (import-audio-frame self (cdr lst))))
         ((video) (ffmpeg-buffer-push self 'video-buffer (import-video-frame self (cdr lst)))))
       #f)))

(define-method (read-audio (self <ffmpeg>))
  (or (ffmpeg-buffer-pop self 'audio-buffer 'audio-pts) (and (buffer-audio/video self) (read-audio self))))
(define-method (read-image (self <ffmpeg>))
  (or (ffmpeg-buffer-pop self 'video-buffer 'video-pts) (and (buffer-audio/video self) (read-image self))))

(define (pts= self position)
  (ffmpeg-seek (slot-ref self 'ffmpeg) position)
  (ffmpeg-flush (slot-ref self 'ffmpeg))
  position)

(define-method (channels (self <ffmpeg>)) (ffmpeg-channels (slot-ref self 'ffmpeg)))
(define-method (rate (self <ffmpeg>)) (ffmpeg-rate (slot-ref self 'ffmpeg)))
(define-method (typecode (self <ffmpeg>))
  (assq-ref audio-types (ffmpeg-typecode (slot-ref self 'ffmpeg))))
