#lang racket/base

(require racket/contract/base
         racket/match
         cldr/core
         cldr/likely-subtags
         "date.rkt"
         "datetime.rkt"
         "exn.rkt"
         "moment.rkt"
         "offset-resolvers.rkt"
         "time.rkt"
         "pattern/ast.rkt"
         "pattern/lexer.rkt"
         "pattern/parse-state.rkt")


(define (parse-temporal input
                        pattern
                        ci?
                        locale
                        make-temporal)
  (define cldr-locale (locale->available-cldr-locale locale modern-locale?))
  (define initial-state (parse-state input (fresh-fields)))
  (define xs (pattern->ast-list pattern))

  (match-define (parse-state remaining-input fields)
    (for/fold ([s initial-state]) ([x (in-list xs)])
      (ast-parse x s ci? cldr-locale)))

  (cond [(zero? (string-length remaining-input))
         (make-temporal fields)]
        [else
         (err "Unable to match pattern [~a] against input [~a]"
              pattern input)]))

(define (parse-moment input
                      pattern
                      #:ci? [ci? #t]
                      #:locale [locale (current-locale)]
                      #:resolve-offset [resolve resolve-offset/raise])
  (parse-temporal input pattern ci? locale
                  (λ (fields)
                    (match (fields->datetime+tz fields err)
                      [(cons dt tz) (datetime+tz->moment dt tz resolve)]))))

(define (parse-datetime input
                        pattern
                        #:ci? [ci? #t]
                        #:locale [locale (current-locale)])
  (parse-temporal input pattern ci? locale
                  (λ (fields)
                  (match (fields->datetime+tz fields err)
                    [(cons dt _) dt]))))

(define (parse-date input
                    pattern
                    #:ci? [ci? #t]
                    #:locale [locale (current-locale)])
  (parse-temporal input pattern ci? locale
                  (λ (fields)
                  (match (fields->datetime+tz fields err)
                    [(cons dt _) (datetime->date dt)]))))

(define (parse-time input
                    pattern
                    #:ci? [ci? #t]
                    #:locale [locale (current-locale)])
  (parse-temporal input pattern ci? locale
                  (λ (fields)
                    (fields->time fields err))))

(define (err fmt . args)
  (raise (exn:gregor:parse (apply format fmt args)
                           (current-continuation-marks))))


(provide/contract
 [parse-moment    (->i ([input string?]
                        [pattern string?])
                       (#:ci? [ci? boolean?]
                        #:locale [locale string?]
                        #:resolve-offset [resolve offset-resolver/c])
                       [m moment?])]
 [parse-datetime  (->i ([input string?]
                        [pattern string?])
                       (#:ci? [ci? boolean?]
                        #:locale [locale string?])
                       [dt datetime?])]
 [parse-date      (->i ([input string?]
                        [pattern string?])
                       (#:ci? [ci? boolean?]
                        #:locale [locale string?])
                       [d date?])]
 [parse-time      (->i ([input string?]
                        [pattern string?])
                       (#:ci? [ci? boolean?]
                        #:locale [locale string?])
                       [t time?])])
