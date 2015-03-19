#lang racket/base

(require racket/match)

(provide invert-hash->trie
         list->trie
         trie-longest-match)

(struct nothing ())
(struct trie (v m) #:transparent)
(struct cased-trie (t ci?))

(define empty (trie (nothing) '()))

(define (list->trie xs ci?)
  (define =? (get=? ci?))
  
  (cased-trie
   (for/fold ([t empty]) ([x (in-list xs)])
     (ins t (string->list x) (cons (string->symbol x) x) =?))
   =?))

(define (invert-hash->trie h ci?)
  (define =? (get=? ci?))
  
  (cased-trie
   (for/fold ([t empty]) ([(k v) (in-hash h)])
     (ins t (string->list v) (cons k v) =?))
   =?))

(define (trie-longest-match ct cs)
  (match-define (cased-trie t =?) ct)
  (longest t cs =?))

(define (ins t ks v =?)
  (match* (t ks v)
    [((trie _ m) '() x)
     (trie x m)]
    [((trie v m) (cons k ks) x)
     (let* ([t (or (ref m k =?) empty)]
            [t (ins t ks x =?)])
       (trie v (set m k t)))]))

(define (longest t ks =? [best #f])
  (match* (t ks)
    [((trie (nothing) _) '()) best]
    [((trie x _) '()) x]
    [((trie x m) (cons k ks))
     (define new-best (if (nothing? x) best x))
     (match (ref m k =?)
       [#f new-best]
       [m (longest m ks =? new-best)])]))
     

(define (ref m k =?)
  (for/first ([p (in-list m)]
              #:when (=? (car p) k))
    (cdr p)))

(define (set m k v)
  (cons (cons k v) m))

(define (get=? ci?)
  (if ci? char-ci=? char=?))

