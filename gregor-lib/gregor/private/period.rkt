#lang racket/base

(require racket/contract/base
         racket/contract/region
         racket/match
         racket/unsafe/ops
         racket/string

         (for-syntax racket/base
                     racket/syntax))

;; fields

(define date-units
  '(years months weeks days))

(define time-units
  '(hours minutes seconds milliseconds microseconds nanoseconds))

(define temporal-units
  (append date-units time-units))

(define date-unit/c (apply symbols date-units))
(define time-unit/c (apply symbols time-units))
(define temporal-unit/c (apply symbols temporal-units))

(define fields (list->vector temporal-units))

(define num-date-fields (length date-units))
(define num-fields (vector-length fields))

;; write-proc
(define (write-period p out mode)
  (fprintf out (period->string p)))

(define (period->string p)
  (format "#<period ~a>" (period-members->string p)))

(define (period-members->string p)
  (define/match (pluralize pair)
    [((cons key n))
     (define str (format "~a ~a" n key))
     (cond [(= (abs n) 1) (substring str 0 (sub1 (string-length str)))]
           [else str])])

  (define non-empty
    (filter (λ (pair) (not (zero? (cdr pair))))
            (period->list p)))

  (if (period-empty? p)
      "[empty]"
      (string-append
       "of "
       (string-join (map pluralize non-empty) ", "))))


;; struct def

(struct Period (years months weeks days hours minutes seconds milliseconds microseconds nanoseconds dp? tp?)
  #:transparent
  #:methods gen:custom-write
  [(define write-proc write-period)])

(define period? (procedure-rename Period? 'period?))

(begin-for-syntax
  (define (field->accessor field-stx)
    (define id (format-id #'period "Period-~a" (syntax->datum field-stx)))
    (and (identifier-binding id 0) id)))

(define-match-expander period*
  (λ (stx)
    (syntax-case stx ()
      [(_ (field pat) ...)
       (andmap (λ (fstx) (field->accessor fstx)) (syntax->list #'(field ...)))
       (with-syntax ([(accessor ...) (map field->accessor (syntax->list #'(field ...)))])
         #`(and (app accessor pat) ...))]))
  (make-rename-transformer #'period))

(define date-period? Period-dp?)
(define time-period? Period-tp?)

(define empty-period (Period 0 0 0 0 0 0 0 0 0 0 #t #t))

(define (period-empty? p)
  (equal? p empty-period))

(define (period->list p)
  (for/list ([(f i) (in-indexed (in-vector fields))])
    (cons f (unsafe-struct*-ref p i))))

(define (period-ref p field)
  (define i
    (for/first ([(f i) (in-indexed (in-vector fields))]
                #:when (eq? field f))
      i))

  (and i (unsafe-struct*-ref p i)))

(define (period-set p field n)
  (define ctor (field->constructor field))
  (define val (period-ref p field))
  (period p (ctor (- n val))))


(define/contract period
  (->* () #:rest (listof period?) period?)

  (λ ps
    (define (field-values start end)
      (for/list ([i (in-range start end)])
        (apply + (map (λ (p) (unsafe-struct*-ref p i)) ps))))

    (define date-values (field-values 0 num-date-fields))
    (define time-values (field-values num-date-fields num-fields))
    (define tags
      (list (andmap zero? time-values)
            (andmap zero? date-values)))

    (apply Period (append date-values time-values tags))))

(define (negate-period p)
  (apply Period
         (append (for/list ([i (in-range num-fields)])
                   (- (unsafe-struct*-ref p i)))

                 (list (Period-dp? p)
                       (Period-tp? p)))))

(define (period->date-period p)
  (match-define (period* (years y) (months m) (weeks w) (days d)) p)
  (period (years y) (months m) (weeks w) (days d)))

(define (period->time-period p)
  (match-define (period* (hours h) (minutes m) (seconds s)
                         (milliseconds ms) (microseconds us) (nanoseconds ns)) p)
  (period (hours h) (minutes m) (seconds s)
          (milliseconds ms) (microseconds us) (nanoseconds ns)))


;; simple period constructors

(define field-constructors (make-hash))
(define (field->constructor f)
  (hash-ref field-constructors f))

(define-syntax-rule (mkperiod name d? t?)
  (begin
    (define (name n)
      (struct-copy Period empty-period
                   [name n]
                   [dp? (or (zero? n) d?)]
                   [tp? (or (zero? n) t?)]))
    (hash-set! field-constructors 'name name)))

(define-syntax-rule (dp name) (mkperiod name #t #f))
(define-syntax-rule (tp name) (mkperiod name #f #t))

(dp years)
(dp months)
(dp weeks)
(dp days)
(tp hours)
(tp minutes)
(tp seconds)
(tp milliseconds)
(tp microseconds)
(tp nanoseconds)


(provide (rename-out [period* period]))

(provide/contract
 [period?         (-> any/c boolean?)]
 [date-period?    (-> period? boolean?)]
 [time-period?    (-> period? boolean?)]
 [period-empty?   (-> period? boolean?)]

 [empty-period        (and/c period? date-period? time-period?)]
 [negate-period       (-> period? period?)]
 [period-ref          (-> period? temporal-unit/c exact-integer?)]
 [period-set          (-> period? temporal-unit/c exact-integer? period?)]
 [period->list        (-> period? (listof (cons/c temporal-unit/c exact-integer?)))]
 [period->date-period (-> period? date-period?)]
 [period->time-period (-> period? time-period?)]

 [years           (-> exact-integer? period?)]
 [months          (-> exact-integer? period?)]
 [weeks           (-> exact-integer? period?)]
 [days            (-> exact-integer? period?)]
 [hours           (-> exact-integer? period?)]
 [minutes         (-> exact-integer? period?)]
 [seconds         (-> exact-integer? period?)]
 [milliseconds    (-> exact-integer? period?)]
 [microseconds    (-> exact-integer? period?)]
 [nanoseconds     (-> exact-integer? period?)]

 [date-units      (listof symbol?)]
 [time-units      (listof symbol?)]
 [temporal-units  (listof symbol?)]

 [date-unit/c     flat-contract?]
 [time-unit/c     flat-contract?]
 [temporal-unit/c flat-contract?])
