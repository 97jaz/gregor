#lang racket/base

(require racket/contract/base
         racket/match
         "../../generics.rkt"
         "../../core/structs.rkt"
         "../../core/ymd.rkt"
         "../ast.rkt"
         "../parse-state.rkt"
         "../l10n/numbers.rkt")

(provide (struct-out Day))

(define (day-fmt ast t loc)
  (match ast
    [(Day _ 'month n)      (num-fmt loc (->day t) n)]
    [(Day _ 'year n)       (num-fmt loc (->yday t) n)]
    [(Day _ 'week/month n) (num-fmt loc (add1 (quotient (sub1 (->day t)) 7)) n)]
    [(Day _ 'jdn n)        (num-fmt loc (->jdn t) n)]))

(define (day-parse ast state ci? loc)
  (match ast
    [(Day _ 'month n)
     (num-parse ast loc state (parse-state/ day) #:min n #:ok? (between/c 1 31))]
    [(Day _ 'year n)
     (num-parse ast loc state parse-state/ignore #:min n #:ok? (between/c 1 366))]
    [(Day _ 'week/month n)
     (num-parse ast loc state parse-state/ignore #:min n #:ok? (between/c 1 5))]
    [(Day _ 'jdn n)
     (define (update str fs jdn)
       (match-define (YMD y m d) (jdn->ymd jdn))
       
       (parse-state
        str
        (struct-copy fields
                     (set-fields-year/ext fs y)
                     [month m]
                     [day d])))
     
     (num-parse ast loc state update #:min n #:neg #t)]))


(struct Day Ast (kind size)
  #:transparent
  #:methods gen:ast
  [(define ast-fmt-contract date-provider-contract)
   (define ast-fmt day-fmt)
   (define ast-parse day-parse)])
