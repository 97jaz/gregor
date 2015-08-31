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

@section[#:tag "time-scale"]{Time Scale}

Gregor assumes that all days have exactly 86,400 seconds. Therefore, it is based fundamentally
on mean solar time, or @link["http://en.wikipedia.org/wiki/Universal_Time"]{Univeral Time},
and @emph{not} on
@link["http://en.wikipedia.org/wiki/Coordinated_Universal_Time"]{Coordinated Universal Time} (UTC),
the civil time scale adopted by most of the world. In the interest of reconciling the SI second
to a close approximation of mean solar time, UTC occasionally inserts an extra @deftech{leap second}
into a day. @margin-note{UTC can also remove seconds but has never done so. The rotation of the Earth is
slowing and solar days are getting longer, so there has only ever been a need to add seconds.}
Since leap seconds are added on an irregular basis, they complicate both the representation of times
and arithemtic performed on them. In practice, most computer systems are not faithful to UTC. The POSIX
clock, for example, ignores leap seconds. The standard (and non-standard) date and time libraries of
most programming languagues also ignore them. In truth, although UTC is the @emph{de jure}
international standard, it's rare to find a system that actually implements it and just as rare to find
a user who misses it.

That said, if there is a demand for proper UTC support, I will consider adding it.
Ideally, Gregor would be able to support many different time scales. API suggestions are welcome.


@include-section["date.scrbl"]
@include-section["time.scrbl"]
@include-section["datetime.scrbl"]
@include-section["moment.scrbl"]
@include-section["period.scrbl"]
@include-section["date-provider.scrbl"]
@include-section["time-provider.scrbl"]
@include-section["datetime-provider.scrbl"]
@include-section["moment-provider.scrbl"]
@include-section["date-arithmetic-provider.scrbl"]
@include-section["time-arithmetic-provider.scrbl"]
@include-section["datetime-arithmetic-provider.scrbl"]
@include-section["clock.scrbl"]
@include-section["format.scrbl"]
@include-section["timezone.scrbl"]
@include-section["query.scrbl"]
@include-section["exceptions.scrbl"]
