#lang racket/base

(require racket/contract/base
         racket/match
         "../../generics.rkt"
         "../../core/math.rkt"
         "../ast.rkt"
         "../parse-state.rkt"
         "../l10n/numbers.rkt")

(provide (struct-out Minute))

(define (minute-fmt ast t loc)
  (match ast
    [(Minute _ n) (num-fmt loc (->minutes t) n)]))

(define (minute-parse ast state ci? loc)
  (match ast
    [(Minute _ n)
     (num-parse ast loc state (parse-state/ minute) #:min n #:max 2 #:ok? (between/c 0 59))]))

(struct Minute Ast (size)
  #:transparent
  #:methods gen:ast
  [(define ast-fmt-contract time-provider-contract)
   (define ast-fmt minute-fmt)
   (define ast-parse minute-parse)])
