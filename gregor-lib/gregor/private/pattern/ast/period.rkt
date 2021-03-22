#lang racket/base

(require racket/match
         cldr/core
         "../../generics.rkt"
         "../ast.rkt"
         "../parse-state.rkt"
         "../l10n/named-trie.rkt"
         "../l10n/symbols.rkt")

(provide (struct-out Period))

(define (period-fmt ast t loc)
  (define p (if (< (->hours t) 12) 'am 'pm))
  
  (match ast
    [(Period _ size) (l10n-cal loc 'dayPeriods 'format size p)]))

(define (period-fmt-compile ast loc)
  (match-define (Period _ size) ast)
  (define periods
    (l10n-cal loc 'dayPeriods 'format size))
  (lambda (t)
    (cldr-ref periods (if (< (->hours t) 12) 'am 'pm))))

(define (period-parse ast next-ast state ci? loc)
  (match ast
    [(Period _ size)
     (sym-parse ast (period-trie loc ci? size) state
                (λ (str fs sym)
                  (case sym
                    [(am pm) (parse-state str (struct-copy fields fs [period sym]))]
                    [else (parse-error ast state)])))]))

(define (period-numeric? ast)
  #f)

(struct Period Ast (size)
  #:transparent
  #:methods gen:ast
  [(define ast-fmt-contract time-provider-contract)
   (define ast-fmt period-fmt)
   (define ast-fmt-compile period-fmt-compile)
   (define ast-parse period-parse)
   (define ast-numeric? period-numeric?)])
