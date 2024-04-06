#lang racket/base

(require racket/format
         racket/match
         racket/serialize
         "datetime.rkt"
         "core/compare.rkt")

(provide (all-defined-out))

(define (moment-equal-proc x y _)
  (match* (x y)
    [((Moment d1 o1 z1) (Moment d2 o2 z2))
     (and (equal? d1 d2)
          (= o1 o2)
          (equal? z1 z2))]))

(define (moment-hash-proc x fn)
  (match x
    [(Moment d o z)
     (bitwise-xor (fn d) (fn o) (fn z))]))

(define (moment-write-proc m out mode)
  (fprintf out
           "#<moment ~a>"
           (moment->iso8601/tzid m)))

(define (moment->iso8601/tzid m)
  (define iso (moment->iso8601 m))
  (match m
    [(Moment _ _ z) #:when z (format "~a[~a]" iso z)]
    [_ iso]))

(define (moment->iso8601 m)
  (match m
    [(Moment d 0 _)
     (string-append (datetime->iso8601 d) "Z")]
    [(Moment d o _)
     (define sign (if (< o 0) "-" "+"))
     (define sec  (abs o))
     (define hrs  (quotient sec 3600))
     (define min  (quotient (- sec (* hrs 3600)) 60))
     
     (format "~a~a~a:~a"
             (datetime->iso8601 d)
             sign
             (~r hrs #:min-width 2 #:pad-string "0" #:sign #f)
             (~r min #:min-width 2 #:pad-string "0" #:sign #f))]))
     
     
(struct Moment (datetime/local utc-offset zone)
  #:methods gen:equal+hash
  [(define equal-proc moment-equal-proc)
   (define hash-proc  moment-hash-proc)
   (define hash2-proc moment-hash-proc)]
  
  #:methods gen:custom-write
  [(define write-proc moment-write-proc)]
  
  #:property prop:serializable
  (make-serialize-info (λ (m)
                         (vector (Moment-datetime/local m)
                                 (Moment-utc-offset m)
                                 (Moment-zone m)))
                       #'deserialize-info:Moment
                       #f
                       (or (current-load-relative-directory)
                           (current-directory))))

(define deserialize-info:Moment
  (make-deserialize-info
   Moment
   (λ () (error "Moment cannot have cycles"))))

;; See racket/racket#4967
(provide deserialize-info:Moment)

(module+ deserialize-info
  (provide deserialize-info:Moment))

(define moment? Moment?)

(define (make-moment dt off z)
  (Moment dt off (and z (string->immutable-string z))))
