#lang racket/base

(require rackunit
         rackunit/text-ui
         gregor)

(run-tests
 (test-suite "[query]"
   (test-case "leap-year?"
     (check-false (leap-year? 1900))
     (check-true (leap-year? 2000))
     (check-false (leap-year? 2015))
     (check-true (leap-year? 2016))
     (check-true (leap-year? -4)))

   (test-case "days-in-year"
     (check-equal? (days-in-year 1900) 365)
     (check-equal? (days-in-year 2000) 366)
     (check-equal? (days-in-year 2015) 365)
     (check-equal? (days-in-year 2016) 366)
     (check-equal? (days-in-year -4) 366))

   (test-case "days-in-month"
     (check-equal? (days-in-month 2015 2) 28)
     (check-equal? (days-in-month 2016 2) 29)
     (check-equal? (days-in-month 2016 6) 30)
     (check-equal? (days-in-month 2016 8) 31))

   (test-case "iso-weeks-in-year"
     (check-equal? (iso-weeks-in-year 2000) 52)
     (check-equal? (iso-weeks-in-year 2004) 53)
     (check-equal? (iso-weeks-in-year 2015) 53)
     (check-equal? (iso-weeks-in-year 2016) 52))))
