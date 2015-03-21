#lang racket/base

(require rackunit
         rackunit/text-ui
         racket/list
         gregor
         gregor/time)

(define (check-n c fmt inputs fn)
  (for ([s (in-list inputs)]
        [i (in-naturals 1)])
    (define pat (format fmt (make-string i c)))

    (test-case (format "(parse-date ~s ~s)" s pat)
      (check-true
       (fn (parse-date s pat))))))

(run-tests
 (test-suite "[parse]"
   (test-suite "locale: en"

     (test-suite "mixed pattern"
       (parameterize ([current-locale "en"]
                      [current-timezone "America/Montreal"])
         (define abbr-pat "MMM. d, yyyy 'at precisely' h 'o''clock and' m 'minutes' a")
         (define abbr-input "Mar. 20, 2015 at precisely 4 o'clock and 22 minutes PM")

         (check-equal? (parse-date abbr-input abbr-pat) (date 2015 3 20))
         (check-equal? (parse-time abbr-input abbr-pat) (time 16 22))
         (check-equal? (parse-datetime abbr-input abbr-pat) (datetime 2015 3 20 16 22))
         (check-equal? (parse-moment abbr-input abbr-pat) (moment 2015 3 20 16 22 #:tz "America/Montreal"))))

     (test-suite "era [G]"
       (check-equal? (->year (parse-date "2000 BC" "y G")) -1999)
       (check-equal? (->year (parse-date "2000 AD" "y G")) 2000)

       (check-equal? (->year (parse-date "2000 BCE" "y G")) -1999)
       (check-equal? (->year (parse-date "2000 CE" "y G")) 2000)

       (check-equal? (->year (parse-date "2000 Before Christ" "y GGGG")) -1999)
       (check-equal? (->year (parse-date "2000 Anno Domini" "y GGGG")) 2000)

       (check-equal? (->year (parse-date "2000 B" "y GGGGG")) -1999)
       (check-equal? (->year (parse-date "2000 A" "y GGGGG")) 2000)

       (check-equal? (->year (parse-date "2000 bce" "y G")) -1999)
       (check-equal? (->year (parse-date "2000 ce" "y G")) 2000)

       (check-exn exn:gregor:parse?
                  (λ ()
                    (->year (parse-date "2000 bce" "y G" #:ci? #f)))))

     (test-suite "year"
       (test-suite "[y]"
         (check-equal? (->year (parse-date "2000" "y")) 2000)
         (check-exn exn:gregor:parse? (λ () (parse-date "-2000" "y"))) ;; era year cannot be negative

         (parameterize ([current-two-digit-year-resolver (λ (y) (+ y 1700))])
           (check-equal? (->year (parse-date "56" "yy")) 1756))

         (check-equal? (->year (parse-date "02000" "yyyyy")) 2000))

       (test-suite "[Y]"
         ;; Week-based year does not contribute to parse data.
         ;; If we had an ISO 8601 week type, this pattern would be a lot more useful.
         ;; But, then, how useful is an ISO 8601 week type?
         (let ([d (parse-date "2005-01-01 / 2004-W53-6" "uuuu-MM-dd / YYYY-'W'ww-W")])
           (check-equal? (->year d) 2005)
           (check-equal? (->iso-wyear d) 2004))

         (check-equal? (->year (parse-date "2005-01-01 / ISO 04" "uuuu-MM-dd / 'ISO' YY")) 2005))

       (test-suite "[u]"
         (check-equal? (->year (parse-date "2000" "u")) 2000)
         (check-equal? (->year (parse-date "9000" "uu")) 9000) ; no special case
         (check-equal? (->year (parse-date "02000" "uuuuu")) 2000)
         (check-equal? (->year (parse-date "-2000" "u")) -2000))

       (test-suite "[U]"
         ;; like y without special case for UU
         (check-equal? (->year (parse-date "9000" "UU")) 9000))

       (test-suite "[r]"
         ;; same as u in the Gregorian calendar
         (check-equal? (->year (parse-date "-1234" "rr")) -1234)))

     (test-suite "quarter"
       (test-suite "[Q]"
         (check-not-exn (λ () (parse-date "4 2000" "Q u")))
         (check-not-exn (λ () (parse-date "04 2000" "QQ u")))
         (check-not-exn (λ () (parse-date "Q4 2000" "QQQ u")))
         (check-not-exn (λ () (parse-date "4th quarter 2000" "QQQQ u")))
         (check-not-exn (λ () (parse-date "4 2000" "QQQQQ u"))))

       (test-suite "[q]"
         (check-not-exn (λ () (parse-date "4 2000" "q u")))
         (check-not-exn (λ () (parse-date "04 2000" "q u")))
         (check-not-exn (λ () (parse-date "Q4 2000" "qqq u")))
         (check-not-exn (λ () (parse-date "4th quarter 2000" "qqqq u")))
         (check-not-exn (λ () (parse-date "4 2000" "qqqqq u")))))

     (test-suite "month"
       ;; 1. No point in testing narrow case, since it's not unique AND YOU SHOULD NEVER PARSE WITH IT.
       ;; 2. We'll test in Greek to demonstrate the difference between format and stand-alone patterns
       ;;    (Απριλίου [genitive] vs. Απρίλιος [nominative])
       
       (parameterize ([current-locale "el"])

         (check-n #\M "u ~a"
                  '("2000 4" "2000 04" "2000 Απρ" "2000 Απριλίου")
                  (λ (d)
                    (and (= (->year d) 2000)
                         (= (->month d) 4))))

         (check-n #\L "u ~a"
                  '("2000 4" "2000 04" "2000 Απρ" "2000 Απρίλιος")
                  (λ (d)
                    (and (= (->year d) 2000)
                         (= (->month d) 4))))))

     ;; week patterns were tested above, alongside Y

     (test-suite "day"
       (check-n #\d "u M ~a"
                '("1234 1 9" "1234 1 09")
                (λ (d) (date=? d (date 1234 1 9))))

       (check-n #\D "u ~a"
                '("2000 5" "2000 05" "2000 005")
                (λ (d) (= (->year d) 2000)))

       (check-equal? (->year (parse-date "2000 3" "u F")) 2000)

       (check-equal? (parse-date "2451334" "g") (date 1999 6 4)))

     (test-suite "weekday"
       (check-n #\E "u ~a"
                '("2000 Sat" "2000 Sat" "2000 Sat" "2000 Saturday")
                (λ (d) (equal? d (date 2000))))
       (check-equal? (parse-date "2000 Sa" "u EEEEEE") (date 2000))

       (check-n #\e "u ~a"
                '("2000 7" "2000 07" "2000 Sat" "2000 Saturday")
                (λ (d) (equal? d (date 2000))))
       (check-equal? (parse-date "2000 Sa" "u eeeeee") (date 2000))

       (check-equal? (parse-date "2000 7" "u c") (date 2000))
       ;; per spec, no 'cc' pattern
       (check-equal? (parse-date "2000 Sat" "u ccc") (date 2000))
       (check-equal? (parse-date "2000 Saturday" "u cccc") (date 2000))
       (check-equal? (parse-date "2000 Sa" "u cccccc") (date 2000)))

     (test-suite "hour and period"
       (check-equal? (parse-time "3 am" "h a") (time 3))
       (check-equal? (parse-time "03 pm" "hh a") (time 15))
       (check-exn exn:gregor:parse? (λ () (parse-time "15" "hh")))

       (check-equal? (parse-time "3" "H") (time 3))
       (check-equal? (parse-time "15" "H") (time 15))

       (check-equal? (parse-time "0" "K") (time 0))
       (check-exn exn:gregor:parse? (λ () (parse-time "12" "KK")))

       (check-exn exn:gregor:parse? (λ () (parse-time "0" "k")))
       (check-equal? (parse-time "03" "kk") (time 3))
       (check-equal? (parse-time "13" "k") (time 13))
       (check-equal? (parse-time "24" "kk") (time 0)))

     (test-suite "minute"
       (check-equal? (->minutes (parse-time "17:30" "H:mm")) 30)
       (check-equal? (->minutes (parse-time "17:45" "H:m")) 45))

     (test-suite "second"
       (check-equal? (->seconds (parse-time "17:30:20" "H:mm:ss")) 20)
       (check-equal? (->seconds (parse-time "4:20:00" "H:m:s")) 0)

       (check-equal? (->milliseconds (parse-time "1:30:00.6" "H:mm:ss.S")) 600)
       (check-equal? (->milliseconds (parse-time "1:30:00.06" "H:mm:ss.SS")) 60)
       (check-equal? (parse-time "9750000" "AAAA") (time 2 42 30)))

     (test-suite "time separator"
       (parameterize ([current-locale "fi"])
         (check-equal? (parse-time "10.09" "H:m") (time 10 9))))

     (test-suite "time zones"
       (let ([check-n (λ (m c xs)
                        (for ([x (in-list xs)]
                              [i (in-naturals 1)])
                          (define input (format "2000-10-10 01:02:03 ~a" x))
                          (define pat (format "u-M-d H:m:s ~a" (make-string i c)))

                          (test-case (format "(parse-moment ~s ~s)" input pat)
                            (check-equal? (parse-moment input pat) m))))]
             [m1 (moment 2000 10 10 1 2 3 #:tz (* 8 -3600))]
             [mz (moment 2000 10 10 1 2 3 #:tz 0)]
             [mlax (moment 2000 10 10 1 2 3 #:tz "America/Los_Angeles")])
         (check-n m1 #\X '("-08" "-0800" "-08:00" "-0800" "-08:00"))
         (check-n m1 #\x '("-08" "-0800" "-08:00" "-0800" "-08:00"))
         (check-n mz #\X (make-list 5 "Z"))
         (check-n mz #\x '("+00" "+0000" "+00:00" "+0000" "+00:00"))

         (check-n mlax #\V '("uslax" "America/Los_Angeles")))))))

         