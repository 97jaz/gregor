#lang racket/base

(require data/order
         racket/contract/base
         racket/format
         racket/match
         racket/runtime-path
         racket/serialize
         "core/compare.rkt"
         "core/structs.rkt"
         "core/ymd.rkt")

(define (date-equal-proc x y _)
  (= (Date-jdn x) (Date-jdn y)))

(define (date-hash-proc x fn)
  (fn (Date-jdn x)))

(define (date-write-proc d out mode)
  (fprintf out "#<date ~a>" (date->iso8601 d)))

(struct Date (ymd jdn)
  #:methods gen:equal+hash
  [(define equal-proc date-equal-proc)
   (define hash-proc  date-hash-proc)
   (define hash2-proc date-hash-proc)]
  
  #:methods gen:custom-write
  [(define write-proc date-write-proc)]
  
  #:property prop:serializable
  (make-serialize-info (λ (d) (vector (date->jdn d)))
                       #'deserialize-info:Date
                       #f
                       (or (current-load-relative-directory)
                           (current-directory))))

(define date? Date?)

(define (date y [m 1] [d 1])
  (define ymd (YMD y m d))
  (Date ymd (ymd->jdn ymd)))

(define date->ymd Date-ymd)
(define date->jdn Date-jdn)

(define (ymd->date ymd)
  (match-define (YMD y m d) ymd)
  (date y m d))

(define (jdn->date jdn)
  (Date (jdn->ymd jdn) jdn))

(define (date->iso-week d)
  (car (date->iso-week+wyear d)))

(define (date->iso-wyear d)
  (cdr (date->iso-week+wyear d)))

(define (date->iso-week+wyear d)
  (define ymd (date->ymd d))
  (define yday (ymd->yday ymd))
  (define iso-wday (jdn->iso-wday (date->jdn d)))
  (match-define (YMD y _ _) ymd)
  
  (define w (quotient (+ yday (- iso-wday ) 10)
                      7))
     
  (cond [(zero? w)
         (define y-1 (sub1 y))
         (cons (iso-weeks-in-year y-1) y-1)]
        [(and (= w 53) (> w (iso-weeks-in-year y)))
         (cons 1 (add1 y))]
        [else
         (cons w y)]))

(define (date->iso8601 d)
  (define (f n len) (~r n #:min-width len #:pad-string "0"))
  
  (match (Date-ymd d)
    [(YMD y m d) (format "~a-~a-~a" (f y 4) (f m 2) (f d 2))]))

(match-define (comparison date=? date<? date<=? date>? date>=? date-compare date-order)
  (build-comparison 'date date? date->jdn))

(define deserialize-info:Date
  (make-deserialize-info
   jdn->date
   (λ () (error "Date cannot have cycles"))))

;; See 97jaz/gregor#59
(runtime-require (submod "." deserialize-info))

(module+ deserialize-info
  (provide deserialize-info:Date))

(provide/contract
 [date?           (-> any/c boolean?)]
 [date            (->i ([year exact-integer?])
                       ([month (integer-in 1 12)]
                        [day (year month) (day-of-month/c year month)])
                       [d date?])]
 [date->ymd       (-> date? YMD?)]
 [date->jdn       (-> date? exact-integer?)]
 [ymd->date       (-> YMD? date?)]
 [jdn->date       (-> exact-integer? date?)]
 [date->iso-week  (-> date? (integer-in 1 53))]
 [date->iso-wyear (-> date? exact-integer?)]
 [date->iso8601   (-> date? string?)]
 [date=?          (-> date? date? boolean?)]
 [date<?          (-> date? date? boolean?)]
 [date<=?         (-> date? date? boolean?)]
 [date>?          (-> date? date? boolean?)]
 [date>=?         (-> date? date? boolean?)]
 [date-order      order?])

