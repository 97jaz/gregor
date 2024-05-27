#lang racket/base

(require racket/match
         "../../generics.rkt"
         "../../clock.rkt"
         "../ast.rkt"
         "../parse-state.rkt"
         "../l10n/l10n-week.rkt"
         "../l10n/numbers.rkt")

(provide (struct-out Year)
         current-two-digit-year-resolver)

(define (year-fmt ast t loc)
  (define Y (->year t))
  (define (short y) (remainder y 100))
  (define (era y) (if (positive? y) y (abs (sub1 y))))
  (define (wyear) (l10n-week-based-year loc t))
  
  (match ast
    [(Year _ 'normal 2)   (num-fmt loc (short (era Y)) 2)]
    [(Year _ 'normal min) (num-fmt loc (era Y) min)]
    [(Year _ 'week 2)     (num-fmt loc (short (era (wyear))) 2)]
    [(Year _ 'week n)     (num-fmt loc (era (wyear)) n)]
    [(Year _ 'ext n)      (num-fmt loc Y n)]
    [(Year _ 'cyclic _)   (num-fmt loc (era Y) 1)]
    [(Year _ 'related n)  (num-fmt loc Y n)]))

(define (year-fmt-compile ast loc)
  (define (short y) (remainder y 100))
  (define (era y) (if (positive? y) y (abs (sub1 y))))
  (define (wyear t) (l10n-week-based-year loc t))
  (define num-fmt2 (num-fmt-compile loc 2))
  (match ast
    [(Year _ 'normal 2)
     (compose1 num-fmt2 short era ->year)]
    [(Year _ 'normal w)
     (compose1 (num-fmt-compile loc w) era ->year)]
    [(Year _ 'week 2)
     (compose1 num-fmt2 short era wyear)]
    [(Year _ 'week w)
     (compose1 (num-fmt-compile loc w) era wyear)]
    [(Year _ 'ext w)
     (compose1 (num-fmt-compile loc w) ->year)]
    [(Year _ 'cyclic _)
     (compose1 (num-fmt-compile loc 1) era ->year)]
    [(Year _ 'related w)
     (compose1 (num-fmt-compile loc w) ->year)]))

(define (year-parse ast next-ast state ci? loc)
  (define (min->max n)
    (if (and next-ast (ast-numeric? next-ast))
        n
        #f))

  (define (parse/era min)
    (num-parse ast loc state (parse-state/ year/era) #:min min #:max (min->max min)))

  (define (parse/two update)
    (define (wrapped-update str fs y)
      (update str fs ((current-two-digit-year-resolver) y)))
    (num-parse ast loc state wrapped-update #:min 2 #:max 2))

  (define (parse/ext min)
    (define (update str fs y)
      (parse-state str
                   (set-fields-year/ext fs y)))

    (num-parse ast loc state update #:min min #:max (min->max min) #:neg #t))

  (match ast
    [(Year _ 'normal 2)   (parse/two (parse-state/ year/era))]
    [(Year _ 'normal n)   (parse/era n)]
    [(Year _ 'week 2)     (parse/two parse-state/ignore)]
    [(Year _ 'week n)     (num-parse ast loc state parse-state/ignore #:min n #:max (min->max n))]
    [(Year _ 'ext n)      (parse/ext n)]
    [(Year _ 'cyclic _)   (parse/era 1)]
    [(Year _ 'related n)  (parse/ext n)]))

(define (year-numeric? ast)
  #t)

(struct Year Ast (kind min)
  #:transparent
  #:methods gen:ast
  [(define ast-fmt-contract date-provider-contract)
   (define ast-fmt year-fmt)
   (define ast-fmt-compile year-fmt-compile)
   (define ast-parse year-parse)
   (define ast-numeric? year-numeric?)])

(define (default-two-digit-year-resolver parsed-year)
  (define current-year (->year (now)))
  (define lo (- current-year 50))
  (define t (if (>= lo 0)
                (remainder lo 100)
                (+ 99 (remainder (add1 lo) 100))))
  
  (+ parsed-year
     lo
     (if (< parsed-year t)
         100
         0)
     (- t)))

(define current-two-digit-year-resolver
  (make-parameter default-two-digit-year-resolver))