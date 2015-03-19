#lang racket/base

(require data/order)

(provide (all-defined-out))

(struct comparison (=? <? <=? >? >=? comparator order))

(define (build-comparison name pred? ->num)
  (define (comparator x y)
    (define diff (- (->num x) (->num y)))
  
    (cond [(negative? diff) '<]
          [(zero? diff)     '=]
          [else             '>]))
         
  (define (=? x y) (eq? '= (comparator x y)))
  (define (<? x y) (eq? '< (comparator x y)))
  (define (>? x y) (eq? '> (comparator x y)))
  
  (define (<=? x y)
    (case (comparator x y)
      [(< =) #t]
      [else  #f]))
  
  (define (>=? x y)
    (case (comparator x y)
      [(> =) #t]
      [else  #f]))

  (define the-order (order name pred? comparator))
  
  (comparison =? <? <=? >? >=? comparator the-order))
