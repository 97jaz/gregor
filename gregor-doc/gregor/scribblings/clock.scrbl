#lang scribble/manual

@(require scribble/eval
          (for-label (except-in racket/base date date? time)
                     gregor
                     gregor/time))

@(define the-eval (make-base-eval))
@(the-eval '(require gregor))

@title[#:tag "clock"]{Current Date and Time}

@declare-exporting[gregor]

@defparam[current-clock clock (-> rational?)
          #:value current-posix-seconds]{
A parameter that defines the current clock used by all functions
that require the current time. A clock is simply a nullary function that
returns the number of seconds since the UNIX epoch.
The default value is @racket[current-posix-seconds].
}

@defproc[(current-posix-seconds) rational?]{
Returns the number of seconds since the UNIX epoch as a rational number.
This function is implemented as:

@racketblock[
(define (current-posix-seconds)
  (/ (inexact->exact (current-inexact-milliseconds)) 1000))
]
}

@deftogether[(@defproc[(today [#:tz tz tz/c (current-timezone)]) date?]
              @defproc[(today/utc) date?])]{
Returns the current @racket[date] in the specified time zone.

@examples[#:eval the-eval
(parameterize ([current-clock (λ () 0)])
  (list (today/utc)
        (today #:tz "America/Chicago")))
]}

@deftogether[(@defproc[(current-time [#:tz tz tz/c (current-timezone)]) time?]
              @defproc[(current-time/utc) time?])]{
Returns the current @racket[time] in the specified time zone.

@examples[#:eval the-eval
(parameterize ([current-clock (λ () 0)])
  (list (current-time/utc)
        (current-time #:tz "America/Chicago")))
]}

@deftogether[(@defproc[(now [#:tz tz tz/c (current-timezone)]) datetime?]
              @defproc[(now/utc) datetime?])]{
Returns the current @racket[datetime] in the specified time zone.

@examples[#:eval the-eval
(parameterize ([current-clock (λ () 0)])
  (list (now/utc)
        (now #:tz "America/Chicago")))
]}

@deftogether[(@defproc[(now/moment [#:tz tz tz/c (current-timezone)]) moment?]
              @defproc[(now/moment/utc) moment?])]{
Returns the current @racket[moment] in the specified time zone.

@examples[#:eval the-eval
(parameterize ([current-clock (λ () 0)])
  (list (now/moment/utc)
        (now/moment #:tz "America/Chicago")))
]}
