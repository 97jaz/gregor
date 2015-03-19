#lang racket/base

(require racket/contract/base
         racket/match
         tzinfo
         "core/hmsn.rkt"
         "datetime.rkt"
         "exn.rkt"
         "moment-base.rkt")

(define gap-resolver/c
  (-> tzgap?
      datetime?
      string?
      (or/c moment? #f)      
      moment?))

(define overlap-resolver/c
  (-> tzoverlap?
      datetime?
      string?
      (or/c moment? #f)      
      moment?))

(define offset-resolver/c
  (-> (or/c tzgap? tzoverlap?)
      datetime?
      string?
      (or/c moment? #f)      
      moment?))

(provide offset-resolver/c
         gap-resolver/c
         overlap-resolver/c

         resolve-gap/pre
         resolve-gap/post
         resolve-gap/push

         resolve-overlap/pre
         resolve-overlap/post
         resolve-overlap/retain

         resolve-offset/pre
         resolve-offset/post
         resolve-offset/post-gap/pre-overlap
         resolve-offset/retain
         resolve-offset/push
         resolve-offset/raise

         offset-resolver)

(define (resolve-gap/pre gap target-dt target-tzid orig)
  (match-define (tzgap tm (tzoffset delta _ _) _) gap)
  (Moment (posix->datetime (+ tm delta (- (/ 1 NS/SECOND)))) delta target-tzid))

(define (resolve-gap/post gap target-dt target-tzid orig)
  (match-define (tzgap tm _ (tzoffset delta _ _)) gap)
  (Moment (posix->datetime (+ tm delta)) delta target-tzid))

(define (resolve-gap/push gap target-dt target-tzid orig)
  (match-define (tzgap tm (tzoffset delta1 _ _) (tzoffset delta2 _ _)) gap)
  (Moment (posix->datetime (+ (datetime->posix target-dt) (- delta2 delta1))) delta2 target-tzid))

(define (resolve-overlap/pre overlap target-dt target-tzid orig)
  (match-define (tzoverlap (tzoffset delta _ _) _) overlap)
  (Moment target-dt delta target-tzid))

(define (resolve-overlap/post overlap target-dt target-tzid orig)
  (match-define (tzoverlap _ (tzoffset delta _ _)) overlap)
  (Moment target-dt delta target-tzid))
                 
(define (resolve-overlap/retain overlap target-dt target-tzid orig)
  (match-define (tzoverlap (tzoffset delta1 _ _) (tzoffset delta2 _ _)) overlap)
  (Moment target-dt
          (or (and orig (= (Moment-utc-offset orig) delta1) delta1)
              delta2)
          target-tzid))

(define (offset-resolver rg ro)
  (λ (g/o target-dt target-tzid orig)
    (define fn (if (tzgap? g/o) rg ro))
    (fn g/o target-dt target-tzid orig)))

(define resolve-offset/pre
  (offset-resolver resolve-gap/pre resolve-overlap/pre))

(define resolve-offset/post
  (offset-resolver resolve-gap/post resolve-overlap/post))

(define resolve-offset/post-gap/pre-overlap
  (offset-resolver resolve-gap/post resolve-overlap/pre))

(define resolve-offset/retain
  (offset-resolver resolve-gap/post
                   resolve-overlap/retain))

(define resolve-offset/push
  (offset-resolver resolve-gap/push
                   resolve-overlap/post))

(define (resolve-offset/raise g/o target-dt target-tzid orig)
  (raise-invalid-offset g/o target-dt target-tzid orig))
