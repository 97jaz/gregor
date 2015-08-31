#lang scribble/manual

@(require scribble/eval
          (for-label (except-in racket/base date date? time)
                     gregor
                     gregor/time
                     data/order))

@(define the-eval (make-base-eval))
@(the-eval '(require gregor
                     gregor/time))

@title[#:tag "time-provider"]{Generic Time Operations}

@declare-exporting[gregor]

@defthing[gen:time-provider any/c]{
An interface, implemented by @racket[time], @racket[datetime],
and @racket[moment], that supplies generic operations on times.
}

@defproc[(time-provider? [x any/c]) boolean]{
Returns @racket[#t] if @racket[x] implements @racket[gen:time-provider];
@racket[#f] otherwise.
}

@defproc[(->time [t time-provider?]) time?]{
Returns the local @racket[time] corresponding to @racket[t].

@examples[#:eval the-eval
(->time (time 12 45 10))
(->time (datetime 1969 7 21 2 56))
(->time (moment 2015 3 8 1 #:tz "America/New_York"))
]}

@defproc[(->hours [t time-provider?]) (integer-in 0 23)]{
Returns the hour of the day from @racket[t].

@examples[#:eval the-eval
(->hours (time 12 45 10))
(->hours (datetime 1969 7 21 2 56))
(->hours (moment 2015 3 8 1 #:tz "America/New_York"))
]}

@defproc[(->minutes [t time-provider?]) (integer-in 0 59)]{
Returns the minute of the hour from @racket[t].

@examples[#:eval the-eval
(->minutes (time 12 45 10))
(->minutes (datetime 1969 7 21 2 56))
(->minutes (moment 2015 3 8 1 #:tz "America/New_York"))
]}

@defproc[(->seconds [t time-provider?]
                    [fractional? boolean? #f])
         (if fractional?
             (and/c rational? (>=/c 0) (</c 60))
             (integer-in 0 59))]{
Returns the seconds from @racket[t]. If @racket[fractional?] is @racket[#t],
then the fraction of the second will be included; otherwise, the result is
an integer.

@examples[#:eval the-eval
(->seconds (time 12 45 10 123456789))
(->seconds (datetime 1969 7 21 2 56 30 123456789) #t)
(->seconds (moment 2015 3 8 1 0 0 999999999 #:tz "America/New_York") #t)
]}

@defproc[(->milliseconds [t time-provider?]) exact-integer?]{
Returns the milliseconds from @racket[t].

@examples[#:eval the-eval
(->milliseconds (time 12 45 10 123456789))
(->milliseconds (datetime 1969 7 21 2 56 30 123456789))
(->milliseconds (moment 2015 3 8 1 0 0 999999999 #:tz "America/New_York"))
]}

@defproc[(->microseconds [t time-provider?]) exact-integer?]{
Returns the microseconds from @racket[t].

@examples[#:eval the-eval
(->microseconds (time 12 45 10 123456789))
(->microseconds (datetime 1969 7 21 2 56 30 123456789))
(->microseconds (moment 2015 3 8 1 0 0 999999999 #:tz "America/New_York"))
]}

@defproc[(->nanoseconds [t time-provider?]) exact-integer?]{
Returns the nanoseconds from @racket[t].

@examples[#:eval the-eval
(->nanoseconds (time 12 45 10 123456789))
(->nanoseconds (datetime 1969 7 21 2 56 30 123456789))
(->nanoseconds (moment 2015 3 8 1 0 0 999999999 #:tz "America/New_York"))
]}

@defproc[(on-date [t time-provider?]
                  [d date-provider?]
                  [#:resolve-offset resolve offset-resolver/c resolve-offset/raise])
         datetime-provider?]{
Combines the time fields of @racket[t] with the date fields of @racket[d] to
produce a datetime provider. Any time zone information from @racket[t] will
be preserved in the result.

@examples[#:eval the-eval
(on-date (time 0) (date 1970))
(on-date (datetime 1 2 3 4 5 6 7) (datetime 2020 12 20))
(on-date (moment 2000 1 1 2 #:tz "America/New_York")
         (date 2015 3 8)
         #:resolve-offset resolve-offset/post)
]}
