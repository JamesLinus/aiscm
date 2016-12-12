(use-modules (oop goops)
             (srfi srfi-1)
             (srfi srfi-26)
             (system foreign)
             (aiscm element)
             (aiscm int)
             (aiscm sequence)
             (aiscm mem)
             (aiscm pointer)
             (aiscm rgb)
             (aiscm obj)
             (aiscm asm)
             (aiscm jit)
             (aiscm method)
             (aiscm util)
             (guile-tap))

(define default-registers (list RAX RCX RDX RSI RDI R10 R11 R9 R8 RBX R12 R13 R14 R15))

(define (number-spilled-variables allocation)
  "Count the number of spilled variables"
  (length (unallocated-variables allocation)))

(define (temporary-variables prog)
  "Allocate temporary variable for each first argument of an instruction"
  (map (lambda (cmd) (let [(arg (first-argument cmd))] (and arg (var (typecode arg))))) prog))

(define (unit-intervals vars)
  "Generate intervals of length one for each temporary variable"
  (filter car (map (lambda (var index) (cons var (cons index index))) vars (iota (length vars)))))

; TODO: generate trivial live intervals for temporary variables (filter out undefined locations)

(define* (linear-scan-allocate prog #:key (registers default-registers)
                                          (predefined '()))
  "Linear scan register allocation for a given program"
  (let* [(live         (live-analysis prog '())); TODO: specify return values here
         (all-vars     (variables prog))
         (intervals    (live-intervals live all-vars))
         (allocation   (linear-scan-coloring intervals registers predefined)); TODO: allocate temporary for each statement
         (stack-offset (* 8 (1+ (number-spilled-variables allocation))))
         (locations    (add-spill-information allocation 8 8))]
    (adjust-stack-pointer stack-offset (concatenate (map (cut replace-variables <> locations RAX) prog))))); TODO: use temporary here

(let [(a (var <int>))
      (b (var <int>))
      (c (var <int>))
      (x (var <sint>))]
  (ok (eqv? 0 (number-spilled-variables '()))
      "count zero spilled variables")
  (ok (eqv? 1 (number-spilled-variables '((a . #f))))
      "count one spilled variable")
  (ok (eqv? 0 (number-spilled-variables (list (cons a RAX))))
      "ignore allocated variables when counting spilled variables")
  (ok (equal? '() (temporary-variables '()))
      "an empty program needs no temporary variables")
  (ok (equal? (list <var>) (map class-of (temporary-variables (list (MOV a 0)))))
      "create temporary variable for first arguemnt of instruction")
  (ok (not (equal? (list a) (temporary-variables (list (MOV a 0)))))
      "temporary variable should be distinct from first argument of instruction")
  (ok (equal? (list <sint>) (map typecode (temporary-variables (list (MOV x 0)))))
      "temporary variable should have correct type")
  (ok (equal? (list #f) (temporary-variables (list (MOV AL 0))))
      "it should only create temporary variables when required")
  (ok (equal? '() (unit-intervals '()))
      "create empty list of unit intervals")
  (ok (equal? '((a . (0 . 0))) (unit-intervals '(a)))
      "generate unit interval for one temporary variable")
  (ok (equal? '((a . (0 . 0)) (b . (1 . 1))) (unit-intervals '(a b)))
      "generate unit interval for two temporary variables")
  (ok (equal? '((b . (1 . 1))) (unit-intervals '(#f b)))
      "filter out locations without temporary variable")
  (ok (equal? (list (SUB RSP 16)
                    (MOV EAX 1)
                    (MOV (ptr <int> RSP 8) EAX)
                    (MOV ESI 2)
                    (ADD ESI 3)
                    (MOV EAX (ptr <int> RSP 8))
                    (ADD EAX 4)
                    (MOV (ptr <int> RSP 8) EAX)
                    (ADD RSP 16)
                    (RET))
              (linear-scan-allocate (list (MOV a 1) (MOV b 2) (ADD b 3) (ADD a 4) (RET))
                                    #:registers (list RSI)))
      "'linear-scan-allocate' should spill variables"))

(run-tests)
