#lang racket/base

(require rackunit
         rackunit/text-ui
         gregor
         gregor/time)

(run-tests
 (test-suite "[time providers]"

   (test-case "time-provider?"
     (check-false (time-provider? (date 2000)))
     (check-true (time-provider? (time 0)))
     (check-true (time-provider? (datetime 2000)))
     (check-true (time-provider? (moment 2000))))

   (test-case "->time"
     (check-equal? (->time (time 12)) (time 12))
     (check-equal? (->time (datetime 2000)) (time 0))
     (check-equal? (->time (moment 2000 1 1 13 14 15 16)) (time 13 14 15 16)))

   (test-case "->hours"
     (check-equal? (->hours (time 12)) 12)
     (check-equal? (->hours (datetime 2000 1 1 18)) 18)
     (check-equal? (->hours (moment 1000 12 12 5)) 5))

   (test-case "->minutes"
     (check-equal? (->minutes (time 12)) 0)
     (check-equal? (->minutes (datetime 2000 1 1 18 45)) 45)
     (check-equal? (->minutes (moment 1000 12 12 5 23)) 23))

   (test-case "->seconds"
     (check-equal? (->seconds (time 12)) 0)
     (check-equal? (->seconds (datetime 2000 1 1 18 45 20)) 20)
     (check-equal? (->seconds (moment 1000 12 12 5 23 1)) 1)

     (check-equal? (->seconds (time 12) #t) 0)
     (check-equal? (->seconds (datetime 2000 1 1 18 45 20 500000000) #t) (+ 20 1/2))
     (check-equal? (->seconds (moment 1000 12 12 5 23 1 1) #t) (+ 1 1/1000000000)))

   (test-case "->milliseconds"
     (check-equal? (->milliseconds (time 12)) 0)
     (check-equal? (->milliseconds (datetime 2000 1 1 0 0 0 500000000)) 500)
     (check-equal? (->milliseconds (moment 2000 1 1 0 0 0 1000000)) 1))

   (test-case "->microseconds"
     (check-equal? (->microseconds (time 12)) 0)
     (check-equal? (->microseconds (datetime 2000 1 1 0 0 0 500000000)) 500000)
     (check-equal? (->microseconds (moment 2000 1 1 0 0 0 1000000)) 1000))

   (test-case "->nanoseconds"
     (check-equal? (->nanoseconds (time 12)) 0)
     (check-equal? (->nanoseconds (datetime 2000 1 1 0 0 0 500000000)) 500000000)
     (check-equal? (->nanoseconds (moment 2000 1 1 0 0 0 1000000)) 1000000))

   (test-case "on-date"
     (check-equal? (on-date (time 0) (date 1970)) (datetime 1970))
     (check-equal? (on-date (datetime 1 2 3 4 5 6 7) (date 2020 12 20))
                   (datetime 2020 12 20 4 5 6 7))
     (check-exn exn:gregor:invalid-offset?
                (λ ()
                  (on-date (moment 2000 1 1 2 #:tz "America/New_York")
                           (date 2015 3 8)
                           #:resolve-offset resolve-offset/raise))))))
