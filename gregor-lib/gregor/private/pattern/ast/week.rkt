#lang racket/base

(require racket/contract/base
         racket/match
         "../../generics.rkt"
         "../ast.rkt"
         "../parse-state.rkt"
         "../l10n/numbers.rkt"
         "../l10n/l10n-week.rkt")

(provide (struct-out Week))

(define (week-fmt ast t loc)
  (match ast
    [(Week _ 'year n)  (num-fmt loc (l10n-week-of-year loc t) n)]
    [(Week _ 'month n) (num-fmt loc (l10n-week-of-month loc t) n)]))

(define (week-fmt-compile ast loc)
  (match ast
    [(Week _ 'year n)
     (define fmt (num-fmt-compile loc n))
     (lambda (t)
       (fmt (l10n-week-of-year loc t)))]
    [(Week _ 'month n)
     (define fmt
       (num-fmt-compile loc n))
     (lambda (t)
       (fmt (l10n-week-of-month loc t)))]))

(define (week-parse ast next-ast state ci? loc)
  (match ast
    [(Week _ 'year n)  (num-parse ast loc state parse-state/ignore #:min n #:max 2 #:ok? (between/c 1 53))]
    [(Week _ 'month n) (num-parse ast loc state parse-state/ignore #:min n #:max 1 #:ok? (between/c 1 6))]))

(define (week-numeric? ast)
  #t)

(struct Week Ast (kind size)
  #:transparent
  #:methods gen:ast
  [(define ast-fmt-contract date-provider-contract)
   (define ast-fmt week-fmt)
   (define ast-fmt-compile week-fmt-compile)
   (define ast-parse week-parse)
   (define ast-numeric? week-numeric?)])
