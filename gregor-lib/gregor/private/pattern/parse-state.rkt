#lang racket/base

(require racket/match
         "../moment.rkt"
         "../datetime.rkt"
         "../core/math.rkt"
         "../core/ymd.rkt")

(provide (all-defined-out))

(struct parse-state (input fields)
  #:transparent)

(define-syntax-rule (parse-state/ f)
  (λ (str fs val)
    (parse-state str (struct-copy fields fs [f val]))))

(define (parse-state/ignore str fs _)
  (parse-state str fs))

(struct fields (era year/era month day period hour/period minute second nano offset tzid)
  #:transparent)

(define (fresh-fields)
  (fields 1 #f #f #f 'am #f #f #f #f #f #f))

(define (set-fields-year/ext fs y)
  (cond [(positive? y)
         (struct-copy fields fs [era 1] [year/era y])]
        [else
         (struct-copy fields fs [era 0] [year/era (add1 (- y))])]))

(define (set-fields-hour/full fs h)
  (cond [(< h 12)
         (struct-copy fields fs [period 'am] [hour/period h])]
        [else
         (struct-copy fields fs [period 'pm] [hour/period (mod1 h 12)])]))

(define (fields->datetime+tz fs err)
  (match-define (fields era year month day period hour minute second nano offset tzid)
    fs)

  (unless year (err "Insufficient data in input to construct a temporal object"))

  (define y (if (= 0 era) (add1 (- year)) year))
  (define m (or month 1))
  (define d (or day 1))

  (when (> d (days-in-month y m))
    (err "Illegal date: year=~a, month=~a, day=~a" y m d))

  (cons (datetime y m d
                  (or (and hour
                           (+ (remainder hour 12) (if (eq? 'am period) 0 12)))
                      0)
                  (or minute 0)
                  (or second 0)
                  (or nano 0))
        (or tzid offset (current-timezone))))

(define (fields->time fs err)
  (match-define (cons dt _)
    (fields->datetime+tz (struct-copy fields fs [era 1] [year/era 1970]) err))
  
  (datetime->time dt))