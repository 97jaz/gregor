#lang racket/base

(require racket/contract/base
         racket/match
         "../ast.rkt"
         "../parse-state.rkt")

(provide (struct-out Literal))

(define (literal-fmt ast t loc)
  (match ast
    [(Literal _ txt) txt]))

(define (literal-fmt-compile ast loc)
  (match-define (Literal _ txt) ast)
  (lambda (t) txt))

(define (literal-parse ast next-ast state ci? loc)
  (match ast
    [(Literal _ txt)
     (define re (regexp (string-append "^" (regexp-quote txt))))
     (define input (parse-state-input state))
     
     (if (regexp-match re input)
         (parse-state (substring input (string-length txt))
                      (parse-state-fields state))
         (parse-error ast state))]))

(define (literal-numeric? ast)
  #f)

(struct Literal Ast (txt)
  #:transparent
  #:methods gen:ast
  [(define (ast-fmt-contract ast) any/c)
   (define ast-fmt literal-fmt)
   (define ast-fmt-compile literal-fmt-compile)
   (define ast-parse literal-parse)
   (define ast-numeric? literal-numeric?)])
