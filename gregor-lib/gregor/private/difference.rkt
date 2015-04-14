#lang racket/base

(require racket/contract/base
         racket/match
         racket/math
         "core/structs.rkt"
         "core/ymd.rkt"
         "core/hmsn.rkt"
         "date.rkt"
         "datetime.rkt")

;; difference
(define (datetime-months-between dt1 dt2)
  (cond [(datetime<? dt2 dt1)
         (- (datetime-months-between dt2 dt1))]
        [else
         (define d1 (datetime->date dt1))
         (define d2 (datetime->date dt2))

         (match* ((date->ymd d1) (date->ymd d2))
           [((YMD y1 m1 d1) (YMD y2 m2 d2))

            (define diff
              (+ (* (- y2 y1) 12)
                 m2
                 (- m1)))

            (define start-dom
              (if (and (> d1 d2)
                       (= (days-in-month y2 m2) d2))
                  d2
                  d1))

            (define dt1a (date+time->datetime (date y1 m1 start-dom) (datetime->time dt1)))

            (define ts1 (- (datetime->jd dt1a) (datetime->jd (datetime y1 m1))))
            (define ts2 (- (datetime->jd dt2)  (datetime->jd (datetime y2 m2))))

            (if (< ts2 ts1)
                (sub1 diff)
                diff)])]))

(define (datetime-days-between dt1 dt2)
  (exact-floor (- (datetime->jd dt2) (datetime->jd dt1))))

(define (datetime-nanoseconds-between dt1 dt2)
  (- (datetime->jdns dt2)
     (datetime->jdns dt1)))

(define (datetime->jdns dt)
  (exact-floor
   (* (datetime->jd dt) NS/DAY)))

(provide/contract
 [datetime-months-between      (-> datetime? datetime? exact-integer?)]
 [datetime-days-between        (-> datetime? datetime? exact-integer?)]
 [datetime-nanoseconds-between (-> datetime? datetime? exact-integer?)])
