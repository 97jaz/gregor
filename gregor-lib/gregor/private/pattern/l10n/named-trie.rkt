#lang racket/base

(require memoize
         cldr/core
         cldr/dates-modern
         cldr/bcp47/timezone
         tzinfo
         "trie.rkt")

(provide (all-defined-out))

(define/memo* (era-trie loc ci? size)
  (common-trie loc ci? (list 'eras size)))

(define/memo* (quarter-trie loc ci? kind size)
  (common-trie loc ci? (list 'quarters kind size)))

(define/memo* (month-trie loc ci? kind size)
  (common-trie loc ci? (list 'months kind size)))

(define/memo* (weekday-trie loc ci? kind size)
  (common-trie loc ci? (list 'days kind size)))

(define/memo* (period-trie loc ci? size)
  (common-trie loc ci? (list 'dayPeriods 'format size)))

(define/memo* (zone-short-id-trie ci?)
  (list->trie (bcp47-timezone-ids) ci?))

(define/memo* (zone-long-id-trie ci?)
  (list->trie (all-tzids) ci?))
  
  
(define (common-trie loc ci? key)
  (invert-hash->trie
   (cldr-ref (ca-gregorian loc) key)
   ci?))

