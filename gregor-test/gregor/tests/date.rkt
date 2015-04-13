#lang racket/base

(require rackunit
         rackunit/text-ui
         racket/serialize
         gregor)

(run-tests
 (test-suite "[dates]"

   (test-case "date?"
     (check-true (date? (date 2000)))
     (check-false (date? "foo")))

   (test-suite "date struct"
     (let* ([d1 (date 1950 1 1)]
            [d2 (date 1950 1)]
            [d3 (date 1950)])

       (test-case "temporal equality"
         (check-true (date=? d1 d2))
         (check-true (date=? d1 d3))
         (check-false (date=? d1 (date 2000))))

       (test-case "structural equality"
         (check-true (equal? d1 d2))
         (check-true (equal? d1 d3))
         (check-false (equal? d1 (date 2000))))

       (test-case "serializability"
         (check-true (equal? d1 (deserialize (serialize d3))))
         (check-false (equal? (date 2000) (deserialize (serialize d3)))))))

   (test-case "date->iso8601"
     (check-equal? (date->iso8601 (date 2000 6 30)) "2000-06-30")

     (let ([d (date 2000 6 30)])
       (check-equal? (iso8601->date (date->iso8601 d)) d)))

   (test-suite "date order"
     (let* ([d1 (date 1950)]
            [d2 (date 1970)]
            [d3 (date 1990)])
       (check-true (date<? d1 d2))
       (check-true (date<? d2 d3))
       (check-true (date<=? d1 d3))
       (check-true (date>? d2 d1))
       (check-true (date>=? d3 d2))
       (check-false (date=? d1 d3))

       (check-eq? (date-order d1 d1) '=)
       (check-eq? (date-order d1 d2) '<)
       (check-eq? (date-order d2 d1) '>)))))
