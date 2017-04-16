(use-modules (oop goops)
             (srfi srfi-1)
             (srfi srfi-26)
             (srfi srfi-64)
             (system foreign)
             (aiscm element)
             (aiscm int)
             (aiscm sequence)
             (aiscm mem)
             (aiscm pointer)
             (aiscm rgb)
             (aiscm complex)
             (aiscm obj)
             (aiscm asm)
             (aiscm jit)
             (aiscm method)
             (aiscm util))

(test-begin "playground")

(define ctx (make <context>))

(define (tensor-operation? expr)
  "Check whether expression is a tensor operation"
  (and (list? expr) (memv (car expr) '(+ -))))

(define (expression->identifier expr)
  "Extract structure of tensor and convert to identifier"
  (if (tensor-operation? expr)
      (cons (car expr) (map expression->identifier (cdr expr)))
      '_))

(define (tensor-variables expr)
  "Return variables of tensor expression"
  (if (tensor-operation? expr) (append-map tensor-variables (cdr expr)) (list expr)))

(define (consume-variables identifier variables)
  "Build arguments of expresssion and return remaining variables"
  (if (null? identifier)
    (cons identifier variables)
    (let* [(head (build-expression (car identifier) variables))
           (tail (consume-variables (cdr identifier) (cdr head)))]
      (cons (cons (car head) (car tail)) (cdr tail)))))

(define (build-expression identifier variables)
  "Build a tensor expression and return remaining variables"
  (if (list? identifier)
    (let [(arguments (consume-variables (cdr identifier) variables))]
      (cons (cons (car identifier) (car arguments)) (cdr arguments)))
    variables))

(define (identifier->expression identifier variables)
  "Convert identifier to tensor expression with variables"
  (car (build-expression identifier variables)))

;(define-macro (tensor-op expr)
;  (let* [(vars (flatten (list (tensor-variables expr))))
;         (args (symbol-list (length vars)))
;         (identifier (expression->identifier expr))]
;    `(let [(f (jit ctx (list . ,(map class-of vars)) (lambda ,args ,(identifier->expression identifier (car args)))))]
;      (apply f ,(car vars)))))
;
;(define s (seq 2 3 5))
;
;(tensor-op s)
;
;(expression->identifier s)
;(tensor-variables s)

(test-begin "identify tensor operations")
  (test-assert "+ is a tensor operation"
    (tensor-operation? '(+ x y)))
  (test-assert "- is a tensor operation"
    (tensor-operation? '(- x)))
  (test-assert "x is not a tensor operation"
    (not (tensor-operation? 'x)))
  (test-assert "read-image is not a tensor operation"
    (not (tensor-operation? '(read-image "test.bmp"))))
(test-end "identify tensor operations")

(test-begin "convert tensor expression to identifier")
  (test-equal "filter variable names in expression"
    '_ (expression->identifier 'x))
  (test-equal "filter numeric arguments of expression"
    '_ (expression->identifier 42))
  (test-equal "preserve unary plus operation"
    '(+ _) (expression->identifier '(+ x)))
  (test-equal "preserve unary minus operation"
    '(- _) (expression->identifier '(- x)))
  (test-equal "preserve binary plus operation"
    '(+ _ _) (expression->identifier '(+ x y)))
  (test-equal "works recursively"
    '(+ (- _) _) (expression->identifier '(+ (- x) y)))
  (test-equal "filter non-tensor operations"
    '_ (expression->identifier '(read-image "test.bmp")))
(test-end "convert tensor expression to identifier")

(test-begin "extract variables of tensor expression")
  (test-equal "detect variable name"
    '(x) (tensor-variables 'x))
  (test-equal "detect numerical arguments"
    '(42) (tensor-variables 42))
  (test-equal "extract argument of unary plus"
    '(x) (tensor-variables '(+ x)))
  (test-equal "extract argument of unary minus"
    '(x) (tensor-variables '(- x)))
  (test-equal "extract arguments of binary plus"
    '(x y) (tensor-variables '(+ x y)))
  (test-equal "extract variables recursively"
    '(x y) (tensor-variables '(+ (- x) y)))
  (test-equal "extract non-tensor operations"
    '((read-image "test.bmp")) (tensor-variables '(read-image "test.bmp")))
(test-end "extract variables of tensor expression")

(test-begin "convert tensor identifier to tensor expression")
  (test-equal "single variable expression"
    (cons 'x '(y z)) (build-expression '_ '(x y z)))
  (test-equal "reconstruct unary plus operation"
    (cons '(+ x) '(y)) (build-expression '(+ _) '(x y)))
  (test-equal "build arguments of unary expression"
    (cons '(x) '(y z)) (consume-variables '(_) '(x y z)))
  (test-equal "build arguments of binary expression"
    (cons '(x y) '(z)) (consume-variables '(_ _) '(x y z)))
  (test-equal "build binary expression"
    (cons '(+ x y) '(z)) (build-expression '(+ _ _) '(x y z)))
  (test-equal "consume variables recursively"
    (cons '((- x)) '(y z)) (consume-variables '((- _)) '(x y z)))
  (test-equal "reconstruct single variable expression"
    'x (identifier->expression '_ '(x)))
  (test-equal "reconstruct expression"
    '(- x y) (identifier->expression '(- _ _) '(x y)))
  (test-equal "reconstruct nested expressions"
    '(+ (- x) y) (identifier->expression '(+ (- _) _) '(x y)))
  (test-equal "insert non-tensor operations"
    '(read-image "test.bmp") (identifier->expression '_ '((read-image "test.bmp"))))
(test-end "convert tensor identifier to tensor expression")

(test-end "playground")
