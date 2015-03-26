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
Formats @racket[t] using the given @racket[pattern]. The
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

@subsection[#:tag "iso-parsing"]{Parsing ISO 8601 representations}

@defproc[(iso8601->date [str string?]) date?]{
Parses an ISO 8601 representation of a date into a @racket[date]. Note that the input must
use the ISO 8601 @emph{extended format}.

@examples[#:eval the-eval
(iso8601->date "1981-04-05")
(iso8601->date "1981-04")
]}

@defproc[(iso8601->time [str string?]) date?]{
Parses an ISO 8601 representation of a time into a @racket[time]. Note that the input must
use the ISO 8601 @emph{extended format}.

@examples[#:eval the-eval
(iso8601->time "13:47:30")
]}

@defproc[(iso8601->datetime [str string?]) date?]{
Parses an ISO 8601 combined date and time representation into a @racket[datetime]. Note that
the input must use the ISO 8601 @emph{extended format}.

@examples[#:eval the-eval
(iso8601->datetime "2014-03-20T19:20:09.3045")
]}

@defproc[(iso8601->moment [str string?]) date?]{
Parses an ISO 8601 combined date and time representation into a @racket[moment]. Note that
the input must use the ISO 8601 @emph{extended format}.

@examples[#:eval the-eval
(iso8601->moment "2014-03-20T19:20:09.3045Z")
]}

@defproc[(iso8601/tzid->moment [str string?]) date?]{
Parses a non-standard format, consisting of an ISO 8601 combined date and time representation
and an IANA time zone ID in brackets, into a @racket[moment]. The input format is the same
as that produced by @racket[moment->iso8601/tzid]. Note that the ISO 8601 portion of
the input must use the ISO 8601 @emph{extended format}.

@examples[#:eval the-eval
(iso8601/tzid->moment "2014-03-20T19:20:09.3045-04:00[America/New_York]")
]}


@subsection[#:tag "pattern-parsing"]{Flexible parsing based on patterns}

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
