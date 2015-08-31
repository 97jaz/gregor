#lang scribble/manual

@(require scribble/eval
          (for-label (except-in racket/base date date? time)
                     gregor
                     gregor/time
                     gregor/period
                     data/order))

@(define the-eval (make-base-eval))
@(the-eval '(require gregor
                     gregor/time
                     gregor/period))

@title[#:tag "time-arithmetic-provider"]{Time Arithmetic}

@declare-exporting[gregor]

@defthing[gen:time-arithmetic-provider any/c]{
An interface that defines time arithmetic operations. It is implemented by
all objects that satisfy either @racket[time-provider?] or @racket[period?].
}

@defproc[(time-arithmetic-provider? [x any/c]) boolean]{
Returns @racket[#t] if @racket[x] implements @racket[gen:time-arithmetic-provider];
@racket[#f] otherwise.
}

@deftogether[(@defproc[(+hours [t time-arithmetic-provider?]
                               [n exact-integer?])
                       time-arithmetic-provider]
              @defproc[(-hours [t time-arithmetic-provider?]
                               [n exact-integer?])
                       time-arithmetic-provider?])]{
Adds or subtracts @racket[n] hours to/from @racket[t], returning a fresh
time arithmetic provider the same type as @racket[t].

@examples[#:eval the-eval
(+hours (time 22) 4)
(-hours (datetime 1970) 12)
(+hours (moment 2015 3 8 1 #:tz "America/New_York") 1)
(-hours (years 5) 20)
]}

@deftogether[(@defproc[(+minutes [t time-arithmetic-provider?]
                                 [n exact-integer?])
                       time-arithmetic-provider?]
              @defproc[(-minutes [t time-arithmetic-provider?]
                                 [n exact-integer?])
                       time-arithmetic-provider?])]{
Adds or subtracts @racket[n] minutes to/from @racket[t], returning a fresh
time arithmetic provider the same type as @racket[t].

@examples[#:eval the-eval
(+minutes (time 22) 4)
(-minutes (datetime 1970) 12)
(+minutes (moment 2015 3 8 1 23 59 #:tz "America/New_York") 1)
(-minutes (years 5) 20)
]}

@deftogether[(@defproc[(+seconds [t time-arithmetic-provider?]
                                 [n exact-integer?])
                       time-arithmetic-provider?]
              @defproc[(-seconds [t time-arithmetic-provider?]
                                 [n exact-integer?])
                       time-arithmetic-provider?])]{
Adds or subtracts @racket[n] seconds to/from @racket[t], returning a fresh
time arithmetic provider the same type as @racket[t].

@examples[#:eval the-eval
(+seconds (time 22) 4)
(-seconds (datetime 1970) 12)
(+seconds (moment 2015 3 8 1 59 59 #:tz "America/New_York") 1)
(-seconds (years 5) 20)
]}

@deftogether[(@defproc[(+milliseconds [t time-arithmetic-provider?]
                                      [n exact-integer?])
                       time-arithmetic-provider?]
              @defproc[(-milliseconds [t time-arithmetic-provider?]
                                      [n exact-integer?])
                       time-arithmetic-provider?])]{
Adds or subtracts @racket[n] milliseconds to/from @racket[t], returning a fresh
time arithmetic provider the same type as @racket[t].

@examples[#:eval the-eval
(+milliseconds (time 22) 4)
(-milliseconds (datetime 1970) 12)
(+milliseconds (moment 2015 3 8 1 59 59 999000000 #:tz "America/New_York") 1)
(-milliseconds (years 5) 20)
]}

@deftogether[(@defproc[(+microseconds [t time-arithmetic-provider?]
                                      [n exact-integer?])
                       time-arithmetic-provider?]
              @defproc[(-microseconds [t time-arithmetic-provider?]
                                      [n exact-integer?])
                       time-arithmetic-provider?])]{
Adds or subtracts @racket[n] microseconds to/from @racket[t], returning a fresh
time arithmetic provider the same type as @racket[t].

@examples[#:eval the-eval
(+microseconds (time 22) 4)
(-microseconds (datetime 1970) 12)
(+microseconds (moment 2015 3 8 1 59 59 999999000 #:tz "America/New_York") 1)
(-microseconds (years 5) 20)
]}

@deftogether[(@defproc[(+nanoseconds [t time-arithmetic-provider?]
                                     [n exact-integer?])
                       time-arithmetic-provider?]
              @defproc[(-nanoseconds [t time-arithmetic-provider?]
                                     [n exact-integer?])
                       time-arithmetic-provider?])]{
Adds or subtracts @racket[n] nanoseconds to/from @racket[t], returning a fresh
time arithmetic provider the same type as @racket[t].

@examples[#:eval the-eval
(+nanoseconds (time 22) 4)
(-nanoseconds (datetime 1970) 12)
(+nanoseconds (moment 2015 3 8 1 59 59 999999999 #:tz "America/New_York") 1)
(-nanoseconds (years 5) 20)
]}

@deftogether[(@defproc[(+time-period [t time-arithmetic-provider?]
                                     [p time-period?])
                       time-arithmetic-provider?]
              @defproc[(-time-period [t time-arithmetic-provider?]
                                     [p time-period?])
                       time-arithmetic-provider?])]{
Adds or subtracts @racket[p] to/from @racket[t], returning a fresh
time arithmetic provider the same type as @racket[t].

@examples[#:eval the-eval
(+time-period (time 22) (hours -4))
(+time-period (moment 2015 3 8 1 59 59 999999999 #:tz "America/New_York") (nanoseconds 1))
(-time-period (years 6) (seconds 5))
]}
