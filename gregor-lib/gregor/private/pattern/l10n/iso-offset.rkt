#lang racket/base

(require racket/format
         racket/match
         "../../generics.rkt"
         "../../moment.rkt"
         "../ast.rkt"
         "../parse-state.rkt")

(provide zone/iso-fmt
         zone/iso-parse
         utc-offset-components)

;; The ISO format is not localized.

(define (zone/iso-parse ast state pat z? sep)
  (define input (parse-state-input state))
  (define fs (parse-state-fields state))
    
  (cond [(and z? (regexp-match #rx"^Z" input))
         (parse-state (substring input 1)
                      (struct-copy fields fs [offset 0]))]
        [else
         (define part "(\\d{2})")
         (define nul "()")
         (define opt (string-append "((?:" sep ")\\d{2})?"))
         (define parts
           (case pat
             [(h-m)  (list part opt nul)]
             [(hm)   (list part sep part nul)]
             [(hm-s) (list part sep part opt)]))
         (define re (pregexp (apply string-append "^([-+])" parts)))
  
         (match (regexp-match re input)
           [(list full-match sgn h m s)
            (define sec
              (+ (* 3600 (string->number h))
                 (or (and m (* 60 (string->number m)))
                     0)
                 (or (and s (string->number s))
                     0)))
            
            (define signed-sec
              (if (string=? "+" sgn)
                  sec
                  (- sec)))
            
            (if (tz/c signed-sec)
                (parse-state
                 (substring input (string-length full-match))
                 (struct-copy fields fs [offset signed-sec]))
                (parse-error ast state))]
           
           [_
            (parse-error ast state)])]))
              

(define (zone/iso-fmt t ext? zulu? pat)
  (define off (->utc-offset t))
  
  (cond [(and zulu? (zero? off))
         "Z"]
        [else
         (match-define (vector sgn h m s) (utc-offset-components off))
         (define SEP (if ext? ":" ""))
  
         (define (hours h)
           (~r h #:min-width 2 #:pad-string "0"))
  
         (define (part m opt?)
           (match* (m opt?)
             [(0 #t) ""]
             [(_ _) (string-append SEP (hours m))]))
  
         (match pat
           ['hm   (string-append sgn (hours h) (part m #f))]
           ['h-m  (string-append sgn (hours h) (part m #t))]
           ['hm-s (string-append sgn (hours h) (part m #f) (part s #t))])]))

(define (utc-offset-components off)
  (define sign (if (negative? off) "-" "+"))
  
  (let* ([off (abs off)]
         [h (quotient off 3600)]
         [off (- off (* h 3600))]
         [m (quotient off 60)]
         [s (- off (* m 60))])
    (vector sign h m s)))
