#lang racket/base

(require racket/contract/base
         racket/match
         "datetime.rkt"
         "generics.rkt")

(provide duration-between
         temporal-unit/c)

(struct U (name add between))

(define units
  (list (U 'years +years years-between)
        (U 'months +months months-between)
        (U 'weeks +weeks weeks-between)
        (U 'days +days days-between)
        (U 'hours +hours hours-between)
        (U 'minutes +minutes minutes-between)
        (U 'seconds +seconds seconds-between)
        (U 'milliseconds +milliseconds milliseconds-between)
        (U 'microseconds +microseconds microseconds-between)
        (U 'nanoseconds +nanoseconds nanoseconds-between)))

(define temporal-unit/c
  (symbols 'years 'months 'weeks 'days
           'hours 'minutes 'seconds
           'milliseconds 'microseconds 'nanoseconds))

(define (duration-between x y fields)
  (define-values (sign t1 t2)
    (let ([t1 (->datetime/utc x)]
          [t2 (->datetime/utc y)])
      (if (datetime<? t2 t1)
          (values '- t2 t1)
          (values '+ t1 t2))))
  
  (define (find-unit u)
    (and (findf (λ (f) (eq? f (U-name u))) fields)
         u))
  
  (let loop ([res '()] [start t1] [xs units])
    (match xs
      [(list)
       (cons (cons 'sign sign) (reverse res))]
      [(cons (app find-unit (U name add between)) xs)
       (define val (between start t2))
       (loop (cons (cons name val) res) (add start val) xs)]
      [(cons _ xs)
       (loop res start xs)])))
