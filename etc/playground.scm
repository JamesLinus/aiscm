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

(define v (var <int>))

(define prog (list (MOV v 42) (RET)))

(define intervals (live-intervals (live-analysis prog) (variables prog)))

(define default-registers (list RAX RCX RDX RSI RDI R10 R11 R9 R8 RBX R12 R13 R14 R15))

(define (labels prog)
  "Get positions of labels in program"
  (filter (compose symbol? car) (map cons prog (iota (length prog)))))

(define-method (next-indices labels cmd k)
  "Determine next program indices for a statement"
  (if (equal? cmd (RET)) '() (list (1+ k))))
(define-method (next-indices labels (cmd <jcc>) k)
  "Determine next program indices for a (conditional) jump"
  (let [(target (assq-ref labels (get-target cmd)))]
    (if (conditional? cmd) (list (1+ k) target) (list target))))

(define (live-analysis prog results)
  "Get list of live variables for program terminated by RET statement"
  (letrec* [(inputs    (map-if (cut equal? (RET) <>) (const results) input prog))
            (outputs   (map output prog))
            (indices   (iota (length prog)))
            (lut       (labels prog))
            (flow      (map (cut next-indices lut <...>) prog indices))
            (same?     (cut every (cut lset= equal? <...>) <...>))
            (track     (lambda (value)
                         (lambda (in ind out)
                           (union in (difference (apply union (map (cut list-ref value <>) ind)) out)))))
            (initial   (map (const '()) prog))
            (iteration (lambda (value) (map (track value) inputs flow outputs)))]
    (map union (fixed-point initial iteration same?) outputs)))


; TODO: sort intervals
(define (linear-scan intervals registers)
  (if (null? intervals)
      '()
      (cons
        (cons (caar intervals) (car registers))
        (linear-scan (cdr intervals) (if (< (cddar intervals) 1) registers (cdr registers))))))

(ok (equal? '((a . 1) (b . 3)) (labels (list (JMP 'a) 'a (MOV AX 0) 'b (RET))))
    "'labels' should extract indices of labels")
(ok (equal? '(1) (next-indices '() (MOV CX 0) 0))
    "Get following indices for first statement in a program")
(ok (equal? '(2) (next-indices '() (MOV AX CX) 1))
    "Get following indices for second statement in a program")
(ok (equal? '() (next-indices '() (RET) 2))
    "RET statement should not have any following indices")
(ok (equal? '(2) (next-indices '((a . 2)) (JMP 'a) 0))
    "Get following indices for a jump statement")
(ok (equal? '(1 2) (next-indices '((a . 2)) (JNE 'a) 0))
    "Get following indices for a conditional jump")
(let [(a (var <int>))
      (b (var <int>))
      (c (var <int>))]
  (ok (equal? (list '() (list a) '()) (live-analysis (list 'x (MOV a 0) (RET)) '()))
      "Live-analysis for definition of unused variable")
  (ok (equal? (list (list a) (list a) (list b a) '()) (live-analysis (list (MOV a 0) (NOP) (MOV b a) (RET)) '()))
      "Live-analysis for definition and later use of a variable")
  (ok (equal? (list (list a) (list a) (list a) (list a) '())
              (live-analysis (list (MOV a 0) 'x (ADD a 1) (JE 'x) (RET)) '()))
      "Live-analysis with conditional jump statement")
  (ok (equal? (list (list a) (list a))
              (live-analysis (list (MOV a 0) (RET)) (list a)))
      "results should be propagated backwards from the return statement"))
(ok (equal? '() (linear-scan '() '()))
    "linear scan with no variables returns empty mapping")
(ok (equal? (list (cons 'a RAX)) (linear-scan '((a . (0 . 0))) (list RAX)))
    "allocate single variable")
(ok (equal? (list (cons 'a RAX) (cons 'b RAX)) (linear-scan '((a . (0 . 0)) (b . (1 . 1))) (list RAX RCX)))
    "reuse register with two variables")
(ok (equal? (list (cons 'a RAX) (cons 'b RCX)) (linear-scan '((a . (0 . 1)) (b . (1 . 1))) (list RAX RCX)))
    "do not reuse register with two conflicting variables")

(run-tests)
