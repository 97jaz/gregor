#lang racket/base

(require racket/match
         cldr/core
         cldr/dates-modern
         cldr/numbers-modern
         "../ast.rkt"
         "../parse-state.rkt"
         "trie.rkt")

(provide (all-defined-out))

(define (l10n-cal loc . path)
  (cldr-ref (ca-gregorian loc) path))

(define (str-parse ast trie state update)
  (define input (parse-state-input state))
  
  (match (trie-longest-match trie (string->list input))
    [(cons key val)
     (update
      (substring input (string-length val))
      (parse-state-fields state)
      (regexp-replace #rx"-alt-variant"
                      (symbol->string key)
                      ""))]
    [_
     (parse-error ast state)]))

(define (sym-parse ast trie state update)
  (str-parse ast trie state
             (λ (in fs val)
               (update in fs (string->symbol val)))))

(define (symnum-parse ast trie state update)
  (str-parse ast trie state
             (λ (in fs val)
               (update in fs (string->number val)))))
