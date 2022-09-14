#lang racket/base

(require racket/contract/base
         racket/match
         "../../generics.rkt"
         "../ast.rkt"
         "../l10n/iso-offset.rkt"
         "../l10n/gmt-offset.rkt"
         "../l10n/zone-id.rkt"
         "../l10n/zone-nonloc.rkt"
         "../l10n/zone-loc.rkt")

(provide (struct-out Zone))

(define (zone-fmt ast t loc)
  (match ast
    [(Zone _ 'iso/basic   pat)    (zone/iso-fmt t #f #f pat)]
    [(Zone _ 'iso/ext     pat)    (zone/iso-fmt t #t #f pat)]
    [(Zone _ 'iso/basic/z pat)    (zone/iso-fmt t #f #t pat)]
    [(Zone _ 'iso/ext/z   pat)    (zone/iso-fmt t #t #t pat)]
    [(Zone _ 'gmt 'short)         (zone/gmt-fmt loc t #f)]
    [(Zone _ 'gmt 'long)          (zone/gmt-fmt loc t #t)]
    [(Zone _ 'id 'short)          (zone-short-id t)]
    [(Zone _ 'id 'long)           (zone-long-id t)]
    [(Zone _ 'offset-name size)   (zone/nonloc-fmt loc t 'specific size)]
    [(Zone _ 'generic size)       (zone/nonloc-fmt loc t 'generic size)]
    [(Zone _ 'city _)             (zone/city-fmt loc t)]
    [(Zone _ 'generic/loc _)      (zone/generic-loc-fmt loc t)]))

(define (zone-fmt-compile ast loc)
  (lambda (t)
    (zone-fmt ast t loc)))

(define (zone-fmt-contract ast)
  (match ast
    [(Zone _ 'iso/basic _)        moment-provider?]
    [(Zone _ 'iso/basic/z _)      moment-provider?]
    [(Zone _ 'iso/ext _)          moment-provider?]
    [(Zone _ 'iso/ext/z _)        moment-provider?]
    [(Zone _ 'gmt _)              moment-provider?]
    [_                            tzid-provider?]))

(define (zone-parse ast next-ast state ci? loc)
  (match ast
    [(Zone _ 'iso/basic pat)      (zone/iso-parse ast state pat #f "")]
    [(Zone _ 'iso/basic/z pat)    (zone/iso-parse ast state pat #t "")]
    [(Zone _ 'iso/ext pat)        (zone/iso-parse ast state pat #f ":")]
    [(Zone _ 'iso/ext/z pat)      (zone/iso-parse ast state pat #t ":")]
    [(Zone _ 'id 'short)          (zone-short-id-parse ast state ci?)]
    [(Zone _ 'id 'long)           (zone-long-id-parse ast state ci?)]))

(define (zone-numeric? ast)
  #f)

(struct Zone Ast (kind size)
  #:transparent
  #:methods gen:ast
  [(define ast-fmt-contract zone-fmt-contract)
   (define ast-fmt zone-fmt)
   (define ast-fmt-compile zone-fmt-compile)
   (define ast-parse zone-parse)
   (define ast-numeric? zone-numeric?)])
