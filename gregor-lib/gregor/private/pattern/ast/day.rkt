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

(define (day-fmt-compile ast loc)
  (match-define (Day _ type width) ast)
  (define num-fmt (num-fmt-compile loc width))
  (define day-value
    (match type
      ['month ->day]
      ['year  ->yday]
      ['jdn   ->jdn]
      ['week/month
        (lambda (t) (add1 (quotient (sub1 (->day t)) 7)))]))
  (compose1 num-fmt day-value))

(define (day-parse ast next-ast state ci? loc)
  (match ast
    [(Day _ 'month n)
     (num-parse ast loc state (parse-state/ day) #:min n #:max 2 #:ok? (between/c 1 31))]
    [(Day _ 'year n)
     (num-parse ast loc state parse-state/ignore #:min n #:max 3 #:ok? (between/c 1 366))]
    [(Day _ 'week/month n)
     (num-parse ast loc state parse-state/ignore #:min n #:max 1 #:ok? (between/c 1 5))]
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

(define (day-numeric? ast)
  #t)

(struct Day Ast (kind size)
  #:transparent
  #:methods gen:ast
  [(define ast-fmt-contract date-provider-contract)
   (define ast-fmt day-fmt)
   (define ast-fmt-compile day-fmt-compile)
   (define ast-parse day-parse)
   (define ast-numeric? day-numeric?)])
