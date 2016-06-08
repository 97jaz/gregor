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
       (check-equal? (today #:tz "America/Chicago") (date 1969 12 31))
       (check-equal? (today #:tz -21600) (date 1969 12 31)))

     (test-case "current-time"
       (check-equal? (current-time/utc) (time 0 0 1))
       (check-equal? (current-time #:tz "America/Chicago") (time 18 0 1))
       (check-equal? (current-time #:tz -21600) (time 18 0 1)))

     (test-case "now"
       (check-equal? (now/utc) (datetime 1970 1 1 0 0 1))
       (check-equal? (now #:tz "America/Chicago") (datetime 1969 12 31 18 0 1))
       (check-equal? (now #:tz -21600) (datetime 1969 12 31 18 0 1)))

     (test-case "moment"
       (check-equal? (now/moment/utc) (moment 1970 1 1 0 0 1 #:tz UTC))
       (check-equal? (now/moment #:tz "America/Chicago")
                     (moment 1969 12 31 18 0 1 #:tz "America/Chicago"))
       (check-equal? (now/moment #:tz -21600)
                     (moment 1969 12 31 18 0 1 #:tz -21600))))))

;; https://github.com/97jaz/gregor/issues/3
(run-tests
 (test-suite "[round-trip ISO 8601 with clock functions]"
   (parameterize ([current-clock (λ () 1463207954418177/1024000)])
     (test-case "today"
       (let ([d (today)])
         (check-equal? d (iso8601->date (date->iso8601 d)))))

     (test-case "current-time"
       (let ([t (current-time)])
         (check-equal? t (iso8601->time (time->iso8601 t)))))

     (test-case "now"
       (let ([n (now)])
         (check-equal? n (iso8601->datetime (datetime->iso8601 n)))))

     (test-case "now/moment"
       (let ([n (now/moment)])
         (check-equal? n (iso8601/tzid->moment (moment->iso8601/tzid n))))))))
