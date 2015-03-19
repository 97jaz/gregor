#lang scribble/manual

@(require scribble/eval
          (for-label (except-in racket/base date date? time)
                     gregor
                     gregor/time
                     data/order))

@(define the-eval (make-base-eval))
@(the-eval '(require gregor
                     gregor/time))

@title[#:tag "date-provider"]{Generic Date Operations}

@declare-exporting[gregor]

@defthing[gen:date-provider any/c]{
An interface, implemented by @racket[date], @racket[datetime],
and @racket[moment], that supplies generic operations on dates.
}

@defproc[(date-provider? [x any/c]) boolean]{
Returns @racket[#t] if @racket[x] implements @racket[gen:date-provider];
@racket[#f] otherwise.
}

@defproc[(->date [d date-provider?]) date?]{
Returns the local @racket[date] corresponding to @racket[d].

@examples[#:eval the-eval
(->date (date 2000 1 1))
(->date (datetime 1969 7 21 2 56))
(->date (moment 2015 3 8 1 #:tz "America/New_York"))
]}

@defproc[(->jdn [d date-provider?]) exact-integer?]{
Returns the @link["http://en.wikipedia.org/wiki/Julian_day"]{Julian day number}
corresponding to the local date component of @racket[d].

@examples[#:eval the-eval
(->jdn (date 1970))
(->jdn (datetime 1969 7 21 2 56))
(->jdn (moment 2015 3 8 1 #:tz "America/New_York"))
]}

@defproc[(->year [d date-provider?]) exact-integer?]{
Returns the year (in the proleptic Gregorian calendar) of the local date
component of @racket[d]. Years are numbered according to ISO 8601. That is,
the year 1 BCE is represented here as the year 0, 2 BCE is -1, and so forth.

@examples[#:eval the-eval
(->year (date 1970))
(->year (datetime -3 3 3 3 33 33))
(->year (moment 2015 3 8 1 #:tz "America/New_York"))
]}

@defproc[(->quarter [d date-provider?]) exact-integer?]{
Returns the quarter (numbered 1-4) of the local date
component of @racket[d].

@examples[#:eval the-eval
(->quarter (date 1970 1 1))
(->quarter (datetime 1970 4 1))
(->quarter (moment 1970 7 1 #:tz "America/New_York"))
(->quarter (moment 1970 10 1 #:tz "Etc/UTC"))
]}

@defproc[(->month [d date-provider?]) exact-integer?]{
Returns the month (numbered 1-12) of the local date
component of @racket[d].

@examples[#:eval the-eval
(->month (date 1970))
(->month (datetime -3 3 3 3 33 33))
(->month (moment 2015 3 8 1 #:tz "America/New_York"))
]}

@defproc[(->day [d date-provider?]) exact-integer?]{
Returns the day of the month of the local date
component of @racket[d].

@examples[#:eval the-eval
(->day (date 1970))
(->day (datetime 1980 2 29))
(->day (moment 2015 3 8 1 #:tz "America/New_York"))
]}

@defproc[(->wday [d date-provider?]) exact-integer?]{
Returns the day of the week (numbered 0-6, starting with Sunday)
of the local date component of @racket[d].

@examples[#:eval the-eval
(->wday (date 1970))
(->wday (datetime 1980 2 29))
(->wday (moment 2015 3 8 1 #:tz "America/New_York"))
]}

@defproc[(->yday [d date-provider?]) exact-integer?]{
Returns the day of the year (numbered from 1)
of the local date component of @racket[d].

@examples[#:eval the-eval
(->yday (date 1970))
(->yday (datetime 1980 12 31))
(->yday (moment 2015 12 31 #:tz "America/New_York"))
]}

@defproc[(->iso-week [d date-provider?]) exact-integer?]{
Returns the @link["http://en.wikipedia.org/wiki/ISO_week_date"]{ISO 8601 week number}
of the local date component of @racket[d].

@examples[#:eval the-eval
(->iso-week (date 2005 1 1))
(->iso-week (datetime 2007 1 1))
(->iso-week (moment 2008 12 31 #:tz "America/New_York"))
]}

@defproc[(->iso-wyear [d date-provider?]) exact-integer?]{
Returns the @link["http://en.wikipedia.org/wiki/ISO_week_date"]{ISO 8601 week-numbering year}
of the local date component of @racket[d].

@examples[#:eval the-eval
(->iso-wyear (date 2005 1 1))
(->iso-wyear (datetime 2007 1 1))
(->iso-wyear (moment 2008 12 31 #:tz "America/New_York"))
]}

@defproc[(->iso-wday [d date-provider?]) exact-integer?]{
Returns the day of the week, numbered according to ISO 8601 (i.e., 1-7,
starting with Monday) of the local date component of @racket[d].

@examples[#:eval the-eval
(->iso-wday (date 1970))
(->iso-wday (datetime 1980 2 29))
(->iso-wday (moment 2015 3 8 1 #:tz "America/New_York"))
]}

@deftogether[(@defproc[(+years [d date-provider?]
                               [n exact-integer?]
                               [#:resolve-offset resolve offset-resolver/c resolve-offset/retain])
                       date-provider?]
              @defproc[(-years [d date-provider?]
                               [n exact-integer?]
                               [#:resolve-offset resolve offset-resolver/c resolve-offset/retain])
                       date-provider?])]{
Adds or subtracts @racket[n] years to/from @racket[d], returning a fresh date provider
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
]}

@deftogether[(@defproc[(+months [d date-provider?]
                                [n exact-integer?]
                                [#:resolve-offset resolve offset-resolver/c resolve-offset/retain])
                       date-provider?]
              @defproc[(-months [d date-provider?]
                                [n exact-integer?]
                                [#:resolve-offset resolve offset-resolver/c resolve-offset/retain])
                       date-provider?])]{
Adds or subtracts @racket[n] months to/from @racket[d], returning a fresh date provider
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
]}

@deftogether[(@defproc[(+weeks [d date-provider?]
                               [n exact-integer?]
                               [#:resolve-offset resolve offset-resolver/c resolve-offset/retain])
                       date-provider?]
              @defproc[(-weeks [d date-provider?]
                               [n exact-integer?]
                               [#:resolve-offset resolve offset-resolver/c resolve-offset/retain])
                       date-provider?])]{
Adds or subtracts @racket[n] weeks to/from @racket[d], returning a fresh date provider
the same type as @racket[d]. If that would result in an invalid date, the date
is adjusted backward. Additionally, if the result would contain invalid time
components, the provided (or default) offset-resolver is used to adjust the result.

@examples[#:eval the-eval
(+weeks (date 1970) 3)
(-weeks (date 1970) 3)
(+weeks (datetime 2016 2 22) 1)
(-weeks (moment 2015 3 29 2) 3 #:resolve-offset resolve-offset/raise)
]}

@deftogether[(@defproc[(+days [d date-provider?]
                              [n exact-integer?]
                              [#:resolve-offset resolve offset-resolver/c resolve-offset/retain])
                       date-provider?]
              @defproc[(-days [d date-provider?]
                              [n exact-integer?]
                              [#:resolve-offset resolve offset-resolver/c resolve-offset/retain])
                       date-provider?])]{
Adds or subtracts @racket[n] days to/from @racket[d], returning a fresh date provider
the same type as @racket[d]. If that would result in an invalid date, the date
is adjusted backward. Additionally, if the result would contain invalid time
components, the provided (or default) offset-resolver is used to adjust the result.

@examples[#:eval the-eval
(+days (date 1970) 3)
(-days (date 1970) 3)
(+days (datetime 2016 2 28) 1)
(-days (moment 2015 3 11 2) 3 #:resolve-offset resolve-offset/raise)
]}

@deftogether[(@defproc[(sunday? [d date-provider?]) boolean?]
              @defproc[(monday? [d date-provider?]) boolean?]
              @defproc[(tuesday? [d date-provider?]) boolean?]
              @defproc[(wednesday? [d date-provider?]) boolean?]
              @defproc[(thursday? [d date-provider?]) boolean?]
              @defproc[(friday? [d date-provider?]) boolean?]
              @defproc[(saturday? [d date-provider?]) boolean?])]{
Predicates that are satisfied when @racket[d] falls on the named day of the week.
}

@defproc[(at-time [d date-provider?]
                  [t time-provider?]
                  [#:resolve-offset resolve offset-resolver/c resolve-offset/raise])
         datetime-provider?]{
Returns an object combining the date components of @racket[d] with the time components
of @racket[t]. The result should not lose any information from @racket[d] (other than whatever
time components @racket[d] may have, which will be replaced by those of @racket[t]). So, for
example, if @racket[d] is a @racket[moment], the result will also be a @racket[moment] with
the same time zone as @racket[d].

@examples[#:eval the-eval
(at-time (date 1970) (time 14 30))
(at-time (datetime 2015 3 8 2) (time 2))
(at-time (moment 2015 3 8 #:tz "America/New_York") (time 2) #:resolve-offset resolve-offset/post)
]}

@defproc[(at-midnight [d date-provider?]
                      [#:resolve-offset resolve offset-resolver/c resolve-offset/raise])
         datetime-provider?]{
Equivalent to @racket[(at-time d (time 0) #:resolve-offset resolve)].
}

@defproc[(at-noon [d date-provider?]
                  [#:resolve-offset resolve offset-resolver/c resolve-offset/raise])
         datetime-provider?]{
Equivalent to @racket[(at-time d (time 12) #:resolve-offset resolve)].
}
