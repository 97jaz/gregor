#lang racket/base

(require racket/contract/base
         racket/match
         racket/serialize
         data/order
         tzinfo
         "core/compare.rkt"
         "core/hmsn.rkt"
         "core/ymd.rkt"
         "datetime.rkt"
         "offset-resolvers.rkt"
         "moment-base.rkt")

(define current-timezone (make-parameter (system-tzid)))

(define (moment year [month 1] [day 1] [hour 0] [minute 0] [second 0] [nano 0]
                #:tz [tz (current-timezone)]
                #:resolve-offset [resolve resolve-offset/raise])
  (datetime+tz->moment (datetime year month day hour minute second nano) tz resolve))

(define (datetime+tz->moment dt zone resolve)
  (cond [(string? zone)
         (define res (local-seconds->tzoffset zone (datetime->posix dt)))
         
         (match res
           [(tzoffset sec _ _) (make-moment dt sec zone)]
           [_                  (resolve res dt zone #f)])]
        [else
         (make-moment dt zone #f)]))


(define moment->datetime/local Moment-datetime/local)
(define moment->utc-offset     Moment-utc-offset)
(define moment->tzid           Moment-zone)

(define (moment->timezone m)
  (or (moment->tzid m)
      (moment->utc-offset m)))

(define (moment-in-utc m)
  (if (equal? UTC (moment->timezone m))
      m
      (timezone-adjust m UTC)))

(define moment->jd
  (compose1 datetime->jd
            moment->datetime/local
            moment-in-utc))

(define moment->posix
  (compose1 datetime->posix
            moment->datetime/local
            moment-in-utc))

(define (posix->moment p z)
  (define off
    (cond [(string? z) (tzoffset-utc-seconds (utc-seconds->tzoffset z p))]
          [else        z]))
  (define dt (posix->datetime (+ p off)))
  (make-moment dt off z))

(define (moment-add-nanoseconds m n)
  (posix->moment (+ (moment->posix m) (* n (/ 1 NS/SECOND)))
                 (moment->timezone m)))

(define (timezone-adjust m z)
  (match-define (Moment dt neg-sec _) m)
  (define dt/utc (datetime-add-seconds dt (- neg-sec)))
  
  (cond [(string? z)
         (define posix (datetime->posix dt/utc))
         (match-define (tzoffset offset _ _) (utc-seconds->tzoffset z posix))
         (define local (datetime-add-seconds dt/utc offset))
         (make-moment local offset z)]
        [else
         (define local (datetime-add-seconds dt/utc z))
         (make-moment local z #f)]))


(define (timezone-coerce m z #:resolve-offset [resolve resolve-offset/raise])
  (datetime+tz->moment (moment->datetime/local m) z resolve))

(match-define (comparison moment=? moment<? moment<=? moment>? moment>=? moment-comparator moment-order)
  (build-comparison 'moment-order moment? moment->jd))

(define UTC "Etc/UTC")

(define tz/c (or/c string?
                   (integer-in -64800 64800)))

(provide tz/c)

(provide/contract
 [current-timezone       (parameter/c tz/c)]
 [moment?                (-> any/c boolean?)]
 [moment                 (->i ([year exact-integer?])
                              ([month (integer-in 1 12)]
                               [day (year month) (day-of-month/c year month)]
                               [hour (integer-in 0 23)]
                               [minute (integer-in 0 59)]
                               [second (integer-in 0 59)]
                               [nanosecond (integer-in 0 (sub1 NS/SECOND))]
                               #:tz [tz tz/c]
                               #:resolve-offset [resolve offset-resolver/c])
                              [res moment?])]
 [datetime+tz->moment    (-> datetime? tz/c offset-resolver/c moment?)]
 [moment->iso8601        (-> moment? string?)]
 [moment->iso8601/tzid   (-> moment? string?)]
 [moment->datetime/local (-> moment? datetime?)]
 [moment->utc-offset     (-> moment? exact-integer?)]
 [moment->timezone       (-> moment? tz/c)]
 [moment->tzid           (-> moment? (or/c string? #f))]
 [moment->jd             (-> moment? rational?)]
 [moment->posix          (-> moment? rational?)]
 [posix->moment          (-> rational? tz/c moment?)]
 [moment-add-nanoseconds (-> moment? exact-integer? moment?)]
 [moment-in-utc          (-> moment? moment?)]
 [timezone-adjust        (-> moment? tz/c moment?)]
 [timezone-coerce        (->i ([m moment?]
                               [z tz/c])
                              (#:resolve-offset [r offset-resolver/c])
                              [res moment?])]
 [moment=?               (-> moment? moment? boolean?)]
 [moment<?               (-> moment? moment? boolean?)]
 [moment<=?              (-> moment? moment? boolean?)]
 [moment>?               (-> moment? moment? boolean?)]
 [moment>=?              (-> moment? moment? boolean?)]
 [moment-order           order?]
 [UTC                    tz/c])
 