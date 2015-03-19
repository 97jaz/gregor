#lang racket/base

(require racket/string
         memoize
         cldr/bcp47
         cldr/database)

(provide (all-defined-out))

(define (split-tzid tzid)
  (string-split tzid "/"))

(define (country-name loc cc)
  (define terr (territories loc))
  (or (cldr-ref terr cc #f)
      (cldr-ref terr "001" #f)))

(define (city-of loc tzid)
  (cldr-ref* (time-zone-names loc)
             `(zone ,@(split-tzid tzid) exemplarCity)
             '(zone Etc Unknown exemplarCity)
             #:fail #f))

(define/memo* (canonical-tzid tzid)
  (and (string? tzid)
       (bcp47-canonical-olson-id tzid)))
