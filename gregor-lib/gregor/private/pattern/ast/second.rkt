#lang racket/base

(require racket/contract/base
         racket/format
         racket/match
         racket/math
         "../../generics.rkt"
         "../../time.rkt"
         "../../core/hmsn.rkt"
         "../../core/structs.rkt"
         "../ast.rkt"
         "../parse-state.rkt"
         "../l10n/numbers.rkt")

(provide (struct-out Second)
         (struct-out SecondFraction)
         (struct-out Millisecond))

(define (second-fmt ast t loc)
  (match ast
    [(Second _ n) (num-fmt loc (->seconds t) n)]))

(define (second-parse ast state ci? loc)
  (match ast
    [(Second _ n)
     (num-parse ast loc state (parse-state/ second) #:min n #:max 2 #:ok? (between/c 0 59))]))

(define (second/frac-fmt ast t loc)
  (match ast
    [(SecondFraction _ n)
     (define nano-str (~a (->nanoseconds t) #:align 'right #:width 9 #:pad-string "0"))

     (num-string-translate
      loc
      (~a nano-str #:align 'left #:width n #:pad-string "0"))]))

(define (second/frac-parse ast state ci? loc)
  (match ast
    [(SecondFraction _ n)
     (define input (parse-state-input state))
     (define re (num-re loc n #f #f))
     
     (match (regexp-match re input)
       [(list full-match _ nstr)
        (define tstr (num-string-untranslate loc nstr))
        (define fstr (string-append "0." tstr))
        (define fraction (string->number fstr))
        (define nanos (exact-truncate (* NS/SECOND fraction)))
        
        (parse-state (substring input (string-length full-match))
                     (struct-copy fields (parse-state-fields state) [nano nanos]))]
       [_
        (parse-error ast state)])]))

(define (millisecond-fmt ast t loc)
  (match ast
    [(Millisecond _ n)
     (define ms (quotient (time->ns (->time t)) NS/MILLI))
     
     (num-fmt loc ms n)]))

(define (millisecond-parse ast state ci? loc)
  (match ast
    [(Millisecond _ n)
     (define (update str fs ms)
       (parse-state 
        str
        (let ()
          (define ns (* ms NS/MILLI))
     
          (match (day-ns->hmsn ns)
            [(HMSN h m s n)
             (struct-copy fields
                          (set-fields-hour/full fs h)
                          [minute m]
                          [second s]
                          [nano n])]))))
     
     (num-parse ast loc state update #:min n #:ok? (between/c 0 (sub1 MILLI/DAY)))]))

(struct Second Ast (size)
  #:transparent
  #:methods gen:ast
  [(define ast-fmt-contract time-provider-contract)
   (define ast-fmt second-fmt)
   (define ast-parse second-parse)])

(struct SecondFraction Ast (size)
  #:transparent
  #:methods gen:ast
  [(define ast-fmt-contract time-provider-contract)
   (define ast-fmt second/frac-fmt)
   (define ast-parse second/frac-parse)])

(struct Millisecond Ast (size)
  #:transparent
  #:methods gen:ast
  [(define ast-fmt-contract time-provider-contract)
   (define ast-fmt millisecond-fmt)
   (define ast-parse millisecond-parse)])
