#lang racket/base

(require cldr/bcp47/timezone
         tzinfo
         "../../generics.rkt"
         "../ast.rkt"
         "../parse-state.rkt"
         "named-trie.rkt"
         "symbols.rkt")
         
(provide (all-defined-out))

(define (zone-long-id t)
  (or (->tzid t) "Etc/Unknown"))

(define zone-short-id
  (compose1 tzid->bcp47-timezone-id
            zone-long-id))

(define (zone-short-id-parse ast state ci?)
  (define (update str fs id)
    (define olson (bcp47-timezone-id->tzid id))
       
    (if (tzid-exists? olson)
        (parse-state str
                     (struct-copy fields fs [tzid olson]))
        (parse-error ast state)))
     
  (str-parse ast (zone-short-id-trie ci?) state update))

(define (zone-long-id-parse ast state ci?)
  (str-parse ast (zone-long-id-trie ci?) state (parse-state/ tzid)))
