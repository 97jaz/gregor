#lang racket/base

(require rackunit
         rackunit/text-ui
         racket/serialize
         gregor)

(run-tests
 (test-suite "[moments]"

   (test-case "moment?"
     (check-true (moment? (moment 0)))
     (check-false (moment? "foo")))

   (test-suite "moment struct"
     (let* ([t1 (moment 1970 #:tz "Etc/UTC")]
            [t2 (moment 1969 12 31 19 #:tz "America/New_York")]
            [t3 (moment 1969 12 31 16 #:tz "America/Los_Angeles")]
            [t4 (moment 1969 12 31 19 #:tz -18000)])

       (test-case "temporal equality"
         (check-true (moment=? t1 t2))
         (check-true (moment=? t1 t3))
         (check-true (moment=? t1 t4))
         (check-false (moment=? t1 (moment 2015 #:tz "Etc/UTC"))))

       (test-case "structural equality"
         (check-true (equal? t1 (moment 1970 1 1 #:tz "Etc/UTC")))
         (check-false (equal? t1 t2))
         (check-false (equal? t1 t4))
         (check-false (equal? t1 t3)))

       (test-case "serializability"
         (check-true (equal? t1 (deserialize (serialize t1))))
         (check-true (equal? t4 (deserialize (serialize t4))))
         (check-false (equal? (moment 2015 #:tz "Etc/UTC") (deserialize (serialize t3)))))))

   (test-case "moment->iso8601"
     (check-equal? (moment->iso8601 (moment 1969 12 31 19 #:tz "America/New_York"))
                   "1969-12-31T19:00:00-05:00")

     (let ([m (moment 2015 4 12 22 6 33 8026521 #:tz -14400)])
       (check-equal? (iso8601->moment (moment->iso8601 m)) m)))

   (test-case "moment->iso8601/tzid"
     (check-equal? (moment->iso8601/tzid (moment 1969 12 31 19 #:tz "America/New_York"))
                   "1969-12-31T19:00:00-05:00[America/New_York]")

     (let ([m (moment 2015 4 12 22 6 33 8026521 #:tz "America/New_York")])
       (check-equal? (iso8601/tzid->moment (moment->iso8601/tzid m)) m)))

   (test-case "posix->moment"
     (check-equal? (posix->moment 119731017 0)
                   (moment 1973 10 17 18 36 57 #:tz 0))
     (check-equal? (posix->moment 1e9 0)
                   (moment 2001 09 09 01 46 40 #:tz 0))
     (let ([t 1638492227])
       (check-true (moment=? (posix->moment t "Antarctica/Troll")
                             (posix->moment t 0)))))

   (test-suite "moment order"
     (let* ([t1 (moment -1000)]
            [t2 (moment 0)]
            [t3 (moment 1000)])
       (check-true (moment<? t1 t2))
       (check-true (moment<? t2 t3))
       (check-true (moment<=? t1 t3))
       (check-true (moment>? t2 t1))
       (check-true (moment>=? t3 t2))
       (check-false (moment=? t1 t3))

       (check-eq? (moment-order t1 t1) '=)
       (check-eq? (moment-order t1 t2) '<)
       (check-eq? (moment-order t2 t1) '>)))))
