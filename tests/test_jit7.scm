(use-modules (oop goops)
             (aiscm asm)
             (aiscm jit)
             (aiscm element)
             (aiscm int)
             (aiscm pointer)
             (aiscm sequence)
             (guile-tap))

(define ctx (make <context>))
(define i (var <long>))
(define j (var <long>))

(let* [(s  (skeleton (sequence <int>)))
       (sx (parameter s))]
  (ok (eq? (value s) (value (delegate (delegate sx))))
      "sequence parameter maintains pointer")
  (ok (eq? (index sx) (index (delegate sx)))
      "index of parameter and index of parameters content should match")
  (ok (eq? (dimension s) (dimension sx))
      "sequence parameter should maintain dimension")
  (ok (eq? (stride s) (stride (delegate sx)))
      "sequence parameter should maintain stride")
  (ok (eq? (sequence <int>) (type sx))
      "sequence parameter maintains type")
  (ok (eq? i (index (subst (delegate sx) (index sx) i)))
      "substitution should replace the lookup index")
  (ok (eq? i (index (get sx i)))
      "retrieving an element by index should replace with the index")
  (ok (eq? (iterator (delegate sx)) (iterator sx))
      "retrieve iterator pointer from tensor parameter")
  (ok (eq? (step (delegate sx)) (step sx))
      "retrieve step variable from tensor parameter")
  (ok (not (eq? (step sx) (iterator sx)))
      "step and iterator need to be distinct variables")
  (ok (is-a? (delegate (project sx)) (pointer <int>))
      "projected 1D array tensor should contain pointer"))
(let* [(m  (skeleton (multiarray <int> 2)))
       (mx (parameter m))]
  (ok (equal? (shape m) (shape mx))
      "2D array parameter should maintain the shape")
  (ok (equal? (index mx) (index (delegate (delegate mx))))
      "first index of parameter should have a match")
  (ok (equal? (index (delegate mx)) (index (delegate (delegate (delegate mx)))))
      "second index of parameter should have a match")
  (ok (eq? i (index (subst (delegate (delegate mx)) (index mx) i)))
    "subst should allow replacing first index")
  (ok (eq? i (index (delegate (subst (delegate (delegate mx)) (index (delegate mx)) i))))
    "subst should allow replacing second index")
  (ok (eq? (index mx) (index (subst (delegate (delegate mx)) (index (delegate mx)) i)))
    "replacing the second index should maintain the first one")
  (ok (eq? i (index (delegate (get mx i))))
    "retrieving an element should replace with the index")
  (let [(tr (indexer (car (shape mx)) i (indexer (cadr (shape mx)) j (get (get mx j) i))))]
    (ok (equal? (list (dimension mx) (dimension (project mx)))
                (list (dimension (project tr)) (dimension tr)))
        "swap dimensions when transposing")
    (ok (equal? (list (stride mx) (stride (project mx)))
                (list (stride (project tr)) (stride tr)))
        "swap strides when transposing")
    (ok (equal? (list (step mx) (step (project mx)))
                (list (step (project tr)) (step tr)))
        "swap step variables when transposing")
    (ok (equal? (list (iterator mx) (iterator (project mx)))
                (list (iterator (project tr)) (iterator tr)))
        "swap iterator variables when transposing")))
(let [(s (seq <int> 2 3 5))
      (m (arr <int> (2 3 5) (7 11 13) (17 19 23)))
      (r (arr <int> (2 3 5) (7 11 13)))]
  (let [(op (lambda (s) (indexer (dimension s) i (get s i))))]
    (ok (equal? (to-list s) (to-list ((jit ctx (list (sequence <int>)) op) s)))
        "compile and run trivial 1D tensor function"))
  (ok (equal? (to-list s) (to-list ((jit ctx (list (class-of s)) (lambda (s) (indexer (car (shape s)) i (get s i)))) s)))
      "reconstitute a 1D tensor in compiled code")
  (ok (equal? (to-list m)
              (to-list ((jit ctx (list (class-of m))
                (lambda (m) (indexer (cadr (shape m)) j (indexer (car (shape m)) i (get (get m j) i))))) m)))
      "reconstitute a square 2D tensor")
  (ok (equal? (to-list (roll m))
              (to-list ((jit ctx (list (class-of m))
                (lambda (m) (indexer (car (shape m)) i (indexer (cadr (shape m)) j (get (get m j) i))))) m)))
      "switch dimensions of a 2D tensor")
  (ok (equal? (to-list s) (to-list ((jit ctx (list (class-of s)) (lambda (s) (tensor (dimension s) k (get s k)))) s)))
      "tensor macro provides local variable")
  (skip (equal? (to-list (roll r))
              (to-list ((jit ctx (list (class-of r))
                (lambda (r) (indexer (car (shape r)) i (indexer (cadr (shape r)) j (get (get r j) i))))) r)))
      "switch dimensions of a non-square 2D tensor"))
(run-tests)
