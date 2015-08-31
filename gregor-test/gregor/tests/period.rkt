#lang racket/base

(require rackunit
         rackunit/text-ui
         racket/match
         gregor
         gregor/period)

(run-tests
 (test-suite "[periods]"

   (test-case "period?"
     (check-true (period? (years 3)))
     (check-false (period? "hi")))

   (test-case "date-period?"
     (check-true (date-period? (months 3)))
     (check-false (date-period? (hours 2)))
     (check-exn exn:fail:contract? (λ () (date-period? "hello"))))

   (test-case "time-period?"
     (check-false (time-period? (months 3)))
     (check-true (time-period? (hours 2)))
     (check-exn exn:fail:contract? (λ () (time-period? "hello"))))

   (test-case "period-empty?"
     (check-true (period-empty? (years 0)))
     (check-true (period-empty? empty-period))
     (check-false (period-empty? (nanoseconds -1))))

   (test-case "negate-period"
     (check-equal? (negate-period (days 8)) (days -8))
     (check-equal? (negate-period (days 0)) (days 0))
     (check-equal? (negate-period (period (years 8) (days -2) (seconds 3)))
                   (period (years -8) (days 2) (seconds -3))))

   (test-case "period->date-period"
     (check-equal? (period->date-period (period (years 8) (days -2) (seconds 3)))
                   (period (years 8) (days -2))))

   (test-case "period->time-period"
     (check-equal? (period->time-period (period (years 8) (days -2) (seconds 3)))
                   (seconds 3)))

   (test-case "period->list"
     (check-equal? (period->list (period (months 4) (weeks -9) (milliseconds 567)))
                   '((years . 0)
                     (months . 4)
                     (weeks . -9)
                     (days . 0)
                     (hours . 0)
                     (minutes . 0)
                     (seconds . 0)
                     (milliseconds . 567)
                     (microseconds . 0)
                     (nanoseconds . 0))))

   (test-case "period-ref"
     (check-equal? (period-ref (years 8) 'years) 8)
     (check-equal? (period-ref (years 8) 'seconds) 0))

   (test-case "period-set"
     (check-equal? (period-set (years 8) 'seconds -10)
                   (period (years 8) (seconds -10)))
     (check-equal? (period-set (years 8) 'years 0)
                   empty-period))

   (test-case "[simple constructors]"
     (for ([k (in-list (list years months weeks days hours minutes seconds milliseconds microseconds nanoseconds))])
       (check-true (period? (k 0)))))

   (test-case "period"
     (match (period [years 9] [days -8] [hours -100])
       [(period [days d] [seconds s])
        (check-equal? d -8)
        (check-equal? s 0)]))))
