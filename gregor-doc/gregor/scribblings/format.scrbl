#lang scribble/manual

@(require scribble/eval
          gregor
          (for-label (except-in racket/base date date? time)
                     gregor))

@(define the-eval (make-base-eval))
@(the-eval '(require gregor
                     gregor/time))

@title[#:tag "time-format"]{Formatting and Parsing}

@declare-exporting[gregor]

@section{Formatting Dates and Times}

@defproc[(~t [t (or/c date-provider? time-provider?)]
             [pattern string?]
             [#:locale locale string? (current-locale)])
         string?]{
Formats @racket[t] using the specified @racket[pattern]. The
@link["http://unicode.org/reports/tr35/tr35-dates.html#Date_Field_Symbol_Table"]{pattern syntax}
is specified by CLDR.

@examples[#:eval the-eval
(parameterize ([current-locale "en"])
  (displayln (~t (date 1955 11 12) "E, MMMM d, y G"))
  (displayln (~t (datetime 1955 11 12 2 42 30) "E h:mm a")))

(parameterize ([current-locale "fr"])
  (displayln (~t (date 1955 11 12) "E d MMM y G"))
  (displayln (~t (datetime 1955 11 12 2 42 30) "E h:mm:ss a")))
]}

@section[#:tag "parsing"]{Parsing Dates and Times}

@defproc[(parse-date [str string?]
                     [pattern string?]
                     [#:ci? ci? boolean? #t]
                     [#:locale locale string? (current-locale)])
         date?]{
Parses @racket[str] according to @racket[pattern], which uses the CLDR
@link["http://unicode.org/reports/tr35/tr35-dates.html#Date_Field_Symbol_Table"]{pattern syntax}.
The result is returned as a @racket[date]. If the input cannot be parsed as a @racket[date],
@racket[exn:gregor:parse] is raised.

@examples[#:eval the-eval
(parameterize ([current-locale "en"])
  (list
   (parse-date "January 24, 1977" "LLLL d, y")
   (parse-date "2015-03-15T02:02:02-04:00" "yyyy-MM-dd'T'HH:mm:ssxxx")))
]}

@defproc[(parse-time [str string?]
                     [pattern string?]
                     [#:ci? ci? boolean? #t]
                     [#:locale locale string? (current-locale)])
         time?]{
Parses @racket[str] according to @racket[pattern], which uses the CLDR
@link["http://unicode.org/reports/tr35/tr35-dates.html#Date_Field_Symbol_Table"]{pattern syntax}.
The result is returned as a @racket[time]. If the input cannot be parsed as a @racket[time],
@racket[exn:gregor:parse] is raised.

@examples[#:eval the-eval
(parameterize ([current-locale "en"])
  (list
   (parse-time "January 24, 1977" "LLLL d, y")
   (parse-time "2015-03-15T02:02:02-04:00" "yyyy-MM-dd'T'HH:mm:ssxxx")))
]}

@defproc[(parse-datetime [str string?]
                         [pattern string?]
                         [#:ci? ci? boolean? #t]
                         [#:locale locale string? (current-locale)])
         datetime?]{
Parses @racket[str] according to @racket[pattern], which uses the CLDR
@link["http://unicode.org/reports/tr35/tr35-dates.html#Date_Field_Symbol_Table"]{pattern syntax}.
The result is returned as a @racket[datetime]. If the input cannot be parsed as a @racket[datetime],
@racket[exn:gregor:parse] is raised.

@examples[#:eval the-eval
(parameterize ([current-locale "en"])
  (list
   (parse-datetime "January 24, 1977" "LLLL d, y")
   (parse-datetime "2015-03-15T02:02:02-04:00" "yyyy-MM-dd'T'HH:mm:ssxxx")))
]}

@defproc[(parse-moment [str string?]
                       [pattern string?]
                       [#:ci? ci? boolean? #t]
                       [#:locale locale string? (current-locale)]
                       [#:resolve-offset resolve resolve-offset/raise])
         moment?]{
Parses @racket[str] according to @racket[pattern], which uses the CLDR
@link["http://unicode.org/reports/tr35/tr35-dates.html#Date_Field_Symbol_Table"]{pattern syntax}.
The result is returned as a @racket[moment]. If the input cannot be parsed as a @racket[moment],
@racket[exn:gregor:parse] is raised. If the result's UTC offset is ambigous, @racket[resolve]
is used to resolve the ambiguity.

@examples[#:eval the-eval
(parameterize ([current-locale "en"]
               [current-timezone "Pacific/Honolulu"])
  (list
   (parse-moment "January 24, 1977" "LLLL d, y")
   (parse-moment "2015-03-15T02:02:02-04:00" "yyyy-MM-dd'T'HH:mm:ssxxx")))
]}

@defparam[current-two-digit-year-resolver resolver (-> (integer-in 0 99) exact-integer?)]{
A parameter used to control how parsed two-digit years are resolved into complete years.
The default implementation is:
@racketblock[
(λ (parsed-year)
  (define current-year (->year (now)))
  (define lo (- current-year 50))
  (define t (if (>= lo 0)
                (remainder lo 100)
                (+ 99 (remainder (add1 lo) 100))))
  
  (+ parsed-year
     lo
     (if (< parsed-year t)
         100
         0)
     (- t)))
]

@examples[#:eval the-eval
(parameterize ([current-two-digit-year-resolver (λ (y) (+ 3300 y))])
  (parse-date "3/3/33" "M/d/yy"))
]}
