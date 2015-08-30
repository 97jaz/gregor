#lang scribble/manual

@(require scribble/eval
          (for-label (except-in racket/base date date? time)
                     gregor
                     gregor/time))

@(define the-eval (make-base-eval))
@(the-eval '(require gregor))

@title[#:tag "query"]{Calendar Query Functions}

@declare-exporting[gregor]

@defproc[(leap-year? [y exact-integer?]) boolean?]{
 Returns @racket[#t] if @racket[y] is a leap year,
 @racket[#f] otherwise.

 @examples[#:eval the-eval
   (leap-year? 1900)
   (leap-year? 2000)
   (leap-year? 2004)
 ]
}

@defproc[(days-in-year [y exact-integer?]) (or/c 365 366)]{
 Returns the number of days in year @racket[y].

 Equivalent to: @racket[(if (leap-year? y) 366 365)]

  @examples[#:eval the-eval
   (days-in-year 1900)
   (days-in-year 2000)
   (days-in-year 2004)
 ]
}

@defproc[(days-in-month [y exact-integer?]
                        [m (integer-in 1 12)])
         (integer-in 28 31)]{
 Returns the number of days in month @racket[m] in year
 @racket[y].

 @examples[#:eval the-eval
   (days-in-month 2015 8)
   (days-in-month 2015 2)
   (days-in-month 2016 2)
 ]
}

@defproc[(iso-weeks-in-year [y exact-integer?]) (or/c 52 53)]{
 Returns the number of weeks in year @racket[y], according
 to the
 @link["http://en.wikipedia.org/wiki/ISO_week_date"]{ISO
  8601 week-numbering year}.

 @examples[#:eval the-eval
   (iso-weeks-in-year 2005)
   (iso-weeks-in-year 2015)
 ]
}