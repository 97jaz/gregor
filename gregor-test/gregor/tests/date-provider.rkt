#lang racket/base

(require rackunit
         rackunit/text-ui
         gregor
         gregor/time)

(run-tests
 (test-suite "[date providers]"

   (test-case "date-provider?"
     (check-true (date-provider? (date 2000)))
     (check-true (date-provider? (datetime 2000)))
     (check-true (date-provider? (moment 2000)))
     (check-false (date-provider? (time 0))))

   (test-case "->date"
     (check-equal? (->date (date 2000)) (date 2000))
     (check-equal? (->date (datetime 2000)) (date 2000))
     (check-equal? (->date (moment 2000)) (date 2000)))

   (test-case "->jdn"
     (check-equal? (->jdn (date 1970)) 2440588)
     (check-equal? (->jdn (datetime 1867 9 29 23 59 59)) 2403239)
     (check-equal? (->jdn (moment 1867 9 29 23 59 59)) 2403239))

   (test-case "->year"
     (check-equal? (->year (date 1970)) 1970)
     (check-equal? (->year (datetime 1867 9 29)) 1867)
     (check-equal? (->year (moment 1900 2 15)) 1900))

   (test-case "->quarter"
     (check-equal? (->quarter (date 1970)) 1)
     (check-equal? (->quarter (datetime 1867 9 29)) 3)
     (check-equal? (->quarter (moment 1900 4 15)) 2))

   (test-case "->month"
     (check-equal? (->month (date 1970)) 1)
     (check-equal? (->month (datetime 1867 9 29)) 9)
     (check-equal? (->month (moment 1900 2 15)) 2))

   (test-case "->day"
     (check-equal? (->day (date 1970)) 1)
     (check-equal? (->day (datetime 1867 9 29)) 29)
     (check-equal? (->day (moment 1900 2 15)) 15))

   (test-case "->wday"
     (check-equal? (->wday (date 1970)) 4)
     (check-equal? (->wday (datetime 1867 9 29)) 0)
     (check-equal? (->wday (moment 1900 2 20)) 2))

   (test-case "->yday"
     (check-equal? (->yday (date 1970)) 1)
     (check-equal? (->yday (datetime 1980 12 31)) 366)
     (check-equal? (->yday (moment 1900 2 20)) 51))

   (test-case "->iso-week"
     (check-equal? (->iso-week (date 2005 1 1)) 53)
     (check-equal? (->iso-week (datetime 2007 1 1)) 1)
     (check-equal? (->iso-week (moment 2008 12 31 #:tz "America/New_York")) 1))

   (test-case "->iso-wyear"
     (check-equal? (->iso-wyear (date 2005 1 1)) 2004)
     (check-equal? (->iso-wyear (datetime 2007 1 1)) 2007)
     (check-equal? (->iso-wyear (moment 2008 12 31 #:tz "America/New_York")) 2009))
   
   (test-case "->iso-wday"
     (check-equal? (->iso-wday (date 1970)) 4)
     (check-equal? (->iso-wday (datetime 1867 9 29)) 7)
     (check-equal? (->iso-wday (moment 1900 2 20)) 2))

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

   (test-case "sunday?"
     (check-true (sunday? (date 1942 5 3)))
     (check-false (sunday? (datetime 1776 7 4)))
     (check-true (sunday? (moment 2100 1 31))))

   (test-case "monday?"
     (check-true (monday? (date 1942 5 4)))
     (check-false (monday? (datetime 1776 7 4)))
     (check-true (monday? (moment 2100 2 1))))

   (test-case "tuesday?"
     (check-true (tuesday? (date 1942 5 5)))
     (check-false (tuesday? (datetime 1776 7 4)))
     (check-true (tuesday? (moment 2100 2 2))))

   (test-case "wednesday?"
     (check-true (wednesday? (date 1942 5 6)))
     (check-false (wednesday? (datetime 1776 7 4)))
     (check-true (wednesday? (moment 2100 2 3))))

   (test-case "thursday?"
     (check-true (thursday? (date 1942 5 7)))
     (check-true (thursday? (datetime 1776 7 4)))
     (check-true (thursday? (moment 2100 2 4))))

   (test-case "friday?"
     (check-true (friday? (date 1942 5 8)))
     (check-false (friday? (datetime 1776 7 4)))
     (check-true (friday? (moment 2100 2 5))))

   (test-case "saturday?"
     (check-true (saturday? (date 1942 5 9)))
     (check-false (saturday? (datetime 1776 7 4)))
     (check-true (saturday? (moment 2100 2 6))))

   (test-case "at-time"
     (check-equal? (at-time (date 1970) (time 15 30)) (datetime 1970 1 1 15 30))
     (check-equal? (at-time (datetime 1775 4 19 21 30 1) (datetime 3000 1 1 5))
                   (datetime 1775 4 19 5))
     (check-equal? (at-time (moment 2015 3 8 #:tz "America/New_York")
                            (time 2)
                            #:resolve-offset resolve-offset/post)
                   (moment 2015 3 8 3 #:tz "America/New_York")))

   (test-case "at-midnight"
     (check-equal? (at-midnight (date 1970)) (datetime 1970))
     (check-equal? (at-midnight (datetime 1970 10 10 10 10 10 10)) (datetime 1970 10 10))
     (check-equal? (at-midnight (moment 1970 10 10 10 10 10 10 #:tz "Etc/UTC"))
                   (moment 1970 10 10 #:tz "Etc/UTC")))

   (test-case "at-noon"
     (check-equal? (at-noon (date 1970)) (datetime 1970 1 1 12))
     (check-equal? (at-noon (datetime 1970 10 10 10 10 10 10)) (datetime 1970 10 10 12))
     (check-equal? (at-noon (moment 1970 10 10 10 10 10 10 #:tz "Etc/UTC"))
                   (moment 1970 10 10 12 #:tz "Etc/UTC")))))
