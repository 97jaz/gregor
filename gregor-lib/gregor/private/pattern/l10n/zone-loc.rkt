#lang racket/base

(require racket/list
         cldr/core
         cldr/dates-modern
         tzinfo
         "../../generics.rkt"
         "zone-util.rkt"
         "gmt-offset.rkt")

(provide zone/city-fmt
         zone/generic-loc-fmt)

(define (zone/city-fmt loc t)
  (define tzid (canonical-tzid (->tzid t)))
  
  (or (and tzid (city-of loc tzid))
      (city-of loc "Etc/Unknown")))

(define (zone/generic-loc-fmt loc t)
  (define tzid (canonical-tzid (->tzid t)))
  
  (cond [(or (not tzid)
             (zero? (length (tzid->country-codes tzid))))
         (zone/gmt-fmt loc t #t)]
        [else
         (define cc (tzid->primary-cc tzid))
  
         (if cc
             (region-fmt loc (country-name loc cc))
             (region-fmt loc (city-of loc tzid)))]))

(define (tzid->primary-cc tzid)
  (and (string? tzid)
       (or (single-cc tzid)
           (primary-cc tzid))))

(define (single-cc tzid)
  (define ccs (tzid->country-codes tzid))
  
  (and (= (length ccs) 1)
       (let ([country-tzids (country-code->tzids (first ccs))])
         (and (= (length country-tzids) 1)
              (first ccs)))))

(define (primary-cc tzid)
  (for/first ([(cc z) (in-hash (primary-zones))]
              #:when (equal? z tzid))
    cc))
  

(define (region-fmt loc str)
  (regexp-replace #rx"{0}"
                  (cldr-ref (time-zone-names loc) 'regionFormat)
                  str))
