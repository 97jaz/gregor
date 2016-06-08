#lang racket/base

(require rackunit
         rackunit/text-ui
         gregor
         gregor/time
         gregor/period)

(run-tests
 (test-suite "[time arithmetic]"

   (test-case "+hours"
     (check-equal? (+hours (time 0) 36) (time 12))
     (check-equal? (+hours (time 12) -4) (time 8))
     (check-equal? (+hours (datetime 2000 2 2 15 30 20) 26) (datetime 2000 2 3 17 30 20))
     (check-equal? (+hours (moment 2015 3 8 1 #:tz "America/New_York") 1)
                   (moment 2015 3 8 3 #:tz "America/New_York"))
     (check-equal? (+hours (moment 2015 3 8 1 #:tz -18000) 1)
                   (moment 2015 3 8 2 #:tz -18000)))

   (test-case "-hours"
     (check-equal? (-hours (time 0) 36) (time 12))
     (check-equal? (-hours (time 12) -4) (time 16))
     (check-equal? (-hours (datetime 2000 2 2 15 30 20) 26) (datetime 2000 2 1 13 30 20))
     (check-equal? (-hours (moment 2015 3 8 3 #:tz "America/New_York") 1)
                   (moment 2015 3 8 1 #:tz "America/New_York"))
     (check-equal? (-hours (moment 2015 3 8 2 #:tz -18000) 1)
                   (moment 2015 3 8 1 #:tz -18000)))

   (test-case "+minutes"
     (check-equal? (+minutes (time 0) 121) (time 2 1))
     (check-equal? (+minutes (datetime 2000 2 28 23 59) 1) (datetime 2000 2 29))
     (check-equal? (+minutes (moment 1970 #:tz "Etc/UTC") -12)
                   (moment 1969 12 31 23 48 #:tz "Etc/UTC"))
     (check-equal? (+minutes (moment 1970 #:tz 0) -12)
                   (moment 1969 12 31 23 48 #:tz 0)))

   (test-case "-minutes"
     (check-equal? (-minutes (time 0) 121) (time 21 59))
     (check-equal? (-minutes (datetime 2000 2 29) 1) (datetime 2000 2 28 23 59) 1)
     (check-equal? (-minutes (moment 1970 #:tz "Etc/UTC") -12)
                   (moment 1970 1 1 0 12 #:tz "Etc/UTC"))
     (check-equal? (-minutes (moment 1970 #:tz 0) -12)
                   (moment 1970 1 1 0 12 #:tz 0)))

   (test-case "+seconds"
     (check-equal? (+seconds (time 0) 121) (time 0 2 1))
     (check-equal? (+seconds (datetime 2000 2 28 23 59 59) 1) (datetime 2000 2 29))
     (check-equal? (+seconds (moment 1970 #:tz "Etc/UTC") -12)
                   (moment 1969 12 31 23 59 48 #:tz "Etc/UTC"))
     (check-equal? (+seconds (moment 1970 #:tz 0) -12)
                   (moment 1969 12 31 23 59 48 #:tz 0)))

   (test-case "-seconds"
     (check-equal? (-seconds (time 0) 121) (time 23 57 59))
     (check-equal? (-seconds (datetime 2000 2 29) 1) (datetime 2000 2 28 23 59 59) 1)
     (check-equal? (-seconds (moment 1970 #:tz "Etc/UTC") -12)
                   (moment 1970 1 1 0 0 12 #:tz "Etc/UTC"))
     (check-equal? (-seconds (moment 1970 #:tz 0) -12)
                   (moment 1970 1 1 0 0 12 #:tz 0)))

   (test-case "+milliseconds"
     (check-equal? (+milliseconds (time 0) 121) (time 0 0 0 121000000))
     (check-equal? (+milliseconds (datetime 2000 2 28 23 59 59) 1)
                   (datetime 2000 2 28 23 59 59 1000000))
     (check-equal? (+milliseconds (moment 1970 #:tz "Etc/UTC") -12)
                   (moment 1969 12 31 23 59 59 988000000 #:tz "Etc/UTC"))
     (check-equal? (+milliseconds (moment 1970 #:tz 0) -12)
                   (moment 1969 12 31 23 59 59 988000000 #:tz 0)))

   (test-case "-milliseconds"
     (check-equal? (-milliseconds (time 0) 121) (time 23 59 59 879000000))
     (check-equal? (-milliseconds (datetime 2000 2 29) 1)
                   (datetime 2000 2 28 23 59 59 999000000))
     (check-equal? (-milliseconds (moment 1970 #:tz "Etc/UTC") -12)
                   (moment 1970 1 1 0 0 0 12000000 #:tz "Etc/UTC"))
     (check-equal? (-milliseconds (moment 1970 #:tz 0) -12)
                   (moment 1970 1 1 0 0 0 12000000 #:tz 0)))

   (test-case "+mircoseconds"
     (check-equal? (+microseconds (time 0) 121) (time 0 0 0 121000))
     (check-equal? (+microseconds (datetime 2000 2 28 23 59 59) 1)
                   (datetime 2000 2 28 23 59 59 1000))
     (check-equal? (+microseconds (moment 1970 #:tz "Etc/UTC") -12)
                   (moment 1969 12 31 23 59 59 999988000 #:tz "Etc/UTC"))
     (check-equal? (+microseconds (moment 1970 #:tz 0) -12)
                   (moment 1969 12 31 23 59 59 999988000 #:tz 0)))

   (test-case "-microseconds"
     (check-equal? (-microseconds (time 0) 121) (time 23 59 59 999879000))
     (check-equal? (-microseconds (datetime 2000 2 29) 1)
                   (datetime 2000 2 28 23 59 59 999999000))
     (check-equal? (-microseconds (moment 1970 #:tz "Etc/UTC") -12)
                   (moment 1970 1 1 0 0 0 12000 #:tz "Etc/UTC"))
     (check-equal? (-microseconds (moment 1970 #:tz 0) -12)
                   (moment 1970 1 1 0 0 0 12000 #:tz 0)))

   (test-case "+nanoseconds"
     (check-equal? (+nanoseconds (time 0) 121) (time 0 0 0 121))
     (check-equal? (+nanoseconds (datetime 2000 2 28 23 59 59) 1)
                   (datetime 2000 2 28 23 59 59 1))
     (check-equal? (+nanoseconds (moment 1970 #:tz "Etc/UTC") -12)
                   (moment 1969 12 31 23 59 59 999999988 #:tz "Etc/UTC"))
     (check-equal? (+nanoseconds (moment 1970 #:tz 0) -12)
                   (moment 1969 12 31 23 59 59 999999988 #:tz 0)))

   (test-case "-nanoseconds"
     (check-equal? (-nanoseconds (time 0) 121) (time 23 59 59 999999879))
     (check-equal? (-nanoseconds (datetime 2000 2 29) 1)
                   (datetime 2000 2 28 23 59 59 999999999))
     (check-equal? (-nanoseconds (moment 1970 #:tz "Etc/UTC") -12)
                   (moment 1970 1 1 0 0 0 12 #:tz "Etc/UTC"))
     (check-equal? (-nanoseconds (moment 1970 #:tz 0) -12)
                   (moment 1970 1 1 0 0 0 12 #:tz 0)))

   (test-case "+time-period"
     (check-equal? (+time-period (time 15 30) (hours -70)) (-hours (time 15 30) 70))
     (check-equal? (+time-period (datetime 2000 9 9 8 30 28 6789) (period [hours -345] [minutes 7364] [seconds 9907] [nanoseconds -3000000000000]))
                   (-nanoseconds (+seconds (+minutes (-hours (datetime 2000 9 9 8 30 28 6789) 345) 7364) 9907) 3000000000000))
     (check-equal? (+time-period (moment 1970 #:tz "Etc/UTC") (period [hours 8] [minutes 10]))
                   (moment 1970 1 1 8 10 #:tz "Etc/UTC"))
     (check-equal? (+time-period (moment 1970 #:tz 0) (period [hours 8] [minutes 10]))
                   (moment 1970 1 1 8 10 #:tz 0)))

   (test-case "-time-period"
     (check-equal? (-time-period (time 15 30) (hours 70)) (+hours (time 15 30) -70))
     (check-equal? (-time-period (datetime 2000 9 9 8 30 28 6789)
                                 (negate-period (period [hours -345] [minutes 7364] [seconds 9907] [nanoseconds -3000000000000])))
                   (-nanoseconds (+seconds (+minutes (-hours (datetime 2000 9 9 8 30 28 6789) 345) 7364) 9907) 3000000000000))
     (check-equal? (-time-period (moment 1970 1 1 8 10 #:tz "Etc/UTC") (period [hours 8] [minutes 10]))
                   (moment 1970 #:tz "Etc/UTC"))
     (check-equal? (-time-period (moment 1970 1 1 8 10 #:tz 0) (period [hours 8] [minutes 10]))
                   (moment 1970 #:tz 0)))))
