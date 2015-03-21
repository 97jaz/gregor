#lang racket/base

(require racket/match
         racket/string
         cldr/core
         cldr/dates-modern
         "../../generics.rkt"
         "iso-offset.rkt"
         "numbers.rkt")

(provide zone/gmt-fmt)

(define (zone/gmt-fmt loc t long?)
  (define tznames (time-zone-names loc))
  
  (match (->utc-offset t)
    [0
     (cldr-ref tznames 'gmtZeroFormat)]
    
    [n
     (match-define (vector _ h m _) (utc-offset-components n))
     (define gmt-fmt (cldr-ref tznames 'gmtFormat))
     (define long-hour-fmts (cldr-ref tznames 'hourFormat))
     (define hour-fmts (string-split (if long? long-hour-fmts "+H;-H") ";"))
     (define hour-fmt (list-ref hour-fmts (if (positive? n) 0 1)))
     (define sep (time-separator loc))
     (define body
       (let* ([s (regexp-replace #rx"H+"
                                 hour-fmt
                                 (λ (x . xs)
                                   (num-fmt loc h (string-length x))))]
              [s (regexp-replace #rx"mm" s (num-fmt loc m 2))]
              [s (regexp-replace #rx":" s sep)])
         s))
     
     (regexp-replace #rx"{0}" gmt-fmt body)]))
