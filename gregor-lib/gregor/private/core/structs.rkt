#lang racket/base

(provide (all-defined-out))

(struct YMD (y m d) #:transparent)
(struct HMSN (h m s n) #:transparent)

