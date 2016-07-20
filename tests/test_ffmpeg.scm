(use-modules (oop goops)
             (srfi srfi-1)
             (aiscm ffmpeg)
             (aiscm element)
             (aiscm int)
             (aiscm float)
             (aiscm rgb)
             (aiscm image)
             (aiscm pointer)
             (aiscm sequence)
             (guile-tap))
(define video (open-ffmpeg-input "fixtures/av-sync.mp4"))
(define audio-mono (open-ffmpeg-input "fixtures/mono.mp3"))
(define audio-stereo (open-ffmpeg-input "fixtures/test.mp3"))
(define image (open-ffmpeg-input "fixtures/fubk.png"))

(define video-pts0 (video-pts video))
(define video-frame (read-video video))
(define video-pts1 (video-pts video))
(define video-frame (read-video video))
(define video-pts2 (video-pts video))

(define audio-pts0 (audio-pts audio-mono))
(define audio-mono-frame (read-audio audio-mono))
(define audio-pts1 (audio-pts audio-mono))
(read-audio audio-mono)
(define audio-pts2 (audio-pts audio-mono))

(define audio-stereo-frame (read-audio audio-stereo))
(define surround (open-ffmpeg-input "fixtures/surround.vob"))

(define full-video (open-ffmpeg-input "fixtures/av-sync.mp4"))
(define images (map (lambda _ (read-video full-video)) (iota 720)))
(define full-audio (open-ffmpeg-input "fixtures/test.mp3"))
(define samples (map (lambda _ (read-audio full-audio)) (iota 1625)))
;(define frames (map (lambda _ (class-of (read-audio/video video))) (iota 32)))

(ok (equal? '(640 356) (shape video))
    "Check frame size of input video")
(ok (throws? (open-ffmpeg-input "fixtures/no-such-file.avi"))
    "Throw error if file does not exist")
(ok (throws? (shape audio-mono))
    "Audio file does not have width and height")
(ok (equal? '(640 356) (shape video-frame))
    "Check shape of video frame")
(ok (is-a? video-frame <image>)
    "Check that video frame is an image object")
(ok (eqv? (/ 24000 1001) (frame-rate video))
    "Get frame rate of video")
(ok (throws? (frame-rate audio-mono))
    "Audio file does not have a frame rate")
(ok (not (cadr (list (read-video image) (read-video image))))
    "Image has only one video frame")
(ok (equal? (rgb 195 179 137) (get (to-array video-frame) 100 200))
    "Check a pixel in the first video frame of the video")
(ok (equal? (list 0 0 (/ 1001 24000)) (list video-pts0 video-pts1 video-pts2))
    "Check first three video frame time stamps")
(ok (last images)
    "Check last image of video was read")
(ok (not (read-video full-video))
    "Check 'read-video' returns false after last frame")
(ok (eqv? 1 (channels audio-mono))
    "Detect mono audio stream")
(ok (eqv? 2 (channels video))
    "Detect stereo audio stream")
(ok (eqv? 6 (channels surround))
    "Detect 6 surround channels")
(ok (throws? (channels image))
    "Image does not have audio channels")
(ok (eqv? 8000 (rate audio-mono))
    "Get sampling rate of audio stream")
(ok (throws? (rate image))
    "Image does not have an audio sampling rate")
(ok (eq? <sint> (typecode audio-mono))
    "Get type of audio samples")
(ok (throws? (typecode image))
    "Image does not have an audio sample type")
(ok (is-a? audio-mono-frame <sequence<>>)
    "Check that audio frame is an array")
(ok (eqv? 2 (dimensions audio-mono-frame))
    "Audio frame should have two dimensions")
(ok (eq? <sint> (typecode audio-mono-frame))
    "Audio frame should have samples of correct type")
(ok (eqv? 1 (car (shape audio-mono-frame)))
    "Mono audio frame should have 1 as first dimension")
(ok (eqv? 2 (car (shape audio-stereo-frame)))
    "Stereo audio frame should have 2 as first dimension")
(ok (eqv? 40 (get audio-mono-frame 0 300))
    "Get a value from a mono audio frame")
(ok (not (read-audio full-audio))
    "Check 'read-audio' returns false after last frame")
(ok (equal? (list 0 0 (/ 3456 48000)) (list audio-pts0 audio-pts1 audio-pts2))
    "Check first three audio frame time stamps")
(diagnostics "Following test should not hang")
(ok (not (read-audio image))
    "Do not hang when reading audio from image")
;(ok (memv (multiarray <float> 2) frames)
;    "read-audio/video should return audio frames")
;(ok (memv <image> frames)
;    "read-audio/video should return video frames")
(ok (eqv? 15 (pts= video 15))
    "Seeking should return the time parameter")
(ok (<= 15 (begin (read-video video) (video-pts video)))
    "Seeking audio/video should update the video position")
(let [(image (open-ffmpeg-input "fixtures/fubk.png"))]
  (read-audio image)
  (todo (read-video image)
      "Cache video data when reading audio"))
(run-tests)
