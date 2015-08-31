#lang racket/base

(require racket/contract/base
         racket/list
         "private/generics.rkt"
         "private/period.rkt")

(define (date-period-between t1 t2 [fields date-units])
  (generic-period-between t1 t2 fields date-units))

(define (time-period-between t1 t2 [fields time-units])
  (generic-period-between t1 t2 fields time-units))

(define (period-between t1 t2 [fields temporal-units])
  (define-values (date-fields time-fields) (partition (λ (f) (memq f date-units)) fields))
  (define dp (date-period-between t1 t2 date-fields))
  (define t (+date-period t1 dp))

  (cond [(time-provider? t)
         (period dp (time-period-between t t2 time-fields))]
        [else
         dp]))

(define (generic-period-between t1 t2 fields all-fields)
  (define-values (result _)
    (for/fold ([p empty-period] [t t1]) ([f (in-list all-fields)])
      (cond [(memq f fields)
             (define-values (add between) (field->arith f))
             (define val (between t t2))
             (values (period-set p f val)
                     (add t val))]
            [else
             (values p t)])))

  result)

(define (field->arith f)
  (case f
    [(years)        (values +years years-between)]
    [(months)       (values +months months-between)]
    [(weeks)        (values +weeks weeks-between)]
    [(days)         (values +days days-between)]
    [(hours)        (values +hours hours-between)]
    [(minutes)      (values +minutes minutes-between)]
    [(seconds)      (values +seconds seconds-between)]
    [(milliseconds) (values +milliseconds milliseconds-between)]
    [(microseconds) (values +microseconds microseconds-between)]
    [(nanoseconds)  (values +nanoseconds nanoseconds-between)]))

(provide/contract
 [date-period-between (->* (date-provider? date-provider?) [(listof date-unit/c)] date-period?)]
 [time-period-between (->* (time-provider? time-provider?) [(listof time-unit/c)] time-period?)]
 [period-between      (->* (datetime-provider? datetime-provider?) [(listof temporal-unit/c)] period?)])

(provide
 period

 (recontract-out
  period?
  date-period?
  time-period?
  period-empty?
  empty-period
  negate-period
  period-ref
  period-set
  period->list
  period->date-period
  period->time-period
  years
  months
  weeks
  days
  hours
  minutes
  seconds
  milliseconds
  microseconds
  nanoseconds
  date-units
  time-units
  temporal-units
  date-unit/c
  time-unit/c
  temporal-unit/c))
