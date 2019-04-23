#lang scribble/manual

@(require scribble/eval
          (for-label (except-in racket/base date date? time)
                     racket/contract
                     gregor
                     gregor/time
                     data/order
                     data/splay-tree
                     (prefix-in base: (only-in racket/base time date))))

@(define the-eval (make-base-eval))
@(the-eval '(require gregor/time
                     data/splay-tree))

@title[#:tag "time"]{Time-of-Day}

@defmodule[gregor/time]

Gregor's @racket[time] struct represents a time-of-day, irrespective of date or
time zone. As with Gregor's @racket[date] struct, the name @tt{time} also conflicts
with an @racketlink[base:time]{existing, incompatible definition} in @racket[racket/base].
The situation here is somewhat different, however. While Gregor completely replaces the
functionality offered by the built-in @racketlink[base:date]{date}, it does not replace
that of the built-in @racketlink[base:time]{time} function, which is used for measuring
the time spent evaluating programs.

To mitigate problems that might be caused by this conflict, Gregor does not provide
@racket[time]-related bindings from the @racketmodname[gregor] module. Instead, they are provided
by the @racketmodname[gregor/time] module.

@defproc[(time [hour (integer-in 0 23)]
               [minute (integer-in 0 59) 0]
               [second (integer-in 0 59) 0]
               [nanosecond (integer-in 0 999999999) 0])
         time?]{
Constructs a @racket[time] with the given @racket[hour], @racket[minute],
@racket[second], and @racket[nanosecond] values.

Note the contract on @racket[second]; a @racket[time] is unable to represent
times that fall on added UTC leap-seconds. For a discussion of Gregor's
relationship to UTC, see @secref["time-scale"].

@examples[#:eval the-eval
(time 1 2 3 4)
(time 0)
(time 12)
]}

@defproc[(time? [x any/c]) boolean?]{
Returns @racket[#t] if @racket[x] is a @racket[time]; @racket[#f] otherwise.
}


@defproc[(time->iso8601 [t time?]) string?]{
Returns an ISO 8601 string representation of @racket[t].

@examples[#:eval the-eval
(time->iso8601 (time 1 2 3 4))
(time->iso8601 (time 0))
(time->iso8601 (time 12))
]}

@deftogether[(@defproc[(time=? [x time?] [y time?]) boolean?]
              @defproc[(time<? [x time?] [y time?]) boolean?]
              @defproc[(time<=? [x time?] [y time?]) boolean?]
              @defproc[(time>? [x time?] [y time?]) boolean?]
              @defproc[(time>=? [x time?] [y time?]) boolean?])]{
Comparison functions on times.

@examples[#:eval the-eval
(time=? (time 12 0 0) (time 12))
(time<? (time 1 30) (time 13 30))
(time>? (time 1 2 3 4) (time 1 2 3))
]}

@defthing[time-order order?]{
An order defined on times.

@examples[#:eval the-eval
(time-order (time 12 0 0) (time 12))
(time-order (time 1 30) (time 13 30))
(time-order (time 1 2 3 4) (time 1 2 3))
(make-splay-tree time-order)
]
}
