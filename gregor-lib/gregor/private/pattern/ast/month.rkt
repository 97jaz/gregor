#lang racket/base

(require racket/contract/base
         racket/match
         cldr/core
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

(define (month-fmt-compile ast loc)
  (define fmt
    (match ast
      [(Month _ 'numeric n) (num-fmt-compile loc n)]
      [(Month _ kind size)
       (let ([months (l10n-cal loc 'months kind size)])
         (lambda (m)
           (cldr-ref months m)))]))
  (compose1 fmt ->month))

(define (month-parse ast next-ast state ci? loc)
  (match ast
    [(Month _ 'numeric n)
     (num-parse ast loc state (parse-state/ month) #:min n #:max 2 #:ok? (between/c 1 12))]
    [(Month _ kind size)
     (symnum-parse ast (month-trie loc ci? kind size) state (parse-state/ month))]))

(define (month-numeric? ast)
  (match ast
    [(Month _ 'numeric _) #t]
    [_ #f]))

(struct Month Ast (kind size)
  #:transparent
  #:methods gen:ast
  [(define ast-fmt-contract date-provider-contract)
   (define ast-fmt month-fmt)
   (define ast-fmt-compile month-fmt-compile)
   (define ast-parse month-parse)
   (define ast-numeric? month-numeric?)])
