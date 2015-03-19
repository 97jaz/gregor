#lang racket/base

(require racket/contract/base
         racket/match
         racket/math
         "structs.rkt")

(define NS/SECOND 1000000000)
(define NS/MILLI (/ NS/SECOND 1000))
(define NS/MICRO (/ NS/MILLI 1000))
(define NS/MINUTE (* NS/SECOND 60))
(define NS/HOUR (* NS/MINUTE 60))
(define NS/DAY (* 86400 NS/SECOND))
(define MILLI/DAY (/ NS/DAY NS/MILLI))
(define DAYS/NS (/ 1 NS/DAY))

(define day-ns/c (integer-in 0 (sub1 NS/DAY)))

(provide/contract
 [NS/MICRO     exact-integer?]
 [NS/MILLI     exact-integer?]
 [NS/SECOND    exact-integer?]
 [NS/MINUTE    exact-integer?]
 [NS/HOUR      exact-integer?]
 [NS/DAY       exact-integer?]
 [MILLI/DAY    exact-integer?]
 [hmsn->day-ns (-> HMSN? day-ns/c)]
 [day-ns->hmsn (-> day-ns/c HMSN?)])

(define (hmsn->day-ns hmsn)
  (match-define (HMSN h m s n) hmsn)
  (+ (* NS/HOUR h)
     (* NS/MINUTE m)
     (* NS/SECOND s)
     n))

(define (day-ns->hmsn ns)
  (let* ([h (quotient ns NS/HOUR)]
         [ns (- ns (* h NS/HOUR))]
         [m (quotient ns NS/MINUTE)]
         [ns (- ns (* m NS/MINUTE))]
         [s (quotient ns NS/SECOND)]
         [ns (- ns (* s NS/SECOND))])
    (HMSN h m s ns)))
