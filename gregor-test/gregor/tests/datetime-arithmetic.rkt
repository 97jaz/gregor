#lang racket/base

(require rackunit
         rackunit/text-ui
         gregor
         gregor/time
         gregor/period)

(run-tests
 (test-suite "[datetime arithemtic]"

   (test-case "+period"
     (check-equal? (+period (datetime 1970) (period [years 5] [hours 2]))
                   (datetime 1975 1 1 2 0))
     (check-equal? (+period (moment 1970 #:tz "UTC") (period [years 5] [hours 2]))
                   (moment 1975 1 1 2 0 #:tz "UTC")))

   (test-case "-period"
     (check-equal? (-period (datetime 2010 12 10 18) (period [years 1] [weeks -2] [minutes 100]))
                   (-minutes (+weeks (-years (datetime 2010 12 10 18) 1) 2) 100)))))
