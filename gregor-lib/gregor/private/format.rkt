#lang racket/base

(require racket/contract/base
         racket/set
         cldr/locale
         "generics.rkt"
         "pattern/ast.rkt"
         "pattern/lexer.rkt")

(define (~t t pattern #:locale [locale (current-cldr-locale-path)])
  (define xs (pattern->ast-list pattern))
  (define required
    (for*/set ([x (in-list xs)]
               [c (in-value (ast-fmt-contract x))]
               #:unless (equal? c any/c))
      c))
  (define omnibus/c (apply and/c (set->list required)))
  
  (cond [(not (omnibus/c t))
         (raise-argument-error '~t
                               (format "~s" (contract-name omnibus/c))
                               0
                               t
                               pattern)]
        [else
         (define fragments (for/list ([x (in-list xs)]) (ast-fmt x t locale)))
         (apply string-append fragments)]))

(provide/contract
 [~t (->i ([t (or/c date-provider? time-provider?)]
           [pattern string?])
          (#:locale [locale string?])
          [result string?])])
