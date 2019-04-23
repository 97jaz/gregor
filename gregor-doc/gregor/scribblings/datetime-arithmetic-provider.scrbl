#lang scribble/manual

@(require scribble/eval
          (for-label (except-in racket/base date date? time)
                     racket/contract
                     gregor
                     gregor/time
                     gregor/period
                     data/order))

@(define the-eval (make-base-eval))
@(the-eval '(require gregor
                     gregor/time
                     gregor/period))

@title[#:tag "datetime-arithmetic-provider"]{Datetime Arithmetic}

@declare-exporting[gregor]

@defthing[gen:datetime-arithmetic-provider any/c]{
An interface that defines datetime arithmetic operations. It is implemented by
all objects that satisfy @racket[datetime?], @racket[moment?], or @racket[period?].
}

@defproc[(datetime-arithmetic-provider? [x any/c]) boolean]{
Returns @racket[#t] if @racket[x] implements @racket[gen:datetime-arithmetic-provider];
@racket[#f] otherwise.
}

@deftogether[(@defproc[(+period [dt datetime-arithmetic-provider?]
                                [p period?])
                       datetime-arithmetic-provider?]
              @defproc[(-period [dt datetime-arithmetic-provider?]
                                [p period?])
                       datetime-arithmetic-provider?])]{
Adds or subtracts @racket[p] to/from @racket[dt], returning a fresh
datetime arithmetic provider the same type as @racket[dt].

@examples[#:eval the-eval
(+period (datetime 1970) (period [years 5] [hours 2]))
(-period (moment 2015 3 8 3 #:tz "America/New_York") (hours 2))
(+period (years 10) (years -5))
]}
