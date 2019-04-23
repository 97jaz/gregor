#lang scribble/manual

@(require scribble/eval
          (for-label (except-in racket/base date date? time)
                     racket/contract
                     gregor
                     data/order
                     data/splay-tree))

@(define the-eval (make-base-eval))
@(the-eval '(require gregor
                     data/splay-tree))

@title[#:tag "moment"]{Moments}

@declare-exporting[gregor]

The @racket[moment] struct represents the combination of a @racket[datetime] and
a time zone.

@defproc[(moment [year exact-integer?]
                 [month (integer-in 1 12) 1]
                 [day (day-of-month/c year month) 1]
                 [hour (integer-in 0 23) 0]
                 [minute (integer-in 0 59) 0]
                 [second (integer-in 0 59) 0]
                 [nanosecond (integer-in 0 999999999) 0]
                 [#:tz tz tz/c (current-timezone)]
                 [#:resolve-offset resolve offset-resolver/c resolve-offset/raise])
         moment?]{
Constructs a @racket[moment] with the given date and time fields, time zone, and
offset-resolver.

@examples[#:eval the-eval
(moment 1970)
(moment 1969 7 21 2 56 #:tz "Etc/UTC")
(moment 2015 3 8 2 #:tz -18000)
(moment 2015 3 8 2 #:tz "America/New_York")
(moment 2015 3 8 2 #:tz "America/New_York" #:resolve-offset resolve-offset/pre)
(moment 2015 3 8 2 #:tz "America/New_York" #:resolve-offset resolve-offset/post)
]}

@defproc[(moment? [x any/c]) boolean?]{
Returns @racket[#t] if @racket[x] is a @racket[moment]; @racket[#f] otherwise.
}

@defproc[(moment->iso8601 [m moment?]) string?]{
Returns an ISO 8601 string representation of @racket[m]. Since ISO 8601
doesn't support IANA time zones, that data is discarded; only the UTC offset
is used in the result. See @racket[moment->iso8601/tzid] for a function that
preserves the IANA time zone information.

@examples[#:eval the-eval
(moment->iso8601 (moment 1970 #:tz "Etc/UTC"))
(moment->iso8601 (moment 1969 7 21 2 56 #:tz 0))
(moment->iso8601 (moment 1 2 3 4 5 6 7 #:tz "America/Los_Angeles"))
]}

@defproc[(moment->iso8601/tzid [m moment?]) string?]{
Returns a string representation of @racket[m] comprising the ISO 8610
representation plus the IANA time zone, if @racket[m] has one.

@examples[#:eval the-eval
(moment->iso8601/tzid (moment 1970 #:tz "Etc/UTC"))
(moment->iso8601/tzid (moment 1969 7 21 2 56 #:tz 0))
(moment->iso8601/tzid (moment 1 2 3 4 5 6 7 #:tz "America/Los_Angeles"))
]}

@deftogether[(@defproc[(moment=? [x moment?] [y moment?]) boolean?]
              @defproc[(moment<? [x moment?] [y moment?]) boolean?]
              @defproc[(moment<=? [x moment?] [y moment?]) boolean?]
              @defproc[(moment>? [x moment?] [y moment?]) boolean?]
              @defproc[(moment>=? [x moment?] [y moment?]) boolean?])]{
Comparison functions on moments. These are @emph{temporal} comparison functions,
which take into consideration time zone data. In particular, @racket[moment=?]
does not implement the same notion of equality as @racket[equal?] on moments.

@examples[#:eval the-eval
(moment=? (moment 1970 1 1) (moment 1970))

(moment=? (moment 1969 12 31 19 #:tz "America/New_York") (moment 1970 #:tz "Etc/UTC"))
(equal? (moment 1969 12 31 19 #:tz "America/New_York") (moment 1970 #:tz "Etc/UTC"))

(moment<? (moment 1970 #:tz "Etc/UTC") (moment 1970 #:tz "America/New_York"))
(moment>? (moment 1970) (moment 1969 7 21 2 56))
]}

@defthing[moment-order order?]{
An order defined on moments.

@examples[#:eval the-eval
(moment-order (moment 1970 1 1) (moment 1970))
(moment-order (moment 1970) (moment 1969 7 21 2 56))
(moment-order (moment 1969 7 21 2 56) (moment 1970))
(make-splay-tree moment-order)
]
}
