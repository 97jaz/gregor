#lang racket/base

(require racket/generic
         racket/list
         racket/match
         "parse-state.rkt"
         "../exn.rkt"
         "../generics.rkt")

(provide (all-defined-out))

(define-generics ast
  (ast-fmt-contract ast)
  (ast-fmt ast t loc)
  (ast-fmt-compile ast loc)
  (ast-parse ast next-ast state ci? loc)
  (ast-numeric? ast))

(struct Ast (pat))

(define (date-provider-contract ast) date-provider?)
(define (time-provider-contract ast) time-provider?)
(define (moment-provider-contract ast) moment-provider?)

(define (parse-error ast state)
  (raise-parse-error (Ast-pat ast)
                     (parse-state-input state)))
