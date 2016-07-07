(use-modules (oop goops)
             (srfi srfi-1)
             (aiscm ffmpeg)
             (aiscm element)
             (aiscm rgb)
             (aiscm image)
             (aiscm sequence)
             (guile-tap))
(define video (open-input-video "fixtures/camera.avi"))
(define audio (open-input-audio "fixtures/test.mp3"))
(define image (open-input-video "fixtures/fubk.png"))
(define video-pts0 (video-pts video))
(define frame (read-video video))
(define video-pts1 (video-pts video))
(ok (equal? '(320 240) (shape video))
    "Check frame size of input video")
(ok (throws? (open-input-video "fixtures/no-such-file.avi"))
    "Throw error if file does not exist")
(ok (throws? (shape audio))
    "Audio file does not have a frame size")
(ok (throws? (video-pts audio))
    "Audio file does not have a video presentation time stamp")
(ok (equal? '(320 240) (shape frame))
    "Check frame size of video frame")
(ok (is-a? frame <image>)
    "Check that video frame is an image object")
(ok (eqv? 5 (frame-rate video))
    "Get frame rate of video")
(ok (throws? (frame-rate audio))
    "Audio file does not have a frame rate")
(ok (not (cadr (list (read-video image) (read-video image))))
    "Image has only one frame")
(ok (equal? (rgb 195 179 137) (get (to-array frame) 100 200))
    "Check a pixel in the first frame of the video")
(ok (equal? (list 0 (/ 1 5)) (list video-pts0 video-pts1))
    "Check first two video frame time stamps")
(define full-run (open-input-video "fixtures/camera.avi"))
(define images (map (lambda (i) (read-video full-run)) (iota 157)))
(ok (last images)
    "Check last image of video was read")
(ok (not (read-video full-run))
    "Check 'read-video' returns false after last frame")
(ok (eqv? 1 (channels audio))
    "Detect mono audio stream")
(ok (eqv? 2 (channels video))
    "Detect stereo audio stream")
(ok (throws? (channels image))
    "Image does not have an audio channel")
(ok (eqv? 8000 (rate audio))
    "Get sampling rate of audio stream")
(run-tests)
