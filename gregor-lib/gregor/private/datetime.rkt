#lang racket/base

(require racket/contract/base
         racket/match
         racket/math
         racket/serialize
         data/order
         "core/compare.rkt"
         "core/ymd.rkt"
         "core/hmsn.rkt"
         "date.rkt"
         "time.rkt")

(define (datetime-equal-proc x y _)
  (= (datetime->jd x)
     (datetime->jd y)))

(define (datetime-hash-proc x fn)
  (fn (datetime->jd x)))

(define (datetime-write-proc dt out mode)
  (fprintf out "#<datetime ~a>" (datetime->iso8601 dt)))

(struct DateTime (date time jd)
  #:methods gen:equal+hash
  [(define equal-proc datetime-equal-proc)
   (define hash-proc  datetime-hash-proc)
   (define hash2-proc datetime-hash-proc)]

  #:methods gen:custom-write
  [(define write-proc datetime-write-proc)]

  #:property prop:serializable
  (make-serialize-info (λ (dt) (vector (datetime->jd dt)))
                       #'deserialize-info:DateTime
                       #f
                       (or (current-load-relative-directory)
                           (current-directory))))

(define datetime? DateTime?)

(define datetime->date DateTime-date)
(define datetime->time DateTime-time)
(define datetime->jd   DateTime-jd)

(define (datetime->posix dt)
  (jd->posix (datetime->jd dt)))

(define (posix->datetime posix)
  (jd->datetime (posix->jd (inexact->exact posix))))

(define (date+time->datetime d t)
  (DateTime d t (date+time->jd d t)))

(define (jd->datetime jd)
  (define ejd (inexact->exact jd))
  (define-values (d t) (jd->date+time ejd))
  (date+time->datetime d t))

(define (datetime year [month 1] [day 1] [hour 0] [minute 0] [second 0] [nano 0])
  (date+time->datetime (date year month day)
                       (time hour minute second nano)))

(define (datetime->iso8601 dt)
  (format "~aT~a"
          (date->iso8601 (datetime->date dt))
          (time->iso8601 (datetime->time dt))))

(match-define (comparison datetime=? datetime<? datetime<=? datetime>? datetime>=? datetime-comparator datetime-order)
  (build-comparison 'datetime datetime? datetime->jd))

(define deserialize-info:DateTime
  (make-deserialize-info
   jd->datetime
   (λ () (error "DateTime cannot have cycles"))))

;; See racket/racket#4967
(provide deserialize-info:DateTime)

(module+ deserialize-info
  (provide deserialize-info:DateTime))


(define (date+time->jd d t)
  (define jdn    (date->jdn d))
  (define day-ns (time->ns t))

  (+ (- jdn 1/2)
     (/ day-ns NS/DAY)))

(define (jd->date+time jd)
  (define jdn    (jd->jdn jd))
  (define d      (jdn->date jdn))
  (define day-ns (jd->day-ns jd))
  (define t      (day-ns->time day-ns))

  (values d t))

(define (jd->jdn jd)
  (define lo (exact-floor jd))

  ;; math-class rounding: round up for >= 1/2
  (if (>= (- jd lo) 1/2)
      (add1 lo)
      lo))

(define (jd->day-ns jd)
  (define base (- jd 1/2))
  (define frac (- base (exact-floor base)))

  (exact-round (* frac NS/DAY)))

(define (jd->posix jd)
  (* 86400 (- jd (+ 2440587 1/2))))

(define (posix->jd posix)
  (+ (/ posix 86400) (+ 2440587 1/2)))

(define (datetime-add-nanoseconds dt n)
  (jd->datetime
   (+ (datetime->jd dt)
      (/ n NS/DAY))))

(define (datetime-add-seconds dt n)
  (datetime-add-nanoseconds dt (* n NS/SECOND)))


(provide/contract
 [datetime?                (-> any/c boolean?)]
 [datetime                 (->i ([year exact-integer?])
                                ([month (integer-in 1 12)]
                                 [day (year month) (day-of-month/c year month)]
                                 [hour (integer-in 0 23)]
                                 [minute (integer-in 0 59)]
                                 [second (integer-in 0 59)]
                                 [nanosecond (integer-in 0 (sub1 NS/SECOND))])
                                [dt datetime?])]
 [datetime->date           (-> datetime? date?)]
 [datetime->time           (-> datetime? time?)]
 [datetime->jd             (-> datetime? rational?)]
 [datetime->posix          (-> datetime? rational?)]
 [date+time->datetime      (-> date? time? datetime?)]
 [jd->datetime             (-> real? datetime?)]
 [posix->datetime          (-> real? datetime?)]
 [datetime->iso8601        (-> datetime? string?)]
 [datetime-add-nanoseconds (-> datetime? exact-integer? datetime?)]
 [datetime-add-seconds     (-> datetime? exact-integer? datetime?)]
 [datetime=?               (-> datetime? datetime? boolean?)]
 [datetime<?               (-> datetime? datetime? boolean?)]
 [datetime<=?              (-> datetime? datetime? boolean?)]
 [datetime>?               (-> datetime? datetime? boolean?)]
 [datetime>=?              (-> datetime? datetime? boolean?)]
 [datetime-order           order?])
