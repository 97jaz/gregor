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

@title[#:tag "date-arithmetic-provider"]{Date Arithmetic}

@declare-exporting[gregor]

@defthing[gen:date-arithmetic-provider any/c]{
An interface that defines date arithmetic operations. It is implemented by
all objects that satisfy either @racket[date-provider?] or @racket[period?].
}

@defproc[(date-arithmetic-provider? [x any/c]) boolean?]{
Returns @racket[#t] if @racket[x] implements @racket[gen:date-arithmetic-provider];
@racket[#f] otherwise.
}

@deftogether[(@defproc[(+years [d date-arithmetic-provider?]
                               [n exact-integer?]
                               [#:resolve-offset resolve offset-resolver/c resolve-offset/retain])
                       date-arithmetic-provider?]
              @defproc[(-years [d date-arithmetic-provider?]
                               [n exact-integer?]
                               [#:resolve-offset resolve offset-resolver/c resolve-offset/retain])
                       date-arithmetic-provider?])]{
Adds or subtracts @racket[n] years to/from @racket[d], returning a fresh date arithmetic provider
the same type as @racket[d]. Where possible, the result will differ from the input
only in its year component. However, when changing only the year would result in an
invalid date, the date is adjusted backward. Additionally, if the result
would contain invalid time components, the provided (or default) offset-resolver
is used to adjust the result.

@examples[#:eval the-eval
(+years (date 1970) 5)
(-years (date 1970) 1)
(-years (datetime 1980 2 29) 1)
(+years (moment 2014 3 8 2 #:tz "America/New_York") 1)
(+years (moment 2014 3 8 2 #:tz "America/New_York") 1 #:resolve-offset resolve-offset/pre)
(-years (days 2) 5)
]}

@deftogether[(@defproc[(+months [d date-arithmetic-provider?]
                                [n exact-integer?]
                                [#:resolve-offset resolve offset-resolver/c resolve-offset/retain])
                       date-arithmetic-provider?]
              @defproc[(-months [d date-arithmetic-provider?]
                                [n exact-integer?]
                                [#:resolve-offset resolve offset-resolver/c resolve-offset/retain])
                       date-arithmetic-provider?])]{
Adds or subtracts @racket[n] months to/from @racket[d], returning a fresh date arithmetic provider
the same type as @racket[d]. Where possible, the result will differ from the input
only in its month (and, possibly, year) components. However, when changing only
these components would result in an invalid date, the date is adjusted backward.
Additionally, if the result would contain invalid time components, the provided
(or default) offset-resolver is used to adjust the result.

@examples[#:eval the-eval
(+months (date 1970) 30)
(+months (datetime 2015 12 29) 2)
(-months (datetime 2015 3 29) 1)
(+months (moment 2015 2 8 2) 1)
(+months (moment 2015 2 8 2) 1 #:resolve-offset resolve-offset/raise)
(-months (months 8) 3)
]}

@deftogether[(@defproc[(+weeks [d date-arithmetic-provider?]
                               [n exact-integer?]
                               [#:resolve-offset resolve offset-resolver/c resolve-offset/retain])
                       date-arithmetic-provider?]
              @defproc[(-weeks [d date-arithmetic-provider?]
                               [n exact-integer?]
                               [#:resolve-offset resolve offset-resolver/c resolve-offset/retain])
                       date-arithmetic-provider?])]{
Adds or subtracts @racket[n] weeks to/from @racket[d], returning a fresh date arithmetic provider
the same type as @racket[d]. If that would result in an invalid date, the date
is adjusted backward. Additionally, if the result would contain invalid time
components, the provided (or default) offset-resolver is used to adjust the result.

@examples[#:eval the-eval
(+weeks (date 1970) 3)
(-weeks (date 1970) 3)
(+weeks (datetime 2016 2 22) 1)
(-weeks (moment 2015 3 29 2) 3 #:resolve-offset resolve-offset/raise)
(+weeks (minutes 7) 1)
]}

@deftogether[(@defproc[(+days [d date-arithmetic-provider?]
                              [n exact-integer?]
                              [#:resolve-offset resolve offset-resolver/c resolve-offset/retain])
                       date-arithmetic-provider?]
              @defproc[(-days [d date-arithmetic-provider?]
                              [n exact-integer?]
                              [#:resolve-offset resolve offset-resolver/c resolve-offset/retain])
                       date-arithmetic-provider?])]{
Adds or subtracts @racket[n] days to/from @racket[d], returning a fresh date arithmetic provider
the same type as @racket[d]. If that would result in an invalid date, the date
is adjusted backward. Additionally, if the result would contain invalid time
components, the provided (or default) offset-resolver is used to adjust the result.

@examples[#:eval the-eval
(+days (date 1970) 3)
(-days (date 1970) 3)
(+days (datetime 2016 2 28) 1)
(-days (moment 2015 3 11 2) 3 #:resolve-offset resolve-offset/raise)
(-days (period [years 5] [hours 2]) 20)
]}

@deftogether[(@defproc[(+date-period [d date-arithmetic-provider?]
                                     [p date-period?]
                                     [#:resolve-offset resolve offset-resolver/c resolve-offset/retain])
                       date-arithmetic-provider?]
              @defproc[(-date-period [d date-arithmetic-provider?]
                                     [p date-period?]
                                     [#:resolve-offset resolve offset-resolver/c resolve-offset/retain])
                       date-arithmetic-provider?])]{
Adds or subtracts @racket[p] to/from @racket[d], returning a fresh date arithmetic provider
the same type as @racket[d]. If that would result in an invalid date, the date
is adjusted backward. Additionally, if the result would contain invalid time
components, the provided (or default) offset-resolver is used to adjust the result.

@examples[#:eval the-eval
(+date-period (date 1970) (years 10))
(-date-period (date 1970) (weeks 1))
(+date-period (minutes 4) (days 2))
]}
