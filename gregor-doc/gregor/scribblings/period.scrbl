#lang scribble/manual

@(require scribble/eval
          (for-label (except-in racket/base date date? time)
                     racket/contract
                     racket/match
                     gregor
                     gregor/time
                     gregor/period))

@(define the-eval (make-base-eval))
@(the-eval '(require racket/match
                     gregor
                     gregor/time
                     gregor/period))

@title[#:tag "period"]{Date and Time Periods}

@defmodule[gregor/period]

@deftogether[(@defproc[(years [n exact-integer?]) date-period?]
              @defproc[(months [n exact-integer?]) date-period?]
              @defproc[(weeks [n exact-integer?]) date-period?]
              @defproc[(days [n exact-integer?]) date-period?]
              @defproc[(hours [n exact-integer?]) time-period?]
              @defproc[(minutes [n exact-integer?]) time-period?]
              @defproc[(seconds [n exact-integer?]) time-period?]
              @defproc[(milliseconds [n exact-integer?]) time-period?]
              @defproc[(microseconds [n exact-integer?]) time-period?]
              @defproc[(nanoseconds [n exact-integer?]) time-period?])]{
Per-field period constructors.

@examples[#:eval the-eval
(years 3)
(days -20)
(seconds 900)
]}

@defthing[empty-period period?]{
Returns a period representing no time.

@examples[#:eval the-eval
empty-period
]}

@defproc[(period [p period?] ...) period?]{
Returns a period representing the sum of the given @racket[p]s.
@examples[#:eval the-eval
(period)
(period [years 6] [days 40] [hours 20] [milliseconds 100])
(period [years 10] [years -5])
]

The same identifier also acts as a @emph{match expander} with the same syntax:
@examples[#:eval the-eval
(match (months 4)
  [(period [years y] [months m] [hours h]) (list y m h)])
]}

@defproc[(period? [v any/c]) boolean?]{
Returns @racket[#t] if @racket[v] is a period, @racket[#f] otherwise.
}

@defproc[(date-period? [p period?]) boolean?]{
Returns @racket[#t] if all of @racket[p]'s time fields are @racket[0], @racket[#f] otherwise.
Equivalent to:
@racketblock[(equal? p (period->date-period p))]
}

@defproc[(time-period? [p period?]) boolean?]{
Returns @racket[#t] if all of @racket[p]'s date fields are @racket[0], @racket[#f] otherwise.
Equivalent to:
@racketblock[(equal? p (period->time-period p))]
}

@defproc[(period-empty? [p period?]) boolean?]{
Returns @racket[#t] if all of @racket[p]'s fields are @racket[0], @racket[#f] otherwise.
Equivalent to:
@racketblock[(andmap (compose zero? cdr) (period->list p))]
}

@defproc[(period-ref [p period?] [f temporal-unit/c]) exact-integer?]{
Returns the value in period @racket[p] corresponding to field @racket[f].
@examples[#:eval the-eval
(period-ref (years 10) 'years)
(period-ref (years 10) 'hours)
]}

@defproc[(period-set [p period?] [f temporal-unit/c] [n exact-integer?]) period?]{
Returns a fresh period equivalent to @racket[p], except that field @racket[f] is set to @racket[n].
@examples[#:eval the-eval
(period-set (years 10) 'years -10)
(period-set (years 10) 'hours -10)
]}

@defproc[(period->list [p period?]) (listof (cons/c temporal-unit/c exact-integer?))]{
Returns an association list with the same mappings as @racket[p].
@examples[#:eval the-eval
(period->list (years 10))
(period->list (period))
(period->list (period [hours 20] [minutes 10] [seconds 5]))
]}

@defproc[(period->date-period [p period?]) date-period?]{
Returns a fresh period containing only the date components of @racket[p].
@examples[#:eval the-eval
(period->date-period (period [years 1] [months 2] [days 3] [hours 4] [minutes 5] [seconds 6]))
]}

@defproc[(period->time-period [p period?]) time-period?]{
Returns a fresh period containing only the time components of @racket[p].
@examples[#:eval the-eval
(period->time-period (period [years 1] [months 2] [days 3] [hours 4] [minutes 5] [seconds 6]))
]}

@defproc[(negate-period [p period?]) period?]{
Returns a period where each of @racket[p]'s components is negated.
@examples[#:eval the-eval
(negate-period (period [years 1] [months 2] [days 3] [hours 4] [minutes 5] [seconds 6]))
]}

@deftogether[(
  @defthing[date-units (listof symbol?) #:value '(years months weeks days)]
  @defthing[time-units (listof symbol?)
                       #:value '(hours
                                 minutes
                                 seconds
                                 milliseconds
                                 microseconds
                                 nanoseconds)]

  @defthing[temporal-units (listof symbol?)
                           #:value '(years
                                     months
                                     weeks
                                     days
                                     hours
                                     minutes
                                     seconds
                                     milliseconds
                                     microseconds
                                     nanoseconds)]
)]

@deftogether[(
  @defthing[date-unit/c flat-contract?]
  @defthing[time-unit/c flat-contract?]
  @defthing[temporal-unit/c flat-contract?]
)]{
Contracts requiring that values be members of @racket[date-units], @racket[time-units], or @racket[temporal-units],
respectively.
}

@defproc[(date-period-between [p1 date-provider?]
                              [p2 date-provider?]
                              [fields (listof date-unit/c) date-units])
         date-period?]{
Computes the date period between @racket[p1] and @racket[p2] in terms of the units supplied in
@racket[fields].
@examples[#:eval the-eval
(date-period-between (date 1959 5 22) (date 1980 1 18) '(years months days))
]}

@defproc[(time-period-between [p1 time-provider?]
                              [p2 time-provider?]
                              [fields (listof time-unit/c) time-units])
         time-period?]{
Computes the time period between @racket[p1] and @racket[p2] in terms of the units supplied in
@racket[fields].
@examples[#:eval the-eval
(time-period-between (datetime 1970) (now))
]}

@defproc[(period-between [p1 datetime-provider?]
                         [p2 datetime-provider?]
                         [fields (listof temporal-unit/c) temporal-units])
         period?]{
Computes the period between @racket[p1] and @racket[p2] in terms of the units supplied in
@racket[fields].
@examples[#:eval the-eval
(period-between (datetime 1970) (now) '(years months days hours minutes seconds))
]}
