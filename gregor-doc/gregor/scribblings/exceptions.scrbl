#lang scribble/manual

@(require scribble/eval
          gregor
          (for-label (except-in racket/base date date? time)
                     tzinfo
                     gregor))

@(define the-eval (make-base-eval))
@(the-eval '(require gregor
                     gregor/time))

@title[#:tag "exn"]{Exceptions}

@declare-exporting[gregor]

@defstruct*[(exn:gregor exn:fail) ()]{
The super-type of all Gregor exceptions.
}

@defstruct*[(exn:gregor:invalid-offset exn:gregor) ()]{
Raised by @racket[resolve-offset/raise] when trying to construct a @racket[moment]
that falls into a gap or overlap in a local time-line. See @secref["offset-resolvers"]
for details.
}

@defstruct*[(exn:gregor:invalid-pattern exn:gregor) ()]{
Raised by @seclink["time-format"]{formatting and parsing functions} when they are given an invalid
pattern.
}

@defstruct*[(exn:gregor:parse exn:gregor) ()]{
Raised by @seclink["parsing"]{parsing functions} when they are unable to
parse the input with the given pattern.
}
