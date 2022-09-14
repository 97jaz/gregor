#lang racket/base

(require racket/contract/base
         racket/match
         "../../generics.rkt"
         "../../core/math.rkt"
         "../ast.rkt"
         "../parse-state.rkt"
         "../l10n/numbers.rkt")

(provide (struct-out Hour))

(define (hour-fmt ast t loc)
  (define h (->hours t))
  
  (match ast
    [(Hour _ 'half n)      (num-fmt loc (mod1 h 12) n)]
    [(Hour _ 'full n)      (num-fmt loc h n)]
    [(Hour _ 'half/zero n) (num-fmt loc (remainder h 12) n)]
    [(Hour _ 'full/one n)  (num-fmt loc (mod1 h 24) n)]))

(define (hour-fmt-compile ast loc)
  (match-define (Hour _ kind n) ast)
  (compose1 (num-fmt-compile loc n)
            (match kind
              ['half      (lambda (h) (mod1 h 12))]
              ['full      values]
              ['half/zero (lambda (h) (remainder h 12))]
              ['full/one  (lambda (h) (mod1 h 24))])
            ->hours))

(define (hour-parse ast next-ast state ci? loc)
  (define (parse n ok? update)
    (num-parse ast loc state update #:min n #:max 2 #:ok? ok?))
    
  (match ast
    [(Hour _ 'half n)
     (parse n (between/c 1 12) (parse-state/ hour/period))]
    [(Hour _ 'full n)
     (parse n (between/c 0 23)
            (λ (str fs h)
              (parse-state str
                           (set-fields-hour/full fs h))))]
    [(Hour _ 'half/zero n)
     (parse n (between/c 0 11)
            (λ (str fs h)
              (define res (if (zero? h) 12 h))
              (parse-state str (struct-copy fields fs [hour/period res]))))]
    [(Hour _ 'full/one n)
     (parse n (between/c 1 24)
            (λ (str fs h)
              (define res (if (= h 24) 0 h))
              (parse-state str (set-fields-hour/full fs res))))]))

(define (hour-numeric? ast)
  #t)
     
(struct Hour Ast (kind size)
  #:transparent
  #:methods gen:ast
  [(define ast-fmt-contract time-provider-contract)
   (define ast-fmt hour-fmt)
   (define ast-fmt-compile hour-fmt-compile)
   (define ast-parse hour-parse)
   (define ast-numeric? hour-numeric?)])
