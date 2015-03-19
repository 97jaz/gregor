#lang racket/base

(require racket/contract/base
         "generics.rkt"
         "moment.rkt"
         "datetime.rkt"
         "date.rkt"
         "time.rkt")

(define (now/moment #:tz [tz (current-timezone)])
  (posix->moment ((current-clock)) tz))

(define (now/moment/utc)
  (now/moment #:tz "Etc/UTC"))

(define (now #:tz [tz (current-timezone)])
  (moment->datetime/local (now/moment #:tz tz)))

(define (now/utc)
  (now #:tz "Etc/UTC"))

(define (today #:tz [tz (current-timezone)])
  (datetime->date (now #:tz tz)))

(define (today/utc)
  (today #:tz "Etc/UTC"))

(define (current-time #:tz [tz (current-timezone)])
  (datetime->time (now #:tz tz)))

(define (current-time/utc)
  (current-time #:tz "Etc/UTC"))

(define (current-posix-seconds)
  (/ (inexact->exact (current-inexact-milliseconds)) 1000))

(define current-clock (make-parameter current-posix-seconds))

(provide/contract
 [current-clock    any/c]
 [current-posix-seconds any/c]
 [now/moment       (->i () (#:tz [tz tz/c]) [res moment?])]
 [now              (->i () (#:tz [tz tz/c]) [res datetime?])]
 [today            (->i () (#:tz [tz tz/c]) [res date?])]
 [current-time     (->i () (#:tz [tz tz/c]) [res time?])]
 [now/moment/utc   (-> moment?)]
 [now/utc          (-> datetime?)]
 [today/utc        (-> date?)]
 [current-time/utc (-> time?)])
