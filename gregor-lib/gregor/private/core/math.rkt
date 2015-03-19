#lang racket/base

(provide (all-defined-out))

(define (div x y)
  (define rem (remainder x y))
  (if (< (bitwise-xor rem y) 0)
      (sub1 (quotient x y))
      (quotient x y)))

(define (mod x y)
  (define rem (remainder x y))
  (if (< (bitwise-xor rem y) 0)
      (+ rem y)
      rem))

(define (mod1 x y)
  (- y (mod (- y x) y)))
