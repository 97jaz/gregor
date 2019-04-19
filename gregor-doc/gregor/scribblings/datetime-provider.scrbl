#lang scribble/manual

@(require scribble/eval
          (for-label (except-in racket/base date date? time)
                     racket/contract
                     gregor
                     gregor/time
                     data/order))

@(define the-eval (make-base-eval))
@(the-eval '(require gregor
                     gregor/time))

@title[#:tag "datetime-provider"]{Generic Datetime Operations}

@declare-exporting[gregor]

@defthing[gen:datetime-provider any/c]{
An interface, implemented by @racket[datetime],
and @racket[moment], that supplies generic operations on datetimes.
@margin-note{
In fact, @racket[gen:datetime-provider] is also implemented by @racket[date],
which can be treated like a @racket[datetime] with its time component set to
midnight. This should be considered an experimental part of the design, which
may be removed.
}
}

@defproc[(datetime-provider? [x any/c]) boolean?]{
Returns @racket[#t] if @racket[x] implements @racket[gen:datetime-provider];
@racket[#f] otherwise.
}

@defproc[(->datetime/local [t datetime-provider?]) datetime?]{
Returns the local @racket[datetime] corresponding to @racket[t].

@examples[#:eval the-eval
(->datetime/local (datetime 1969 7 21 2 56))
(->datetime/local (moment 2015 3 8 1 #:tz "America/New_York"))
]}

@defproc[(->datetime/utc [t datetime-provider?]) datetime?]{
Returns the UTC @racket[datetime] corresponding to @racket[t].

For a @racket[datetime], @racket[->datetime/local] and @racket[->datetime/utc]
return the same thing.


@examples[#:eval the-eval
(->datetime/utc (datetime 1969 7 21 2 56))
(->datetime/utc (moment 2015 3 8 1 #:tz "America/New_York"))
]}

@defproc[(->posix [t datetime-provider?]) rational?]{
Returns the number of seconds between the UNIX epoch (UTC midnight on January 1, 1970)
and @racket[t], expressed as a rational number.

@examples[#:eval the-eval
(->posix (datetime 1970))
(->posix (moment 2015 3 8 1 #:tz "America/New_York"))
]}

@defproc[(->jd [t datetime-provider?]) rational?]{
Returns the number of days since the Julian epoch (noon on November 24, 4714 BCE
in the proleptic Gregorian calendar), expressed as a rational number.

@examples[#:eval the-eval
(->jd (moment -4713 11 24 12 #:tz "Etc/UTC"))
(->jd (datetime 1970))
]}

@deftogether[(@defproc[(years-between [t1 datetime-provider?] [t2 datetime-provider?])
                       exact-integer?]
              @defproc[(months-between [t1 datetime-provider?] [t2 datetime-provider?])
                       exact-integer?]
              @defproc[(weeks-between [t1 datetime-provider?] [t2 datetime-provider?])
                       exact-integer?]
              @defproc[(days-between [t1 datetime-provider?] [t2 datetime-provider?])
                       exact-integer?]
              @defproc[(hours-between [t1 datetime-provider?] [t2 datetime-provider?])
                       exact-integer?]
              @defproc[(minutes-between [t1 datetime-provider?] [t2 datetime-provider?])
                       exact-integer?]
              @defproc[(seconds-between [t1 datetime-provider?] [t2 datetime-provider?])
                       exact-integer?]
              @defproc[(milliseconds-between [t1 datetime-provider?] [t2 datetime-provider?])
                       exact-integer?]
              @defproc[(microseconds-between [t1 datetime-provider?] [t2 datetime-provider?])
                       exact-integer?]
              @defproc[(nanoseconds-between [t1 datetime-provider?] [t2 datetime-provider?])
                       exact-integer?])]{
Returns the duration between the given date providers, in terms of the chosen
unit. These functions follow the same rules as date and time arithmetic. So, for example,
there is exactly one year between successive January 1sts, whether or not the actual span
is 365 or 366 days.

@examples[#:eval the-eval
(years-between (datetime 2000) (datetime 2001))
(years-between (datetime 2001) (datetime 2002))
(months-between (datetime 2000 3) (datetime 1999 12))
(days-between (moment 2015 3 8  1 59 #:tz "America/Los_Angeles")
              (moment 2015 3 16 1 59 #:tz "America/Los_Angeles"))
(weeks-between (moment 2015 3 8  1 59 #:tz "America/Los_Angeles")
               (moment 2015 3 16 1 59 #:tz "Etc/UTC"))
(days-between (datetime 2015) (datetime 2015 1 14 23 59 59))
(hours-between (moment 2000 #:tz "Etc/UTC")
               (moment 1999 12 31 19 #:tz "America/New_York"))
(minutes-between (datetime 2000) (datetime 2000 1 2))
(seconds-between (datetime 2000) (datetime 2000 1 2))
(milliseconds-between (datetime 2000) (datetime 2000 1 2))
(microseconds-between (datetime 2000) (datetime 2000 1 2))
(nanoseconds-between (datetime 2000) (datetime 2000 1 2))
]}

@defproc[(with-timezone [t datetime-provider?]
                        [tz tz/c]
                        [#:resolve-offset resolve-offset offset-resolver/c])
         moment-provider?]{
Attaches @racket[tz] to the local @racket[datetime] component of @racket[t].
Note that if @racket[t] starts with any timezone information, it is discarded.
@margin-note{
This function is a blunt instrument and is rarely needed. If your aim is to
translate a @racket[moment] into another that represents the same point in
absolute time but in a different time zone, then you're looking for
@racket[adjust-timezone].
}

@examples[#:eval the-eval
(with-timezone (datetime 2000) "America/New_York")
(with-timezone (moment 2000 #:tz "America/New_York") "Europe/Paris")
]}
