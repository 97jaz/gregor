#lang racket/base

(require racket/format
         racket/match
         cldr/core
         cldr/numbers-modern
         memoize
         "../ast.rkt"
         "../parse-state.rkt")

(provide num-fmt
         num-fmt-compile
         num-parse
         num-string-translate
         num-string-translate-compile
         num-string-untranslate
         num-re
         number-system-symbols
         time-separator)

(define (num-fmt loc n min-width)
  (num-string-translate
   loc
   (~a n #:align 'right #:min-width min-width #:pad-string "0")))

(define (num-fmt-compile loc min-width)
  (define locale-digits (numeral-string loc))
  (lambda (n)
    (define str
      (~a n #:align 'right #:min-width min-width #:pad-string "0"))
    (substitute str locale-digits ZERO)))

(define (num-parse ast loc state update #:min min #:max [max #f] #:neg [neg #f] #:ok? [ok? (λ (x) #t)])
  (define input (parse-state-input state))
  (define re (num-re loc min max neg))
  
  (match (regexp-match re input)
    [(list full-match neg-str nstr)
     (define nums (numeral-string loc))
     (define n (string->number (num-string-untranslate loc nstr)))
     (define result (if (equal? neg-str (minus-sign loc)) (- n) n))
     
     (if (ok? result)
         (update (substring input (string-length full-match))
                 (parse-state-fields state)
                 result)
         (parse-error ast state))]
    [_
     (parse-error ast state)]))

(define (num-string-translate loc str)
  (substitute str (numeral-string loc) ZERO))

(define (num-string-translate-compile loc)
  (lambda (str)
    (substitute str (numeral-string loc) ZERO)))

(define (num-string-untranslate loc str)
  (substitute str
              DEFAULT-DIGITS
              (string-ref (numeral-string loc) 0)))

(define (time-separator loc)
  (cldr-ref (number-system-symbols loc) 'timeSeparator))

(define/memo* (num-re loc min max neg)
  (pregexp
   (format "^(~a)?([~a]{~a,~a})"
           (if neg (minus-sign loc) "")
           (numeral-string loc)
           min
           (or max ""))))
  
(define (substitute src digits zero)
  (list->string
   (for/list ([c src])
     (define i (- (char->integer c) (char->integer zero)))
     (string-ref digits i))))


(define/memo* (numeral-string loc)
  (define sys (default-numsys loc))
  (cldr-ref (numbering-systems) (list sys '_digits)))
  
(define (default-numsys loc)
  (cldr-ref (numbers loc) 'defaultNumberingSystem))

(define (minus-sign loc)
  (cldr-ref (number-system-symbols loc) 'minusSign))

(define (number-system-symbols loc)
  (cldr-ref (numbers loc) 
            (format "symbols-numberSystem-~a"
                    (default-numsys loc))))

(define ZERO #\0)
(define DEFAULT-DIGITS "0123456789")