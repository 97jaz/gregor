#lang racket/base

(require racket/contract/base
         racket/match
         "../../generics.rkt"
         "../ast.rkt"
         "../parse-state.rkt"
         "../l10n/numbers.rkt"
         "../l10n/named-trie.rkt"
         "../l10n/symbols.rkt")

(provide (struct-out Quarter))

(define (quarter-fmt ast t loc)
  (define q (->quarter t))
  
  (match ast
    [(Quarter _ 'numeric n) (num-fmt loc q n)]
    [(Quarter _ kind size)  (l10n-cal loc 'quarters kind size q)]))

(define (quarter-parse ast state ci? loc)
  (match ast
    [(Quarter _ 'numeric n)
     (num-parse ast loc state parse-state/ignore #:min n #:max 2 #:ok? (between/c 1 4))]
    [(Quarter _ kind size)
     (symnum-parse ast (quarter-trie loc ci? kind size) state parse-state/ignore)]))

(struct Quarter Ast (kind min)
  #:transparent
  #:methods gen:ast
  [(define ast-fmt-contract date-provider-contract)
   (define ast-fmt quarter-fmt)
   (define ast-parse quarter-parse)])
