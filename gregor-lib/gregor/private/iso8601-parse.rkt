#lang racket/base

(require racket/contract/base
         racket/match
         racket/math
         parser-tools/lex
         (prefix-in : parser-tools/lex-sre)
         parser-tools/yacc
         "core/hmsn.rkt"
         "exn.rkt"
         "generics.rkt"
         "date.rkt"
         "time.rkt"
         "datetime.rkt"
         "moment.rkt"
         "offset-resolvers.rkt")

(provide iso8601->date
         iso8601->time
         iso8601->datetime
         iso8601->moment
         iso8601/tzid->moment)


(define-tokens data-tokens (YEAR D2 FRACTION TZID))
(define-empty-tokens empty-tokens (DASH PLUS COLON T Z EOF))

(define parse-temporal
  (parser
   [tokens data-tokens empty-tokens]
   [error (λ (tok-ok? tok-name tok-value)
            (raise-iso8601-parse-error))]
   [start temporal]
   [end EOF]
   [grammar
    (temporal
     [(moment/ext) $1]
     [(moment)     $1]
     [(datetime)   $1]
     [(time)       $1]
     [(date)       $1])
    
    (date
     [(optsign YEAR DASH month DASH day)  (date ($1 $2) $4 $6)]
     [(optsign YEAR DASH month)           (date ($1 $2) $4)]
     [(optsign YEAR)                      (date ($1 $2))])
    
    (time
     [(hour)                              (time $1)]
     [(hour COLON min)                    (time $1 $3)]
     [(hour COLON min COLON sec)          (time $1 $3 $5)]
     [(hour COLON min COLON sec fraction) (time $1 $3 $5 $6)])

    (datetime
     [(date T time)                       (date+time->datetime $1 $3)])

    (moment
     [(datetime offset)      (datetime+tz->moment $1 $2 resolve-offset/raise)])

    (moment/ext
     [(datetime offset TZID) (datetime+tz->moment $1 $3 resolve-offset/raise)])

    (offset
     [(sign hour)           ($1 (* 3600 $2))]
     [(sign hour COLON min) ($1 (+ (* 3600 $2) (* 60 $4)))]
     [(Z)                   0])

    (month
     [(D2) (guard $1 (integer-in 1 12))])

    (day
     [(D2) (guard $1 (integer-in 1 31))])

    (hour
     [(D2) (guard $1 (integer-in 0 23))])

    (min
     [(D2) (guard $1 (integer-in 0 59))])

    (sec
     [(min) $1])

    (sign
     [(PLUS)  +]
     [(DASH)  -])

    (optsign
     [(sign)  $1]
     [()      +])

    (fraction
     [(FRACTION) (exact-floor (* $1 NS/SECOND))])]))

(define (make-parser kind p? xform)
  (λ (str)
    (define in (open-input-string str))
    (define t (parse-temporal (λ () (scan in))))

    (if (p? t)
        (xform t)
        (raise-iso8601-parse-error
         (format "Unable to parse string as a ~a" kind)))))

(define iso8601->date        (make-parser 'date date-provider? ->date))
(define iso8601->time        (make-parser 'time time-provider? ->time))
(define iso8601->datetime    (make-parser 'datetime datetime-provider? ->datetime/local))
(define iso8601->moment      (make-parser 'moment moment-provider? ->moment))
(define iso8601/tzid->moment (make-parser 'moment/tzid tzid-provider? ->moment))

(define (guard val ok?)
  (if (ok? val)
      val
      (raise-iso8601-parse-error)))

(define scan
  (lexer
   [(:>= 4 digit) (token-YEAR (string->number lexeme))]
   [(:= 2 digit)  (token-D2 (string->number lexeme))]
   [(:: (:or "." ",") (:+ digit)) (token-FRACTION (string->number (regexp-replace #rx"," lexeme ".")))]
   ["-" (token-DASH)]
   ["+" (token-PLUS)]
   [":" (token-COLON)]
   ["T" (token-T)]
   ["Z" (token-Z)]
   ["[" (token-TZID (list->string (scan-tzid input-port)))]
   [(eof) (token-EOF)]
   [any-char (raise-iso8601-parse-error)]))

(define scan-tzid
  (lexer
   ["]"
    '()]
   [(:~ (:or "]" " "))
    (cons (string-ref lexeme 0)
          (scan-tzid input-port))]
   [any-char
    (raise-iso8601-parse-error)]
   [(eof)
    (raise-iso8601-parse-error)]))

(define-lex-abbrev digit (:/ #\0 #\9))

(define (raise-iso8601-parse-error [msg "Unable to parse input as an ISO 8601 string"])
  (raise
   (exn:gregor:parse msg
                     (current-continuation-marks))))
