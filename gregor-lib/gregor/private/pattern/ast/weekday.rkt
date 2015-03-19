#lang racket/base

(require racket/contract/base
         racket/match
         "../../generics.rkt"
         "../ast.rkt"
         "../parse-state.rkt"
         "../l10n/numbers.rkt"
         "../l10n/l10n-week.rkt"
         "../l10n/named-trie.rkt"
         "../l10n/symbols.rkt")

(provide (struct-out Weekday/Loc)
         (struct-out Weekday/Std))

(define (->dow t)
  (wday->dow (->wday t)))

(define (weekday/loc-fmt ast t loc)
  (match ast
    [(Weekday/Loc _ 'numeric n) (num-fmt loc (l10n-cwday loc t) n)]
    [(Weekday/Loc _ kind size)  (l10n-cal loc 'days kind size (->dow t))]))

(define (weekday/std-fmt ast t loc)
  (match ast
    [(Weekday/Std _ kind size) (l10n-cal loc 'days kind size (->dow t))]))

(define (weekday/loc-parse ast state ci? loc)
  (match ast
    [(Weekday/Loc _ 'numeric n)
     (num-parse ast loc state parse-state/ignore #:min n #:ok? (between/c 1 7))]
    [(Weekday/Loc _ kind size)
     (sym-parse ast (weekday-trie loc ci? kind size) state parse-state/ignore)]))

(define (weekday/std-parse ast state ci? loc)
  (match ast
    [(Weekday/Std _ kind size)
     (sym-parse ast (weekday-trie loc ci? kind size) state parse-state/ignore)]))

(struct Weekday/Loc Ast (kind size)
  #:transparent
  #:methods gen:ast
  [(define ast-fmt-contract date-provider-contract)
   (define ast-fmt weekday/loc-fmt)
   (define ast-parse weekday/loc-parse)])

(struct Weekday/Std Ast (kind size)
  #:transparent
  #:methods gen:ast
  [(define ast-fmt-contract date-provider-contract)
   (define ast-fmt weekday/std-fmt)
   (define ast-parse weekday/std-parse)])
