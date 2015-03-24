#lang info


(define collection 'multi)
(define deps '("base"
               "memoize"
               "tzinfo"
               "cldr-core"
               "cldr-bcp47"
               "cldr-numbers-modern"
               "cldr-dates-modern"
               "cldr-localenames-modern"))
(define build-deps '("racket-doc" "scribble-lib"))

(define pkg-desc "implementation (no documentation) of \"gregor\"")

(define pkg-authors '(97jaz))
