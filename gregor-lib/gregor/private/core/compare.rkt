#lang racket/base

(require data/order
         (for-syntax racket/base
                     syntax/parse
                     racket/syntax))

(provide
  (struct-out comparison)
  build-comparison)

(struct comparison (=? <? <=? >? >=? comparator order))

(define-syntax (build-comparison stx)
  (syntax-parse stx #:literals (quote)
    [(_ (quote name-prefix:id) pred?:id ->num:id)
     #:with comparator-id (id/suffix #'name-prefix '-comparator)
     #:with =?-id (id/suffix #'name-prefix '=?)
     #:with <?-id (id/suffix #'name-prefix '<?)
     #:with >?-id (id/suffix #'name-prefix '>?)
     #:with <=?-id (id/suffix #'name-prefix '<=?)
     #:with >=?-id (id/suffix #'name-prefix '>=?)
     #:with order-id (id/suffix #'name-prefix '-order)
     #'(let ()
         (define (comparator-id x y)
           (define diff (- (->num x) (->num y)))
           (cond [(negative? diff) '<]
                 [(zero? diff)     '=]
                 [else             '>]))

         (define (=?-id x y) (eq? '= (comparator-id x y)))
         (define (<?-id x y) (eq? '< (comparator-id x y)))
         (define (>?-id x y) (eq? '> (comparator-id x y)))

         (define (<=?-id x y)
           (case (comparator-id x y)
             [(< =) #t]
             [else  #f]))

         (define (>=?-id x y)
           (case (comparator-id x y)
             [(> =) #t]
             [else  #f]))

         (define order-id (order 'order-id pred? comparator-id))

         (comparison =?-id <?-id <=?-id >?-id >=?-id comparator-id order-id))]))

(define-for-syntax (id/suffix id sym)
  (format-id id "~a~a" id sym))

