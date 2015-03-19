#lang info

(define collection 'multi)

(define deps '("base"))

(define build-deps '("base"
                     "racket-doc"
                     "data-doc"
                     "data-lib"
                     "gregor-lib"
                     "scribble-lib"
                     "sandbox-lib"
                     "tzinfo"))

(define update-implies '("gregor-lib"))

(define pkg-desc "documentation for \"gregor\"")

(define pkg-authors '(97jaz))
