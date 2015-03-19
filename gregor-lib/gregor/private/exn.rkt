#lang racket/base

(require "datetime.rkt"
         tzinfo)

(provide (all-defined-out))

(struct exn:gregor exn:fail ())
(struct exn:gregor:invalid-offset exn:gregor ())
(struct exn:gregor:invalid-pattern exn:gregor ())
(struct exn:gregor:parse exn:gregor ())

(define (raise-invalid-offset g/o target-dt target-tzid orig)
  (raise
   (exn:gregor:invalid-offset
    (format "Illegal moment: local time ~a ~a in time zone ~a"
            (datetime->iso8601 target-dt)
            (if (tzgap? g/o)
                "does not exist"
                "is ambiguous")
            target-tzid)
    (current-continuation-marks))))

(define (raise-parse-error pat str)
  (raise
   (exn:gregor:parse
    (format "Unable to match pattern [~a] against input ~s"
            pat
            str)
    (current-continuation-marks))))

(define (raise-pattern-error pat)
  (raise
   (exn:gregor:invalid-pattern
    (format (string-append "The character [~a] is reserved in pattern syntax. "
                           "Literal ASCII letters must be enclosed in single quotes. "
                           "E.g., '~a'.")
            pat pat)
    (current-continuation-marks))))
