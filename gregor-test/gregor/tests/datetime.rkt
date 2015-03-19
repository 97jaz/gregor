#lang racket/base

(require rackunit
         rackunit/text-ui
         racket/serialize
         gregor)

(run-tests
 (test-suite "[datetimes]"

   (test-case "datetime?"
     (check-true (datetime? (datetime 0)))
     (check-false (datetime? "foo")))

   (test-suite "datetime struct"
     (let* ([t1 (datetime 1970 1 1)]
            [t2 (datetime 1970 1)]
            [t3 (datetime 1970)])

       (test-case "temporal equality"
         (check-true (datetime=? t1 t2))
         (check-true (datetime=? t1 t3))
         (check-false (datetime=? t1 (datetime 12))))

       (test-case "structural equality"
         (check-true (equal? t1 t2))
         (check-true (equal? t1 t3))
         (check-false (equal? t1 (datetime 12))))

       (test-case "serializability"
         (check-true (equal? t1 (deserialize (serialize t3))))
         (check-false (equal? (datetime 12) (deserialize (serialize t3)))))))

   (test-case "datetime->iso8601"
     (check-equal? (datetime->iso8601 (datetime 1969 7 21 2 56 20 1234))
                   "1969-07-21T02:56:20.000001234"))

   (test-suite "datetime order"
     (let* ([t1 (datetime 0)]
            [t2 (datetime 12)]
            [t3 (datetime 23)])
       (check-true (datetime<? t1 t2))
       (check-true (datetime<? t2 t3))
       (check-true (datetime<=? t1 t3))
       (check-true (datetime>? t2 t1))
       (check-true (datetime>=? t3 t2))
       (check-false (datetime=? t1 t3))

       (check-eq? (datetime-order t1 t1) '=)
       (check-eq? (datetime-order t1 t2) '<)
       (check-eq? (datetime-order t2 t1) '>)))))
