#lang racket/base

(require racket/match
         racket/string
         cldr/database
         "../../datetime.rkt"
         "../../generics.rkt")

(provide metazone-of
         metazone-preferred-zone
         preferred-zone->country)

(struct epoch (mz from to))

(define (metazone-of canonical-olson-id posix)
  (for/first ([e (in-list (metazone-index canonical-olson-id))]
              #:when (and (>= posix (epoch-from e))
                          (< posix (epoch-to e))))
    (epoch-mz e)))

(define (metazone-preferred-zone mz cc)
  (or (hash-ref preferred-zones (cons mz cc) #f)
      (hash-ref preferred-zones (cons mz "001") #f)))

(define (preferred-zone->country tzid)
  (hash-ref zone-to-country tzid #f))

(define (metazone-index tzid)
  (hash-ref!
   METAZONE-INDEX
   tzid
   (λ ()
     (define segments (string-split tzid "/"))
     (define mzs (cldr-ref (meta-zones) `(metazoneInfo timezone ,@segments) '()))
     (map (λ (x)
            (define src (cldr-ref x 'usesMetazone))
            (epoch (cldr-ref src '_mzone)
                   (parse-date (cldr-ref src '_from #f) -inf.0)
                   (parse-date (cldr-ref src '_to #f) +inf.0)))
          mzs))))

(define (parse-date str default)
  (match str
    [(regexp #px"(....)-(..)-(..) (..):(..)" (cons _ xs))
     (datetime->posix
      (apply datetime (map string->number xs)))]
    [_ default]))

(define-values (preferred-zones zone-to-country)
  (for/fold ([pref (hash)] [inv (hash)])
            ([x (in-list (cldr-ref (meta-zones) 'metazones))])
    (match x 
      [(hash-table ('mapZone (hash-table ('_other mz) ('_territory t) ('_type z))))
       (define key (cons mz t))
       (values (hash-set pref key z)
               (hash-set inv z t))])))

(define METAZONE-INDEX (make-hash))
