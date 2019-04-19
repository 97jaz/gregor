#lang scribble/manual

@(require scribble/eval
          (for-label (except-in racket/base date date? time)
                     racket/contract
                     gregor
                     gregor/time
                     data/order
                     data/splay-tree))

@(define the-eval (make-base-eval))
@(the-eval '(require gregor
                     data/splay-tree))

@title[#:tag "datetime"]{Combined Date and Time}

@declare-exporting[gregor]

The @racket[datetime] struct represents the combination of a @racket[date] and a
@racket[time]; that is, it represents a date at a particular time-of-day. However,
it does not include time zone information, so it does not represent an absolute
moment in time.

@defproc[(datetime [year exact-integer?]
                   [month (integer-in 1 12) 1]
                   [day (day-of-month/c year month) 1]
                   [hour (integer-in 0 23) 0]
                   [minute (integer-in 0 59) 0]
                   [second (integer-in 0 59) 0]
                   [nanosecond (integer-in 0 999999999) 0])
         datetime?]{
Constructs a @racket[datetime] with the given date and time fields.

@examples[#:eval the-eval
(datetime 1970)
(datetime 1969 7 21 2 56)
]}

@defproc[(datetime? [x any/c]) boolean?]{
Returns @racket[#t] if @racket[x] is a @racket[datetime]; @racket[#f] otherwise.
}

@defproc[(jd->datetime [jd real?]) datetime?]{
Returns the @racket[datetime] corresponding to the given
@link["http://en.wikipedia.org/wiki/Julian_day"]{Julian day}, which is the number of
solar days that have elapsed since 12:00 UT on November 24, 4714 BC in the
proleptic Gregorian calendar.

@examples[#:eval the-eval
(jd->datetime 0)
(jd->datetime 2440587.5)
]}

@defproc[(posix->datetime [posix real?]) datetime?]{
Returns the @racket[datetime] corresponding to the given
@link["http://en.wikipedia.org/wiki/Unix_time"]{POSIX time}, which is the number of
seconds that have elapsed since 00:00 UTC on January 1, 1970.

@examples[#:eval the-eval
(posix->datetime 0)
(posix->datetime 2147483648)
]}

@defproc[(datetime->iso8601 [dt datetime?]) string?]{
Returns an ISO 8601 string representation of @racket[dt].

@examples[#:eval the-eval
(datetime->iso8601 (datetime 1970))
(datetime->iso8601 (datetime 1969 7 21 2 56))
(datetime->iso8601 (datetime 1 2 3 4 5 6 7))
]}

@deftogether[(@defproc[(datetime=? [x datetime?] [y datetime?]) boolean?]
              @defproc[(datetime<? [x datetime?] [y datetime?]) boolean?]
              @defproc[(datetime<=? [x datetime?] [y datetime?]) boolean?]
              @defproc[(datetime>? [x datetime?] [y datetime?]) boolean?]
              @defproc[(datetime>=? [x datetime?] [y datetime?]) boolean?])]{
Comparison functions on datetimes.

@examples[#:eval the-eval
(datetime=? (datetime 1970 1 1) (datetime 1970))
(datetime<? (datetime 1970) (datetime 1969 7 21 2 56))
(datetime>? (datetime 1970) (datetime 1969 7 21 2 56))
]}

@defthing[datetime-order order?]{
An order defined on datetimes.

@examples[#:eval the-eval
(datetime-order (datetime 1970 1 1) (datetime 1970))
(datetime-order (datetime 1970) (datetime 1969 7 21 2 56))
(datetime-order (datetime 1969 7 21 2 56) (datetime 1970))
(make-splay-tree datetime-order)
]
}
