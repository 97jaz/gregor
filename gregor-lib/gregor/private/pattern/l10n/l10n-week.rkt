#lang racket/base

(require racket/match
         cldr/core
         cldr/likely-subtags
         "../../generics.rkt"
         "../../core/math.rkt")

(provide (all-defined-out))

(define (l10n-week-based-year loc d)
  (match (l10n-week-based-week+year loc d)
    [(cons _ y) y]))

(define (l10n-week-of-year loc d)
  (match (l10n-week-based-week+year loc d)
    [(cons w _) w]))

(define (l10n-week-of-month loc d)
  (define cwday (l10n-cwday loc d))
  (define dom (->day d))
  (define week (day+offset->week dom (start-of-week-offset loc dom cwday)))
  
  (cond [(zero? week)
         (l10n-week-of-month loc (-days d dom))]
        [(let ([min (l10n-min-days/week loc)])
           (or (>= cwday min)
               (= (->month d) (->month (+days d (- min cwday))))))
         week]
        [else
         1]))

(define (l10n-week-based-week+year loc d)
  (define cwday (l10n-cwday loc d))
  (define doy (->yday d))
  (define year (->year d))
  (define week (day+offset->week doy (start-of-week-offset loc doy cwday)))
  
  (cond [(zero? week)
         (l10n-week-based-week+year loc (-days d doy))]
        [(let ([min (l10n-min-days/week loc)])
           (or (>= cwday min)
               (= (->month d) (->month (+days d (- min cwday))))))
         (cons week year)]
        [else
         (cons 1 (add1 year))]))

(define (l10n-cwday loc d)
  (define fst-cwday (l10n-first-cwday loc))
  (define cwday (->iso-wday d))
  (add1 (mod (- cwday fst-cwday) 7)))

(define (l10n-min-days/week loc)
  (string->number
   (cldr-ref (week-data)
             `(minDays ,(locale->cldr-region loc))
             (λ () (cldr-ref (week-data) '(minDays |001|))))))

(define (l10n-first-cwday loc)
  (dow->cwday (l10n-first-dow loc)))

(define (l10n-first-dow loc)
  (cldr-ref (week-data)
            `(firstDay ,(locale->cldr-region loc))
            (λ () (cldr-ref (week-data) '(firstDay |001|)))))

(define (start-of-week-offset loc day cwday)
  (define week-start (mod (- day cwday) 7))
  
  (cond [(> (add1 week-start) (l10n-min-days/week loc))
         (- 7 week-start)]
        [else
         (- week-start)]))

(define (day+offset->week day offset)
  (quotient (+ offset 7 (sub1 day))
            7))

(define (dow->cwday str)
  (case str
    [("mon") 1]
    [("tue") 2]
    [("wed") 3]
    [("thu") 4]
    [("fri") 5]
    [("sat") 6]
    [("sun") 7]))

(define (wday->dow n)
  (case n
    [(0) "sun"]
    [(1) "mon"]
    [(2) "tue"]
    [(3) "wed"]
    [(4) "thu"]
    [(5) "fri"]
    [(6) "sat"]))
