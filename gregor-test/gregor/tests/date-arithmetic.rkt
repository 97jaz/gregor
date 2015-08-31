#lang racket/base

(require rackunit
         rackunit/text-ui
         gregor
         gregor/period)

(run-tests
 (test-suite "[date arithmetic]"

   (test-case "+years"
     (check-equal? (+years (date 1970) 4) (date 1974))
     (check-equal? (+years (date 1970) -4) (date 1966))
     (check-equal? (+years (datetime 1980 2 29) 1) (datetime 1981 2 28))
     (check-equal? (+years (datetime 1980 2 29) -1) (datetime 1979 2 28))
     (check-equal? (+years (moment 2014 3 8 2 #:tz "America/New_York") 1)
                   (moment 2015 3 8 3 #:tz "America/New_York"))
     (check-equal? (+years (moment 2016 3 8 2 #:tz "America/New_York") -1)
                   (moment 2015 3 8 3 #:tz "America/New_York")))

   (test-case "-years"
     (check-equal? (-years (date 1970) -4) (date 1974))
     (check-equal? (-years (date 1970) 4) (date 1966))
     (check-equal? (-years (datetime 1980 2 29) -1) (datetime 1981 2 28))
     (check-equal? (-years (datetime 1980 2 29) 1) (datetime 1979 2 28))
     (check-equal? (-years (moment 2014 3 8 2 #:tz "America/New_York") -1)
                   (moment 2015 3 8 3 #:tz "America/New_York"))
     (check-equal? (-years (moment 2016 3 8 2 #:tz "America/New_York") 1)
                   (moment 2015 3 8 3 #:tz "America/New_York"))

     (check-exn exn:gregor:invalid-offset?
                (λ ()
                  (-years (moment 2016 3 8 2 #:tz "America/New_York")
                          1
                          #:resolve-offset resolve-offset/raise))))

   (test-case "+months"
     (check-equal? (+months (date 1970) 4) (date 1970 5))
     (check-equal? (+months (date 1970) -4) (date 1969 9))
     (check-equal? (+months (datetime 1979 1 29) 1) (datetime 1979 2 28))
     (check-equal? (+months (datetime 1979 3 29) -1) (datetime 1979 2 28))
     (check-equal? (+months (moment 2015 2 8 2 #:tz "America/New_York") 1)
                   (moment 2015 3 8 3 #:tz "America/New_York"))
     (check-equal? (+months (moment 2015 4 8 2 #:tz "America/New_York") -1)
                   (moment 2015 3 8 3 #:tz "America/New_York")))

   (test-case "-months"
     (check-equal? (-months (date 1970) -4) (date 1970 5))
     (check-equal? (-months (date 1970) 4) (date 1969 9))
     (check-equal? (-months (datetime 1979 1 29) -1) (datetime 1979 2 28))
     (check-equal? (-months (datetime 1979 3 29) 1) (datetime 1979 2 28))
     (check-equal? (-months (moment 2015 2 8 2 #:tz "America/New_York") -1)
                   (moment 2015 3 8 3 #:tz "America/New_York"))
     (check-equal? (-months (moment 2015 4 8 2 #:tz "America/New_York") 1)
                   (moment 2015 3 8 3 #:tz "America/New_York")))

   (test-case "+weeks"
     (check-equal? (+weeks (date 1970) 6) (date 1970 2 12))
     (check-equal? (+weeks (date 1970) -6) (date 1969 11 20))
     (check-equal? (+weeks (datetime 1980 1 4 12) 8) (datetime 1980 2 29 12))
     (check-equal? (+weeks (datetime 1980 2 29 12) -8) (datetime 1980 1 4 12))
     (check-equal?
      (+weeks (moment 2015 3 1 2
                      #:tz "America/Los_Angeles"
                      #:resolve-offset resolve-offset/raise)
              1)
      (moment 2015 3 8 3 #:tz "America/Los_Angeles")))

   (test-case "-weeks"
     (check-equal? (-weeks (date 1970) -6) (date 1970 2 12))
     (check-equal? (-weeks (date 1970) 6) (date 1969 11 20))
     (check-equal? (-weeks (datetime 1980 1 4 12) -8) (datetime 1980 2 29 12))
     (check-equal? (-weeks (datetime 1980 2 29 12) 8) (datetime 1980 1 4 12))
     (check-equal?
      (-weeks (moment 2015 3 1 2
                      #:tz "America/Los_Angeles"
                      #:resolve-offset resolve-offset/raise)
              -1)
      (moment 2015 3 8 3 #:tz "America/Los_Angeles")))

   (test-case "+days"
     (check-equal? (+days (date 1980) (* 365 2)) (date 1981 12 31))
     (check-equal? (+days (datetime 1980 11 15 10) (* 365 2)) (datetime 1982 11 15 10))
     (check-exn exn:gregor:invalid-offset?
                (λ ()
                  (+days (moment 2015 3 7 2 #:tz "America/Denver")
                         1
                         #:resolve-offset resolve-offset/raise))))

   (test-case "-days"
     (check-equal? (-days (date 1980) (* 365 -2)) (date 1981 12 31))
     (check-equal? (-days (datetime 1980 11 15 10) (* 365 -2)) (datetime 1982 11 15 10))
     (check-exn exn:gregor:invalid-offset?
                (λ ()
                  (-days (moment 2015 3 7 2 #:tz "America/Denver")
                         -1
                         #:resolve-offset resolve-offset/raise))))

   (test-case "+date-period"
     (check-equal? (+date-period (date 1980 6 5) (days 10)) (date 1980 6 15))
     (check-equal? (+date-period (datetime 2000 10 10) (weeks -2)) (datetime 2000 9 26))
     (check-equal? (+date-period (moment 2015 8 30) (months 23)) (moment 2017 7 30))
     (check-equal? (+date-period (date 1990) (years 10)) (date 2000))
     (check-equal? (+date-period (date 1950) (period [years 6] [months 2] [days 15])) (date 1956 3 16)))

   (test-case "-date-period"
     (check-equal? (-date-period (date 1956 3 16) (period [years 6] [months 2] [days 15])) (date 1950))
     (check-equal? (-date-period (datetime 1956 3 16) (period [years 6] [months 2] [days 15])) (datetime 1950)))))
