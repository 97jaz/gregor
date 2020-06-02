#lang racket/base


(require racket/contract/base
         "../ast.rkt"
         "../parse-state.rkt"
         "../l10n/numbers.rkt")

(provide (struct-out TimeSeparator))

(define (time-separator-fmt ast t loc)
  (time-separator loc))

(define (time-separator-fmt-compile ast loc)
  (define v (time-separator loc))
  (lambda (t) v))

(define (time-separator-parse ast next-ast state ci? loc)
  (define sep (time-separator loc))
  (define re (regexp (string-append "^" (regexp-quote sep))))
  (define input (parse-state-input state))
  
  (if (regexp-match re input)
      (parse-state (substring input (string-length sep))
                   (parse-state-fields state))
      (parse-error ast state)))

(define (separator-numeric? ast)
  #f)

(struct TimeSeparator Ast ()
  #:transparent
  #:methods gen:ast
  [(define (ast-fmt-contract ast) any/c)
   (define ast-fmt time-separator-fmt)
   (define ast-fmt-compile time-separator-fmt-compile)
   (define ast-parse time-separator-parse)
   (define ast-numeric? separator-numeric?)])
