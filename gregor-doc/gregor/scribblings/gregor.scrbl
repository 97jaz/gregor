#lang scribble/manual

@title{Gregor: Dates and Times}
@author[@author+email["Jon Zeppieri" "zeppieri@gmail.com"]]

@section-index["calendar"]

@defmodule[gregor]

Gregor is a date and time library for Racket. It provides:

@itemize[
@item{data structures for representing dates, times, and their combination,
both with and without time zones;}

@item{generic functions for accessing these data structures;}

@item{date and time arithmetic, based on a proleptic Gregorian calendar and
the @link["http://www.iana.org/time-zones"]{tz} database; and}

@item{localized formatting and parsing, based on @link["http://cldr.unicode.org/"]{CLDR}.}
]

@include-section["date.scrbl"]
@include-section["time.scrbl"]
@include-section["datetime.scrbl"]
@include-section["moment.scrbl"]
@include-section["date-provider.scrbl"]
@include-section["time-provider.scrbl"]
@include-section["datetime-provider.scrbl"]
@include-section["moment-provider.scrbl"]
@include-section["clock.scrbl"]
@include-section["format.scrbl"]
@include-section["timezone.scrbl"]
@include-section["exceptions.scrbl"]
