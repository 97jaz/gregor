#lang racket/base

(require rackunit
         rackunit/text-ui
         gregor
         gregor/time)

(define-syntax-rule (check-n d c results)
  (for ([r results]
        [i (in-naturals 1)])
    (check-equal? (~t d (make-string i c)) r)))

(define d (date 1955 11 12))
(define t (time 2 42 30 555))
(define dt (at-time d t))
(define m (moment 2000 #:tz "America/Los_Angeles"))

(run-tests
 (test-suite "[format]"
   (test-suite "locale: en"
     (parameterize ([current-locale "en"])
       ;; real patterns
       (check-equal? (~t d "ccc") "Sat")
       (check-equal? (~t dt "E HH:mm") "Sat 02:42")
       (check-equal? (~t dt "E HH:mm:ss") "Sat 02:42:30")
       (check-equal? (~t dt "d E") "12 Sat")
       (check-equal? (~t dt "E h:mm a") "Sat 2:42 AM")
       (check-equal? (~t dt "y G") "1955 AD")
       (check-equal? (~t dt "MMM y G") "Nov 1955 AD")
       (check-equal? (~t dt "E, MMMM d, y G") "Sat, November 12, 1955 AD")
       (check-equal? (~t dt "L") "11")
       (check-equal? (~t dt "QQQQ, uuuu") "4th quarter, 1955")
       (check-equal? (~t dt "QQQ, yy") "Q4, 55")

       ;; era
       (for ([p '("G" "GG" "GGG")])
         (check-equal? (~t (date 2000) p) "AD")
         (check-equal? (~t (date 0) p) "BC"))

       (check-equal? (~t (date 2000) "GGGG") "Anno Domini")
       (check-equal? (~t (date 0) "GGGG") "Before Christ")

       (check-equal? (~t (date 2000) "GGGGG") "A")
       (check-equal? (~t (date 0) "GGGGG") "B")

       ;; year
       ;; y
       (let ([years '(1 12 123 1234 12345)]
             [pats '("y" "yy" "yyy" "yyyy" "yyyyy")]
             [exp  '(("1" "01" "001" "0001" "00001")
                     ("12" "12" "012" "0012" "00012")
                     ("123" "23" "123" "0123" "00123")
                     ("1234" "34" "1234" "1234" "01234")
                     ("12345" "45" "12345" "12345" "12345"))])
         
         (for ([(y ps es) (in-parallel years
                                       (in-cycle (in-value pats))
                                       exp)])
           (for ([p ps]
                 [e es])
             (test-case (format "year: ~a; pattern: ~a" y p)
               (check-equal? (~t (date y) p) e)))))

       (check-equal? (~t (date 0) "Y G") "1 BC")
       
       ;; Y
       (check-equal? (~t d "Y") "1955")
       (check-equal? (~t d "YY") "55")
       (check-equal? (~t d "YYYYY") "01955")

       ;; u
       (check-equal? (~t d "u") "1955")
       (check-equal? (~t (date 0) "u") "0")
       (check-equal? (~t d "uu") "1955")

       ;; U
       (check-equal? (~t d "U") "1955")
       (check-equal? (~t (date 0) "U G") "1 BC")

       ;; r
       (check-equal? (~t d "r") "1955")
       (check-equal? (~t (date 0) "r") "0")
       (check-equal? (~t d "rr") "1955")

       ;; Quarter
       (check-n d #\Q '("4" "04" "Q4" "4th quarter" "4"))
       (check-n d #\q '("4" "04" "Q4" "4th quarter" "4"))
       
       ;; month
       (check-n d #\M '("11" "11" "Nov" "November" "N"))
       (check-n d #\L '("11" "11" "Nov" "November" "N"))

       ;; week
       (check-n d #\w '("46" "46"))
       (check-n d #\W '("2"))

       ;; day
       (check-n d #\d '("12" "12"))
       (check-n d #\D '("316" "316" "316"))
       (check-n d #\F '("2"))
       (check-n d #\g '("2435424" "2435424" "2435424" "2435424" "2435424" "2435424" "2435424" "02435424"))

       ;; weekday
       (check-n d #\E '("Sat" "Sat" "Sat" "Saturday" "S" "Sa"))
       (check-n d #\e '("7" "07" "Sat" "Saturday" "S" "Sa"))
       (check-n d #\c '("7" "77" "Sat" "Saturday" "S" "Sa")) ; per spec, no "cc" pattern

       ;; period
       (check-n dt #\a '("AM" "AM" "AM" "AM" "a"))

       ;; hour
       (check-n dt #\h '("2" "02"))
       (check-n dt #\H '("2" "02"))
       (check-n (time 0) #\K '("0" "00"))
       (check-n (time 1) #\K '("1" "01"))
       (check-n (time 12) #\K '("0" "00"))
       (check-n (time 0) #\k '("24" "24"))
       (check-n (time 1) #\k '("1" "01"))
       (check-n (time 13) #\k '("13" "13"))

       ;; minute
       (check-n dt #\m '("42" "42"))

       ;; second
       (check-n dt #\s '("30" "30"))
       (check-n dt #\S '("0" "00" "000" "0000" "00000" "000000" "0000005" "00000055" "000000555"))
       (check-n dt #\A '("9750000" "9750000"))

       ;; separator
       (check-n dt #\: '(":"))

       ;; time zones
       (check-n m #\z '("PST" "PST" "PST" "Pacific Standard Time"))
       (check-n m #\Z '("-0800" "-0800" "-0800" "GMT-08:00" "-08:00"))
       (check-equal? (~t m "O") "GMT-8")
       (check-equal? (~t m "OOOO") "GMT-08:00")
       (check-equal? (~t m "v") "PT")
       (check-equal? (~t m "vvvv") "Pacific Time")
       (check-n m #\V '("uslax" "America/Los_Angeles" "Los Angeles" "Los Angeles Time"))
       (check-n m #\X '("-08" "-0800" "-08:00" "-0800" "-08:00"))
       (check-n m #\x '("-08" "-0800" "-08:00" "-0800" "-08:00"))))))

       