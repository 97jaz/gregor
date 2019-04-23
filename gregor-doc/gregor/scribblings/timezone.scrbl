#lang scribble/manual

@(require scribble/eval
          gregor
          (for-label (except-in racket/base date date? time)
                     racket/contract
                     tzinfo
                     gregor))

@(define the-eval (make-base-eval))
@(the-eval '(require gregor
                     gregor/time))

@title[#:tag "timezone"]{Time Zones and UTC Offsets}

@declare-exporting[gregor]

@defthing[tz/c flat-contract?]{
A time zone, in Gregor, is either:
@itemize[
  @item{an identifier from the IANA @link["http://www.iana.org/time-zones"]{tz database}, like
        @racket["America/New_York"] or @racket["Antarctica/Troll"], or}
  @item{an offset from UTC in seconds, expressed as an exact integer between
        @racket[-64800] and @racket[64800].}
]}

@defparam[current-timezone tz tz/c #:value (system-tzid)]{
A parameter that defines the current time zone. The current time zone is used
as a default value in many Gregor functions, including @racket[moment] and
all of the @seclink["clock"]{clock functions} that rely on the current moment.
}

@section[#:tag "offset-resolvers"]{Resolving UTC Offsets}

Many time zones introduce discontinuities in the local time-line. In
time zones that use daylight saving time (DST), the transition from standard time to DST
introduces a @emph{gap} in the time-line when the local time jumps ahead by an hour.
Similarly, the transition back to standard time introduces an @emph{overlap} when the
clock is set back and the same hour is repeated, only with a different UTC offset.

Whenever a Gregor function might construct a @racket[moment] that falls into a gap
or an overlap, the function will accept an optional keyword argument named
@racket[#:resolve-offset]. The argument value must be an @deftech{offset resolver},
a function satisfying the @racket[offset-resolver/c] contract.

An @tech{offset resolver} comprises a @deftech{gap resolver} and an @deftech{overlap resolver},
functions that satisfy @racket[gap-resolver/c] and @racket[overlap-resolver/c], respectively.

Most functions that take a @racket[#:resolve-offset] parameter use
@racket[resolve-offset/raise] as the default value. This is a simple @tech{offset resolver}
that raises @racket[exn:gregor:invalid-offset] whenever it encounters either a gap or an overlap.

@subsection{Offset Resolvers}

@defthing[offset-resolver/c chaperone-contract?]{
A contract for @tech{offset resolver} functions. The contract is specified as:
@racketblock[
(-> (or/c tzgap? tzoverlap?)
    datetime?
    string?
    (or/c moment? #f)      
    moment?)
]}

@defproc[(offset-resolver [gap-resolver gap-resolver/c]
                          [overlap-resolver overlap-resolver/c])
         offset-resolver/c]{
Constructs an @tech{offset resolver} from the given @racket[gap-resolver] and
@racket[overlap-resolver].
}

@defproc[(resolve-offset/raise [gap-or-overlap (or/c tzgap? tzoverlap?)]
                               [local datetime?]
                               [tzid string?]
                               [orig (or/c moment? #f)])
         moment?]{
An @tech{offset resolver} that unconditionally raises @racket[exn:gregor:invalid-offset].

@examples[#:eval the-eval
(moment 2015 3 8 2 30 #:tz "America/New_York" (code:comment "in gap")
        #:resolve-offset resolve-offset/raise)

(moment 2015 11 1 1 30 #:tz "America/New_York" (code:comment "in overlap")
        #:resolve-offset resolve-offset/raise)
]}

@defproc[(resolve-offset/pre [gap-or-overlap (or/c tzgap? tzoverlap?)]
                             [local datetime?]
                             [tzid string?]
                             [orig (or/c moment? #f)])
         moment?]{
An @tech{offset resolver} that combines @racket[resolve-gap/pre] and @racket[resolve-overlap/pre].

@examples[#:eval the-eval
(moment 2015 3 8 2 30 #:tz "America/New_York" (code:comment "in gap")
        #:resolve-offset resolve-offset/pre)

(moment 2015 11 1 1 30 #:tz "America/New_York" (code:comment "in overlap")
        #:resolve-offset resolve-offset/pre)
]}

@defproc[(resolve-offset/post [gap-or-overlap (or/c tzgap? tzoverlap?)]
                              [local datetime?]
                              [tzid string?]
                              [orig (or/c moment? #f)])
         moment?]{
An @tech{offset resolver} that combines @racket[resolve-gap/post] and @racket[resolve-overlap/post].

@examples[#:eval the-eval
(moment 2015 3 8 2 30 #:tz "America/New_York" (code:comment "in gap")
        #:resolve-offset resolve-offset/post)

(moment 2015 11 1 1 30 #:tz "America/New_York" (code:comment "in overlap")
        #:resolve-offset resolve-offset/post)
]}

@defproc[(resolve-offset/post-gap/pre-overlap [gap-or-overlap (or/c tzgap? tzoverlap?)]
                                              [local datetime?]
                                              [tzid string?]
                                              [orig (or/c moment? #f)])
         moment?]{
An @tech{offset resolver} that combines @racket[resolve-gap/post] and @racket[resolve-overlap/pre].

@examples[#:eval the-eval
(moment 2015 3 8 2 30 #:tz "America/New_York" (code:comment "in gap")
        #:resolve-offset resolve-offset/post-gap/pre-overlap)

(moment 2015 11 1 1 30 #:tz "America/New_York" (code:comment "in overlap")
        #:resolve-offset resolve-offset/post-gap/pre-overlap)
]}


@defproc[(resolve-offset/retain [gap-or-overlap (or/c tzgap? tzoverlap?)]
                                [local datetime?]
                                [tzid string?]
                                [orig (or/c moment? #f)])
         moment?]{
An @tech{offset resolver} that combines @racket[resolve-gap/post] and @racket[resolve-overlap/retain].

This resolver is used by default in date arithmetic functions.

@examples[#:eval the-eval
(+years
 (moment 2014 11 1 1 30 #:tz "America/New_York") (code:comment "UTC-04:00")
 1
 #:resolve-offset resolve-offset/retain)

(+years
 (moment 2014 11 1 1 30 #:tz "America/New_York") (code:comment "UTC-04:00")
 1
 #:resolve-offset resolve-offset/post)
]}

@defproc[(resolve-offset/push [gap-or-overlap (or/c tzgap? tzoverlap?)]
                              [local datetime?]
                              [tzid string?]
                              [orig (or/c moment? #f)])
         moment?]{
An @tech{offset resolver} that combines @racket[resolve-gap/push] and @racket[resolve-overlap/post].

@examples[#:eval the-eval
(moment 2015 3 8 2 30 #:tz "America/New_York" (code:comment "in gap")
        #:resolve-offset resolve-offset/push)

(moment 2015 11 1 1 30 #:tz "America/New_York" (code:comment "in overlap")
        #:resolve-offset resolve-offset/push)
]}

@subsection{Gap Resolvers}

@defthing[gap-resolver/c chaperone-contract?]{
A contract for @tech{gap resolver} functions. The contract is specified as:
@racketblock[
(-> tzgap?
    datetime?
    string?
    (or/c moment? #f)      
    moment?)
]}

@defproc[(resolve-gap/pre [gap tzgap?]
                          [local datetime?]
                          [tzid string?]
                          [orig (or/c moment? #f)])
         moment?]{
Returns the @racket[moment] just prior to the given @racket[gap].
}

@defproc[(resolve-gap/post [gap tzgap?]
                           [local datetime?]
                           [tzid string?]
                           [orig (or/c moment? #f)])
         moment?]{
Returns the @racket[moment] at the end of the given @racket[gap].
}

@defproc[(resolve-gap/push [gap tzgap?]
                           [local datetime?]
                           [tzid string?]
                           [orig (or/c moment? #f)])
         moment?]{
Returns a @racket[moment] where the @racket[local] @racket[datetime] portion is pushed
forward by the length of the gap.
}

@subsection{Overlap Resolvers}

@defthing[overlap-resolver/c chaperone-contract?]{
A contract for @tech{overlap resolver} functions. The contract is specified as:
@racketblock[
(-> tzoverlap?
    datetime?
    string?
    (or/c moment? #f)      
    moment?)
]}

@defproc[(resolve-overlap/pre [overlap tzoverlap?]
                              [local datetime?]
                              [tzid string?]
                              [orig (or/c moment? #f)])
         moment?]{
Returns a @racket[moment] for the given @racket[local] @racket[datetime], using the
UTC offset in effect before the overlap.
}

@defproc[(resolve-overlap/post [overlap tzoverlap?]
                               [local datetime?]
                               [tzid string?]
                               [orig (or/c moment? #f)])
         moment?]{
Returns a @racket[moment] for the given @racket[local] @racket[datetime], using the
UTC offset in effect after the overlap.
}

@defproc[(resolve-overlap/retain [overlap tzoverlap?]
                                 [local datetime?]
                                 [tzid string?]
                                 [orig (or/c moment? #f)])
         moment?]{
If @racket[orig] is a @racket[moment] and its UTC offset is one of the ones involved
in the given @racket[overlap], then the result will use that offset. Otherwise, this
function behaves the same as @racket[resolve-overlap/post].
}
