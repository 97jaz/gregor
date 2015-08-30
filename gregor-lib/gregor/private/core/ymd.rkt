#lang racket/base

(require racket/contract/base
         racket/match
         racket/math
         "structs.rkt"
         "math.rkt")

(provide/contract
 [ymd->jdn          (-> YMD? exact-integer?)]
 [jdn->ymd          (-> exact-integer? YMD?)]
 [jdn->wday         (-> exact-integer? (integer-in 0 6))]
 [jdn->iso-wday     (-> exact-integer? (integer-in 1 7))]
 [ymd->yday         (-> YMD? (integer-in 1 366))]
 [ymd->quarter      (-> YMD? (integer-in 1 4))]
 [ymd-add-years     (-> YMD? exact-integer? YMD?)]
 [ymd-add-months    (-> YMD? exact-integer? YMD?)]
 [leap-year?        (-> exact-integer? boolean?)]
 [days-in-month     (-> exact-integer? (integer-in 1 12) (integer-in 28 31))]
 [days-in-year      (-> exact-integer? (or/c 365 366))]
 [iso-weeks-in-year (-> exact-integer? (or/c 52 53))]
 [day-of-month/c    any/c])


(define (ymd->jdn ymd)
  (match-define (YMD y m d) ymd)
  (let-values ([(y m) (if (< m 3)
                          (values (sub1 y) (+ m 12))
                          (values y m))])
    (+ d
       (exact-truncate
        (/
         (- (* 153 m) 457)
         5))
       (* 365 y)
       (exact-floor
        (/ y 4))
       (-
        (exact-floor
         (/ y 100)))
       (exact-floor
        (/ y 400))
       1721119)))

(define (jdn->ymd jdn)
  (let* ([x (exact-floor (/ (- jdn 1867216.25) 36524.25))]
         [a (+ jdn 1 x (- (exact-floor (/ x 4))))]
         [b (+ a 1524)]
         [c (exact-floor (/ (- b 122.1) 365.25))]
         [d (exact-floor (* 365.25 c))]
         [e (exact-floor (/ (- b d) 30.6001))]
         [dom (- b d (exact-floor (* 30.6001 e)))])
    (let-values ([(m y) (if (<= e 13)
                            (values (sub1 e) (- c 4716))
                            (values (- e 13) (- c 4715)))])
      (YMD y m dom))))

(define (jdn->wday jdn)
  (mod (add1 jdn) 7))

(define (jdn->iso-wday jdn)
  (mod1 (jdn->wday jdn) 7))

(define (ymd->yday ymd)
  (match-define (YMD y m d) ymd)
  (+ d
     (if (leap-year? y)
         (vector-ref CUMULATIVE-MONTH-DAYS/LEAP (sub1 m))
         (vector-ref CUMULATIVE-MONTH-DAYS (sub1 m)))))

(define (ymd->quarter ymd)
  (add1 (quotient (sub1 (YMD-m ymd)) 3)))

(define (ymd-add-years ymd n)
  (match-define (YMD y m d) ymd)
  (define ny (+ y n))
  (define max-dom (days-in-month ny m))
  (YMD ny m (if (<= d max-dom) d max-dom)))

(define (ymd-add-months ymd n)
  (match-define (YMD y m d) ymd)
  (define ny (+ y (div (+ m n -1) 12)))
  (define nm (let ([v (mod1 (+ m n) 12)])
               (if (< v 0)
                   (+ 12 v)
                   v)))
  (define max-dom (days-in-month ny nm))
  (YMD ny nm (if (<= d max-dom) d max-dom)))

(define (leap-year? y)
  (and (zero? (remainder y 4))
       (or (not (zero? (remainder y 100)))
           (zero? (remainder y 400)))))

(define (days-in-year y)
  (if (leap-year? y) 366 365))

(define (days-in-month y m)
  (let ([delta (if (and (= m 2)
                        (leap-year? y))
                   1
                   0)])
    (+ (vector-ref DAYS-PER-MONTH m) delta)))

(define (day-of-month/c y m)
  (integer-in 1 (days-in-month y m)))

(define (iso-weeks-in-year y)
  (define w (jdn->wday (ymd->jdn (YMD y 1 1))))

  (cond [(or (= w 4)
             (and (leap-year? y) (= w  3)))
         53]
        [else
         52]))


(define DAYS-PER-MONTH
  (vector 0 31 28 31 30 31 30 31 31 30 31 30 31))

(define CUMULATIVE-MONTH-DAYS
  (vector 0 31 59 90 120 151 181 212 243 273 304 334))

(define CUMULATIVE-MONTH-DAYS/LEAP
  (vector 0 31 60 91 121 152 182 213 244 274 305 335))
