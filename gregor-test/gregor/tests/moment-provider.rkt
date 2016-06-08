#lang racket/base

(require rackunit
         rackunit/text-ui
         racket/serialize
         gregor)

(run-tests
 (test-suite "[moment providers]"

   (test-case "moment-provider?"
     (check-true (moment-provider? (moment 2000 #:tz "Etc/UTC")))
     (check-true (moment-provider? (moment 2000 #:tz -18000)))
     (check-false (moment-provider? (datetime 2000))))

   (test-case "->moment"
     (check-equal? (->moment (moment 2000 #:tz "America/New_York"))
                   (moment 2000 #:tz "America/New_York"))
     (check-equal? (->moment (moment 2000 #:tz -18000))
                   (moment 2000 #:tz -18000)))

   (test-case "->utc-offset"
     (check-equal? (->utc-offset (moment 2000 #:tz "America/New_York"))
                   -18000)
     (check-equal? (->utc-offset (moment 2000 6 #:tz "America/New_York"))
                   -14400)
     (check-equal? (->utc-offset (moment 2000 6 #:tz -18000))
                   -18000))

   (test-case "->timezone"
     (check-equal? (->timezone (moment 2000 #:tz "America/New_York"))
                   "America/New_York")
     (check-equal? (->timezone (moment 2000 6 #:tz -18000))
                   -18000))

   (test-case "->tzid"
     (check-equal? (->tzid (moment 2000 #:tz "America/New_York"))
                   "America/New_York")
     (check-false (->tzid (moment 2000 6 #:tz -18000))))

   (test-case "adjust-timezone"
     (check-equal? (adjust-timezone
                    (moment 2000 #:tz "America/New_York")
                    "Etc/UTC")
                   (moment 2000 1 1 5 #:tz "Etc/UTC"))
     (check-equal? (adjust-timezone
                    (moment 2000 #:tz -18000)
                    "Etc/UTC")
                   (moment 2000 1 1 5 #:tz "Etc/UTC"))
     (check-equal? (adjust-timezone
                    (moment 2015 3 16 23 38 #:tz "America/Los_Angeles")
                    "America/New_York")
                   (moment 2015 3 17 2 38 #:tz "America/New_York"))
     (check-equal? (adjust-timezone
                    (moment 2015 3 16 23 38 #:tz "America/Los_Angeles")
                    -18000)
                   (moment 2015 3 17 1 38 #:tz -18000)))))
