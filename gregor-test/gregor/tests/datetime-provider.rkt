#lang racket/base

(require rackunit
         rackunit/text-ui
         gregor
         gregor/time)

(run-tests
 (test-suite "[datetime providers]"

   (test-case "datetime-provider?"
     (check-true (datetime-provider? (datetime 2000)))
     (check-true (datetime-provider? (moment 2000))))

   (test-case "->datetime/local"
     (check-equal? (->datetime/local (datetime 2000)) (datetime 2000))
     (check-equal? (->datetime/local (moment 2000 #:tz "America/New_York")) (datetime 2000)))

   (test-case "->datetime/utc"
     (check-equal? (->datetime/utc (datetime 2000)) (datetime 2000))
     (check-equal? (->datetime/utc (moment 2000 #:tz "America/New_York"))
                   (datetime 2000 1 1 5)))

   (test-case "->posix"
     (check-equal? (->posix (datetime 1970)) 0)
     (check-equal? (->posix (moment 1970 #:tz "Etc/UTC")) 0)
     (check-equal? (->posix (moment 1950 6 20 #:tz "America/New_York")) -616449600))

   (test-case "->jd"
     (check-equal? (->jd (datetime 1970)) (+ 2440587 1/2))
     (check-equal? (->jd (moment 2014 12 8 7 #:tz "America/New_York")) 2457000))

   (test-case "years-between"
     (check-equal? (years-between (datetime 0) (datetime 0)) 0)
     (check-equal? (years-between (datetime 0) (datetime 1970)) 1970)
     (check-equal? (years-between (datetime 1970 5 20) (datetime 1000)) -970)
     (check-equal? (years-between (moment 2000 #:tz "America/New_York")
                                  (moment 2001 #:tz "Etc/UTC"))
                   0)
     (check-equal? (years-between (moment 2000 #:tz "America/New_York")
                                  (moment 2001 1 1 5 #:tz "Etc/UTC"))
                   1))

   (test-case "months-between"
     (check-equal? (months-between (datetime 1970 1 1) (datetime 1968 6 20))
                   -18)
     (check-equal? (months-between (moment 2000 #:tz "Etc/UTC")
                                   (moment 2000 4 #:tz "America/New_York"))
                   3))

   (test-case "weeks-between"
     (check-equal? (weeks-between (datetime 2015 3 15) (datetime 2015 1 4))
                   -10)
     (check-equal? (weeks-between (moment 2015 3 15 #:tz "America/New_York")
                                  (moment 2015 5 29 #:tz "America/New_York"))
                   10))

   (test-case "days-between"
     (check-equal? (days-between (datetime 2000) (datetime 2001)) 366)
     (check-equal? (days-between (moment 2000 3 1 #:tz "Etc/UTC")
                                 (moment 2000 2 28 #:tz "Etc/UTC"))
                   -2))

   (test-case "hours-between"
     (check-equal? (hours-between (datetime 2000) (datetime 2000 1 1 13 59)) 13)
     (check-equal? (hours-between (moment 2015 3 8 1 #:tz "America/New_York")
                                  (moment 2015 3 8 3 #:tz "America/New_York"))
                   1)
     (check-equal? (hours-between (moment 2015 3 8 1 #:tz "Etc/UTC")
                                  (moment 2015 3 8 3 #:tz "Etc/UTC"))
                   2))

   (test-case "minutes-between"
     (check-equal? (minutes-between (datetime 2000) (datetime 2000 1 1 1)) 60)
     (check-equal? (minutes-between (moment 2000 #:tz "America/New_York")
                                    (moment 2000 #:tz "Etc/UTC"))
                   -300))

   (test-case "seconds-between"
     (check-equal? (seconds-between (datetime 2000) (datetime 2000 1 1 1)) 3600)
     (check-equal? (seconds-between (moment 2000 #:tz "America/New_York")
                                    (moment 2000 #:tz "Etc/UTC"))
                   -18000))

   (test-case "milliseconds-between"
     (check-equal? (milliseconds-between (datetime 2000) (datetime 2000 1 1 1)) 3600000)
     (check-equal? (milliseconds-between (moment 2000 #:tz "America/New_York")
                                         (moment 2000 #:tz "Etc/UTC"))
                   -18000000))

   (test-case "microseconds-between"
     (check-equal? (microseconds-between (datetime 2000) (datetime 2000 1 1 1)) 3600000000)
     (check-equal? (microseconds-between (moment 2000 #:tz "America/New_York")
                                         (moment 2000 #:tz "Etc/UTC"))
                   -18000000000))

   (test-case "nanoseconds-between"
     (check-equal? (nanoseconds-between (datetime 2000) (datetime 2000 1 1 1)) 3600000000000)
     (check-equal? (nanoseconds-between (moment 2000 #:tz "America/New_York")
                                        (moment 2000 #:tz "Etc/UTC"))
                   -18000000000000))))
