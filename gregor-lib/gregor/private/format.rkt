#lang racket/base

(require racket/contract/base
         racket/set
         racket/string
         cldr/core
         cldr/likely-subtags
         memoize
         "generics.rkt"
         "pattern/ast.rkt"
         "pattern/lexer.rkt")

(define/memo* (compile-pattern-format pattern locale)
  (define ast (pattern->ast-list pattern))
  (define contract
    (for*/fold ([cs (set)]
                #:result (apply and/c (set->list cs)))
               ([part (in-list ast)]
                [c (in-value (ast-fmt-contract part))]
                #:unless (equal? c any/c))
      (set-add cs c)))
  (define loc (locale->available-cldr-locale locale modern-locale?))
  (define fmts
    (for/list ([part (in-list ast)])
      (ast-fmt-compile part loc)))

  (lambda (t)
    (cond [(not (contract t))
           (raise-argument-error '~t
                                 (format "~s" (contract-name contract))
                                 0
                                 t
                                 pattern)]
          [else
            (string-append*
              (for/list ([fmt (in-list fmts)])
                (fmt t)))])))

(define (~t t pattern #:locale [locale (current-locale)])
  ((compile-pattern-format pattern locale) t))

(provide/contract
 [~t (->i ([t (or/c date-provider? time-provider?)]
           [pattern string?])
          (#:locale [locale string?])
          [result string?])])
