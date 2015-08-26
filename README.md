# Gregor: a date and time library for Racket

Jon Zeppieri <[zeppieri@gmail.com](mailto:zeppieri@gmail.com)>

To install:
```sh
raco pkg install gregor
```

To use:
```racket
(require gregor)
```

Gregor is a date and time library for Racket. It provides:
- data structures for representing dates, times, and their combination, both with and without time zones;
- generic functions for accessing these data structures;
- date and time arithmetic, based on a proleptic Gregorian calendar and the tz database; and
- localized formatting and parsing, based on CLDR.

[Read the documentation](http://pkg-build.racket-lang.org/doc/gregor/index.html)
