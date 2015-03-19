#lang racket/base

(require rackunit
         rackunit/text-ui
         gregor
         gregor/time)

(run-tests
 (test-suite "[clock]"
   (parameterize ([current-clock (λ () 1)])

     (test-case "today"
       (check-equal? (today/utc) (date 1970))
       (check-equal? (today #:tz "America/Chicago") (date 1969 12 31)))

     (test-case "current-time"
       (check-equal? (current-time/utc) (time 0 0 1))
       (check-equal? (current-time #:tz "America/Chicago") (time 18 0 1)))

     (test-case "now"
       (check-equal? (now/utc) (datetime 1970 1 1 0 0 1))
       (check-equal? (now #:tz "America/Chicago") (datetime 1969 12 31 18 0 1)))

     (test-case "moment"
       (check-equal? (now/moment/utc) (moment 1970 1 1 0 0 1 #:tz UTC))
       (check-equal? (now/moment #:tz "America/Chicago")
                     (moment 1969 12 31 18 0 1 #:tz "America/Chicago"))))))
