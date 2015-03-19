#lang racket/base

(require cldr/database
         cldr/locale
         tzinfo
         "../../generics.rkt"
         "gmt-offset.rkt"
         "metazone.rkt"
         "zone-util.rkt")

(provide zone/nonloc-fmt)

(define (zone/nonloc-fmt loc t kind size)
  (define zone (->timezone t))
  (define long? (eq? size 'long))
  
  (cond [(integer? zone)
         (zone/gmt-fmt loc t long?)]
        [else
         (define canon (canonical-tzid zone))
         (define posix (->posix t))
         (define tzn (time-zone-names loc))
         (define zdata (cldr-ref tzn `(zone ,@(split-tzid canon) ,size) #f))
         (define tzoff (utc-seconds->tzoffset zone posix))
         (define otype (nonloc-offset-type tzoff kind))
         
         (or (and zdata (cldr-ref zdata otype #f))
             (and zdata (type-fallback t zdata otype))
             (metazone-fmt loc t canon posix otype size)
             (zone/gmt-fmt loc t long?))]))


(define (nonloc-offset-type tzoff kind)
  (cond [(eq? kind 'generic)   'generic]
        [(tzoffset-dst? tzoff) 'daylight]
        [else                  'standard]))

(define (type-fallback t zdata otype)
  (cond [(not (cldr-ref zdata 'daylight #f))
         (or (cldr-ref zdata 'generic #f)
             (cldr-ref zdata 'standard #f))]
        
        [(and (eq? otype 'generic)
              (let* ([ts (list (-days t 184)
                               t
                               (+days t 184))]
                     [ts-offsets (map ->utc-offset ts)])
                (apply = ts-offsets)))
         (cldr-ref zdata 'standard #f)]))

(define (metazone-fmt loc t tzid posix otype size)
  (define tzn (time-zone-names loc))
  (define mz (metazone-of tzid posix))
  (define mdata (and mz (cldr-ref tzn (list 'metazone mz size) #f)))

  (and mdata
       (let ()
         (define mfmt (or (and mdata (cldr-ref mdata otype #f))
                          (and mdata (type-fallback t mdata otype))))
         (define country (or (locale->cldr-region loc) "001"))
         (define pref (metazone-preferred-zone mz country))
         
         (cond [(equal? pref tzid)
                mfmt]
               [else
                (define cc (preferred-zone->country tzid))
                
                (cond [cc   (fallback-fmt loc mfmt (country-name loc cc))]
                      [else (fallback-fmt loc mfmt (city-of loc tzid))])]))))


(define (fallback-fmt loc mz-format city/country)
  (regexp-replaces (cldr-ref (time-zone-names loc) 'fallbackFormat)
                   `([#rx"{0}" ,city/country] [#rx"{1}" ,mz-format])))


                  