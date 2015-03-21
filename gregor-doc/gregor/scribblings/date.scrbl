#lang scribble/manual

@(require scribble/eval
          (for-label (except-in racket/base date date? time)
                     gregor
                     data/order
                     data/splay-tree
                     (prefix-in base: (only-in racket/base date))))

@(define the-eval (make-base-eval))
@(the-eval '(require gregor
                     data/splay-tree))

@title[#:tag "date"]{Dates}

@declare-exporting[gregor]

Gregor provides a @racket[date] struct that represents a calendar date without a time
or time zone. Unfortunately, the name @tt{date} conflicts with an
@racketlink[base:date]{existing, incompatible definition} in @racket[racket/base].

The author of this package considered other names, including @tt{Date} (with a capital D)
and @tt{local-date} (à la @link["http://www.joda.org/joda-time/"]{Joda-Time})
but in the end decided to live with the incompatibility. Gregor's @racket[date],
along with its companion data structures (@racket[time], @racket[datetime], and
@racket[moment]) should be considered a replacement of, not a supplement to, the
built-in Racket @racketlink[base:date]{date}.


@defproc[(date [year exact-integer?]
               [month (integer-in 1 12) 1]
               [day (day-of-month/c year month) 1])
         date?]{
Constructs a @racket[date] with the given @racket[year], @racket[month], and @racket[day].

@examples[#:eval the-eval
(date 1941 12 7)
(date 1965 7)
(date 1970)
]}

@defproc[(date? [x any/c]) boolean?]{
Returns @racket[#t] if @racket[x] is a @racket[date]; @racket[#f] otherwise.
}

@defproc[(jdn->date [jdn exact-integer?]) date?]{
Returns the @racket[date] corresponding to the given
@link["http://en.wikipedia.org/wiki/Julian_day"]{Julian day number}, which is the
number of solar days that have elapsed since 12:00 UT on November 24, 4714 BC in the
proleptic Gregorian calendar.

@examples[#:eval the-eval
(jdn->date 0)
(jdn->date 2440588)
]}

@defproc[(date->iso8601 [d date?]) string?]{
Returns an ISO 8601 string representation of @racket[d].

@examples[#:eval the-eval
(date->iso8601 (date 1941 12 7))
(date->iso8601 (date 1965 7))
(date->iso8601 (date 1970))
]}

@deftogether[(@defproc[(date=? [x date?] [y date?]) boolean?]
              @defproc[(date<? [x date?] [y date?]) boolean?]
              @defproc[(date<=? [x date?] [y date?]) boolean?]
              @defproc[(date>? [x date?] [y date?]) boolean?]
              @defproc[(date>=? [x date?] [y date?]) boolean?])]{
Comparison functions on dates.

@examples[#:eval the-eval
(date=? (date 1970) (date 1970 1 1))
(date<? (date 1941 12 7) (date 1965 7))
(date>? (date 1492) (date 2015))
]}

@defthing[date-order order?]{
An order defined on dates.

@examples[#:eval the-eval
(date-order (date 1970) (date 1970 1 1))
(date-order (date 1941 12 7) (date 1965 7))
(date-order (date 2015) (date 1492))
(make-splay-tree date-order)
]
}
