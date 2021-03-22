#lang racket/base

(require cldr/core
         "../../generics.rkt"
         "../ast.rkt"
         "../parse-state.rkt"
         "../l10n/named-trie.rkt"
         "../l10n/symbols.rkt")

(provide (struct-out Era))

(define (era-fmt ast t loc)
  (define key
    (if (positive? (->year t))
        "1"
        "0"))
  (l10n-cal loc 'eras (Era-size ast) key))

(define (era-fmt-compile ast loc)
  (define tbl
    (l10n-cal loc 'eras (Era-size ast)))
  (lambda (t)
    (define key
      (if (positive? (->year t)) "1" "0"))
    (cldr-ref tbl key)))

(define (era-parse ast next-ast state ci? loc)
  (symnum-parse ast (era-trie loc ci? (Era-size ast)) state (parse-state/ era)))

(define (era-numeric? ast)
  #f)

(struct Era Ast (size)
  #:methods gen:ast
  [(define ast-fmt-contract date-provider-contract)
   (define ast-fmt era-fmt)
   (define ast-fmt-compile era-fmt-compile)
   (define ast-parse era-parse)
   (define ast-numeric? era-numeric?)])
