#lang scribble/manual

@(require scribble/eval
          (for-label (except-in racket/base date date? time)
                     gregor))

@(define the-eval (make-base-eval))
@(the-eval '(require gregor))

@title[#:tag "moment-provider"]{Generic Moment Operations}

@declare-exporting[gregor]

@defthing[gen:moment-provider any/c]{
An interface, implemented by @racket[moment], that supplies generic
operations on moments.
}

@defproc[(moment-provider? [x any/c]) boolean?]{
Returns @racket[#t] if @racket[x] implements @racket[gen:moment-provider];
@racket[#f] otherwise.
}

@defproc[(->moment [t moment-provider?]) moment?]{
Returns the @racket[moment] corresponding to @racket[t].
}

@defproc[(->utc-offset [t moment-provider?]) (integer-in -64800 64800)]{
Returns the UTC offset of @racket[t] in seconds.

@examples[#:eval the-eval
(->utc-offset (moment 1970 #:tz "Etc/UTC"))
(->utc-offset (moment 1970 1 1 #:tz "America/New_York"))
(->utc-offset (moment 1970 6 1 #:tz "America/New_York"))
(->utc-offset (moment 1970 6 1 #:tz -18000))
]}

@defproc[(->timezone [t moment-provider?]) tz/c]{
Returns the time zone component of @racket[t], whether it is an IANA ID
or a UTC offset.

@examples[#:eval the-eval
(->timezone (moment 1970 #:tz "Etc/UTC"))
(->timezone (moment 1970 1 1 #:tz "America/New_York"))
(->timezone (moment 1970 6 1 #:tz -18000))
]}

@defproc[(->tzid [t moment-provider?]) (or/c string? false/c)]{
Returns the time zone component of @racket[t] only if it is an IANA ID. If it is
a UTC offset, @racket[#f] is returned.

@examples[#:eval the-eval
(->tzid (moment 1970 #:tz "Etc/UTC"))
(->tzid (moment 1970 6 1 #:tz -18000))
]}

@defproc[(adjust-timezone [t moment-provider?] [tz tz/c]) moment-provider?]{
Returns a moment provider @racket[m], such that:

@racket[(and (moment=? t (->moment m)) (equal? tz (->timezone m)))].

@examples[#:eval the-eval
(adjust-timezone (moment 1970 #:tz "Etc/UTC") "Antarctica/Troll")
(adjust-timezone (moment 1970 6 1 0 0 0 #:tz "Europe/Paris") -18000)
]}
