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

   (test-case "+hours"
     (check-equal? (+hours (time 0) 36) (time 12))
     (check-equal? (+hours (time 12) -4) (time 8))
     (check-equal? (+hours (datetime 2000 2 2 15 30 20) 26) (datetime 2000 2 3 17 30 20))
     (check-equal? (+hours (moment 2015 3 8 1 #:tz "America/New_York") 1)
                   (moment 2015 3 8 3 #:tz "America/New_York")))

   (test-case "-hours"
     (check-equal? (-hours (time 0) 36) (time 12))
     (check-equal? (-hours (time 12) -4) (time 16))
     (check-equal? (-hours (datetime 2000 2 2 15 30 20) 26) (datetime 2000 2 1 13 30 20))
     (check-equal? (-hours (moment 2015 3 8 3 #:tz "America/New_York") 1)
                   (moment 2015 3 8 1 #:tz "America/New_York")))

   (test-case "+minutes"
     (check-equal? (+minutes (time 0) 121) (time 2 1))
     (check-equal? (+minutes (datetime 2000 2 28 23 59) 1) (datetime 2000 2 29))
     (check-equal? (+minutes (moment 1970 #:tz "Etc/UTC") -12)
                   (moment 1969 12 31 23 48 #:tz "Etc/UTC")))

   (test-case "-minutes"
     (check-equal? (-minutes (time 0) 121) (time 21 59))
     (check-equal? (-minutes (datetime 2000 2 29) 1) (datetime 2000 2 28 23 59) 1)
     (check-equal? (-minutes (moment 1970 #:tz "Etc/UTC") -12)
                   (moment 1970 1 1 0 12 #:tz "Etc/UTC")))

   (test-case "+seconds"
     (check-equal? (+seconds (time 0) 121) (time 0 2 1))
     (check-equal? (+seconds (datetime 2000 2 28 23 59 59) 1) (datetime 2000 2 29))
     (check-equal? (+seconds (moment 1970 #:tz "Etc/UTC") -12)
                   (moment 1969 12 31 23 59 48 #:tz "Etc/UTC")))

   (test-case "-seconds"
     (check-equal? (-seconds (time 0) 121) (time 23 57 59))
     (check-equal? (-seconds (datetime 2000 2 29) 1) (datetime 2000 2 28 23 59 59) 1)
     (check-equal? (-seconds (moment 1970 #:tz "Etc/UTC") -12)
                   (moment 1970 1 1 0 0 12 #:tz "Etc/UTC")))

   (test-case "+milliseconds"
     (check-equal? (+milliseconds (time 0) 121) (time 0 0 0 121000000))
     (check-equal? (+milliseconds (datetime 2000 2 28 23 59 59) 1)
                   (datetime 2000 2 28 23 59 59 1000000))
     (check-equal? (+milliseconds (moment 1970 #:tz "Etc/UTC") -12)
                   (moment 1969 12 31 23 59 59 988000000 #:tz "Etc/UTC")))

   (test-case "-milliseconds"
     (check-equal? (-milliseconds (time 0) 121) (time 23 59 59 879000000))
     (check-equal? (-milliseconds (datetime 2000 2 29) 1)
                   (datetime 2000 2 28 23 59 59 999000000))
     (check-equal? (-milliseconds (moment 1970 #:tz "Etc/UTC") -12)
                   (moment 1970 1 1 0 0 0 12000000 #:tz "Etc/UTC")))

   (test-case "+mircoseconds"
     (check-equal? (+microseconds (time 0) 121) (time 0 0 0 121000))
     (check-equal? (+microseconds (datetime 2000 2 28 23 59 59) 1)
                   (datetime 2000 2 28 23 59 59 1000))
     (check-equal? (+microseconds (moment 1970 #:tz "Etc/UTC") -12)
                   (moment 1969 12 31 23 59 59 999988000 #:tz "Etc/UTC")))

   (test-case "-microseconds"
     (check-equal? (-microseconds (time 0) 121) (time 23 59 59 999879000))
     (check-equal? (-microseconds (datetime 2000 2 29) 1)
                   (datetime 2000 2 28 23 59 59 999999000))
     (check-equal? (-microseconds (moment 1970 #:tz "Etc/UTC") -12)
                   (moment 1970 1 1 0 0 0 12000 #:tz "Etc/UTC")))

   (test-case "+nanoseconds"
     (check-equal? (+nanoseconds (time 0) 121) (time 0 0 0 121))
     (check-equal? (+nanoseconds (datetime 2000 2 28 23 59 59) 1)
                   (datetime 2000 2 28 23 59 59 1))
     (check-equal? (+nanoseconds (moment 1970 #:tz "Etc/UTC") -12)
                   (moment 1969 12 31 23 59 59 999999988 #:tz "Etc/UTC")))

   (test-case "-nanoseconds"
     (check-equal? (-nanoseconds (time 0) 121) (time 23 59 59 999999879))
     (check-equal? (-nanoseconds (datetime 2000 2 29) 1)
                   (datetime 2000 2 28 23 59 59 999999999))
     (check-equal? (-nanoseconds (moment 1970 #:tz "Etc/UTC") -12)
                   (moment 1970 1 1 0 0 0 12 #:tz "Etc/UTC")))

   (test-case "on-date"
     (check-equal? (on-date (time 0) (date 1970)) (datetime 1970))
     (check-equal? (on-date (datetime 1 2 3 4 5 6 7) (date 2020 12 20))
                   (datetime 2020 12 20 4 5 6 7))
     (check-exn exn:gregor:invalid-offset?
                (λ ()
                  (on-date (moment 2000 1 1 2 #:tz "America/New_York")
                           (date 2015 3 8)
                           #:resolve-offset resolve-offset/raise))))))
