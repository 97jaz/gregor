#lang racket/base

(require rackunit
         rackunit/text-ui
         racket/serialize
         gregor
         gregor/time)

(run-tests
 (test-suite "[times]"

   (test-case "time?"
     (check-true (time? (time 0)))
     (check-false (time? "foo")))

   (test-suite "time struct"
     (let* ([t1 (time 1 2 0 0)]
            [t2 (time 1 2 0)]
            [t3 (time 1 2)])

       (test-case "temporal equality"
         (check-true (time=? t1 t2))
         (check-true (time=? t1 t3))
         (check-false (time=? t1 (time 12))))

       (test-case "structural equality"
         (check-true (equal? t1 t2))
         (check-true (equal? t1 t3))
         (check-false (equal? t1 (time 12))))

       (test-case "serializability"
         (check-true (equal? t1 (deserialize (serialize t3))))
         (check-false (equal? (time 12) (deserialize (serialize t3)))))))

   (test-case "time->iso8601"
     (check-equal? (time->iso8601 (time 12 45 3 1234)) "12:45:03.000001234")

     (let ([t (time 1 56 43 386282959)])
       (check-equal? (iso8601->time (time->iso8601 t)) t)))

   (test-suite "time order"
     (let* ([t1 (time 0)]
            [t2 (time 12)]
            [t3 (time 23)])
       (check-true (time<? t1 t2))
       (check-true (time<? t2 t3))
       (check-true (time<=? t1 t3))
       (check-true (time>? t2 t1))
       (check-true (time>=? t3 t2))
       (check-false (time=? t1 t3))

       (check-eq? (time-order t1 t1) '=)
       (check-eq? (time-order t1 t2) '<)
       (check-eq? (time-order t2 t1) '>)))))
