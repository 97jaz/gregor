#lang racket/base

(require racket/contract/base
         racket/match
         "../../generics.rkt"
         "../ast.rkt"
         "../parse-state.rkt"
         "../l10n/numbers.rkt"
         "../l10n/named-trie.rkt"
         "../l10n/symbols.rkt")

(provide (struct-out Month))

(define (month-fmt ast t loc)
  (define m (->month t))
  
  (match ast
    [(Month _ 'numeric n) (num-fmt loc m n)]
    [(Month _ kind size)  (l10n-cal loc 'months kind size m)]))

(define (month-parse ast state ci? loc)
  (match ast
    [(Month _ 'numeric n)
     (num-parse ast loc state (parse-state/ month) #:min n #:max 2 #:ok? (between/c 1 12))]
    [(Month _ kind size)
     (symnum-parse ast (month-trie loc ci? kind size) state (parse-state/ month))]))

(struct Month Ast (kind size)
  #:transparent
  #:methods gen:ast
  [(define ast-fmt-contract date-provider-contract)
   (define ast-fmt month-fmt)
   (define ast-parse month-parse)])
