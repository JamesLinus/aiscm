(use-modules (guile-tap))
(load-extension "libguile-tests" "init_tests")
(ok (eqv? 42 (forty-two))
    "Run simple native method")
(ok (null? (from-array-empty))
    "Convert empty integer array to Scheme array")
(ok (equal? '(2 3 5) (from-array-three-elements))
    "Convert integer array with three elements to Scheme array")
(ok (equal? '(2 3 5) (from-array-stop-at-zero))
    "Convert integer array to Scheme array stopping at first zero element")
(ok (equal? '(0) (from-array-at-least-one))
    "Convert zero array with minimum number of elements")
(run-tests)