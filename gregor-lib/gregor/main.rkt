#lang racket/base

(require racket/contract/base
         data/order
         tzinfo

         "private/clock.rkt"
         "private/date.rkt"
         "private/datetime.rkt"
         "private/exn.rkt"
         "private/format.rkt"
         "private/generics.rkt"
         "private/moment.rkt"
         "private/offset-resolvers.rkt"
         "private/parse.rkt"
         "private/iso8601-parse.rkt"
         "private/time.rkt"
         "private/period.rkt"

         "private/core/ymd.rkt"
         "private/core/hmsn.rkt"

         "private/pattern/ast/year.rkt")

(define date-arith/c
  (->i ([d date-arithmetic-provider?]
        [n exact-integer?])
       (#:resolve-offset [resolve offset-resolver/c])
       [r date-arithmetic-provider?]))

(define date-period-arith/c
  (->i ([d date-arithmetic-provider?]
        [p date-period?])
       (#:resolve-offset [resolve offset-resolver/c])
       [r date-arithmetic-provider?]))

(define time-arith/c
  (-> time-arithmetic-provider? exact-integer? time-arithmetic-provider?))

(define time-period-arith/c
  (-> time-arithmetic-provider? time-period? time-arithmetic-provider?))

(define datetime-period-arith/c
  (->i ([d datetime-arithmetic-provider?]
        [p period?])
       (#:resolve-offset [resolve offset-resolver/c])
       [r datetime-arithmetic-provider?]))

;; exceptions
(provide (struct-out exn:gregor)
         (struct-out exn:gregor:invalid-offset)
         (struct-out exn:gregor:invalid-pattern)
         (struct-out exn:gregor:parse))

(provide/contract

 ;; date
 [date            (->i ([year exact-integer?])
                       ([month (integer-in 1 12)]
                        [day (year month) (day-of-month/c year month)])
                       [d date?])]
 [jdn->date       (-> exact-integer? date?)]
 [date?           (-> any/c boolean?)]
 [date->iso8601   (-> date? string?)]

 [date=?          (-> date? date? boolean?)]
 [date<?          (-> date? date? boolean?)]
 [date<=?         (-> date? date? boolean?)]
 [date>?          (-> date? date? boolean?)]
 [date>=?         (-> date? date? boolean?)]
 [date-order      order?]

 ;; datetime
 [datetime           (->i ([year exact-integer?])
                          ([month (integer-in 1 12)]
                           [day (year month) (day-of-month/c year month)]
                           [hour (integer-in 0 23)]
                           [minute (integer-in 0 59)]
                           [second (integer-in 0 59)]
                           [nanosecond (integer-in 0 (sub1 NS/SECOND))])
                          [dt datetime?])]
 [jd->datetime       (-> real? datetime?)]
 [posix->datetime    (-> real? datetime?)]
 [datetime?          (-> any/c boolean?)]
 [datetime->iso8601  (-> datetime? string?)]
 [datetime=?         (-> datetime? datetime? boolean?)]
 [datetime<?         (-> datetime? datetime? boolean?)]
 [datetime<=?        (-> datetime? datetime? boolean?)]
 [datetime>?         (-> datetime? datetime? boolean?)]
 [datetime>=?        (-> datetime? datetime? boolean?)]
 [datetime-order     order?]

 ;; moment
 [moment               (->i ([year exact-integer?])
                            ([month (integer-in 1 12)]
                             [day (year month) (day-of-month/c year month)]
                             [hour (integer-in 0 23)]
                             [minute (integer-in 0 59)]
                             [second (integer-in 0 59)]
                             [nanosecond (integer-in 0 (sub1 NS/SECOND))]
                             #:tz [tz tz/c]
                             #:resolve-offset [resolve offset-resolver/c])
                            [res moment?])]
 [moment?              (-> any/c boolean?)]
 [moment->iso8601      (-> moment? string?)]
 [moment->iso8601/tzid (-> moment? string?)]
 [moment=?             (-> moment? moment? boolean?)]
 [moment<?             (-> moment? moment? boolean?)]
 [moment<=?            (-> moment? moment? boolean?)]
 [moment>?             (-> moment? moment? boolean?)]
 [moment>=?            (-> moment? moment? boolean?)]
 [moment-order         order?]
 [UTC                  tz/c]

  ;; date generics
 [date-provider?     (-> any/c boolean?)]

 [->date             (-> date-provider? date?)]
 [->jdn              (-> date-provider? exact-integer?)]
 [->year             (-> date-provider? exact-integer?)]
 [->quarter          (-> date-provider? (integer-in 1 4))]
 [->month            (-> date-provider? (integer-in 1 12))]
 [->day              (-> date-provider? (integer-in 1 31))]
 [->wday             (-> date-provider? (integer-in 0 6))]
 [->yday             (-> date-provider? (integer-in 1 366))]
 [->iso-week         (-> date-provider? (integer-in 1 53))]
 [->iso-wyear        (-> date-provider? exact-integer?)]
 [->iso-wday         (-> date-provider? (integer-in 1 7))]

 [sunday?            (-> date-provider? boolean?)]
 [monday?            (-> date-provider? boolean?)]
 [tuesday?           (-> date-provider? boolean?)]
 [wednesday?         (-> date-provider? boolean?)]
 [thursday?          (-> date-provider? boolean?)]
 [friday?            (-> date-provider? boolean?)]
 [saturday?          (-> date-provider? boolean?)]

 [at-time            (->i ([d date-provider?]
                           [t time-provider?])
                          (#:resolve-offset [resolve offset-resolver/c])
                          [result datetime-provider?])]
 [at-midnight        (->i ([d date-provider?])
                          (#:resolve-offset [resolve offset-resolver/c])
                          [result datetime-provider?])]
 [at-noon            (->i ([d date-provider?])
                          (#:resolve-offset [resolve offset-resolver/c])
                          [result datetime-provider?])]

 [date-arithmetic-provider? (-> any/c boolean?)]

 [+years             date-arith/c]
 [+months            date-arith/c]
 [+weeks             date-arith/c]
 [+days              date-arith/c]
 [-years             date-arith/c]
 [-months            date-arith/c]
 [-weeks             date-arith/c]
 [-days              date-arith/c]

 [+date-period       date-period-arith/c]
 [-date-period       date-period-arith/c]

 ;; time generics
 [time-provider?     (-> any/c boolean?)]

 [->time             (-> time-provider? time?)]
 [->hours            (-> time-provider? (integer-in 0 23))]
 [->minutes          (-> time-provider? (integer-in 0 59))]
 [->seconds          (->* (time-provider?) (boolean?) (and/c rational? (>=/c 0) (</c 60)))]
 [->milliseconds     (-> time-provider? (integer-in 0 999))]
 [->microseconds     (-> time-provider? (integer-in 0 999999))]
 [->nanoseconds      (-> time-provider? (integer-in 0 999999999))]

 [on-date            (->i ([t time-provider?]
                           [d date-provider?])
                          (#:resolve-offset [resolve offset-resolver/c])
                          [result datetime-provider?])]

 [time-arithmetic-provider? (-> any/c boolean?)]

 [+hours             time-arith/c]
 [+minutes           time-arith/c]
 [+seconds           time-arith/c]
 [+milliseconds      time-arith/c]
 [+microseconds      time-arith/c]
 [+nanoseconds       time-arith/c]

 [-hours             time-arith/c]
 [-minutes           time-arith/c]
 [-seconds           time-arith/c]
 [-milliseconds      time-arith/c]
 [-microseconds      time-arith/c]
 [-nanoseconds       time-arith/c]

 [+time-period       time-period-arith/c]
 [-time-period       time-period-arith/c]

 ;; datetime generics
 [datetime-provider? (-> any/c boolean?)]

 [->datetime/local   (-> datetime-provider? datetime?)]
 [->datetime/utc     (-> datetime-provider? datetime?)]
 [->posix            (-> datetime-provider? rational?)]
 [->jd               (-> datetime-provider? rational?)]

 [years-between        (-> datetime-provider? datetime-provider? exact-integer?)]
 [months-between       (-> datetime-provider? datetime-provider? exact-integer?)]
 [weeks-between        (-> datetime-provider? datetime-provider? exact-integer?)]
 [days-between         (-> datetime-provider? datetime-provider? exact-integer?)]
 [hours-between        (-> datetime-provider? datetime-provider? exact-integer?)]
 [minutes-between      (-> datetime-provider? datetime-provider? exact-integer?)]
 [seconds-between      (-> datetime-provider? datetime-provider? exact-integer?)]
 [milliseconds-between (-> datetime-provider? datetime-provider? exact-integer?)]
 [microseconds-between (-> datetime-provider? datetime-provider? exact-integer?)]
 [nanoseconds-between  (-> datetime-provider? datetime-provider? exact-integer?)]

 [with-timezone        (->i ([t datetime-provider?]
                             [tz tz/c])
                            (#:resolve-offset [resolve-offset offset-resolver/c])
                            [m moment-provider?])]

 [datetime-arithmetic-provider? (-> any/c boolean?)]

 [+period            datetime-period-arith/c]
 [-period            datetime-period-arith/c]

 ;; moment generics
 [tz/c               any/c]
 [current-timezone   (parameter/c tz/c)]

 [moment-provider?   (-> any/c boolean?)]

 [->moment           (-> moment-provider? moment?)]
 [->utc-offset       (-> moment-provider? (integer-in -64800 64800))]
 [->timezone         (-> moment-provider? tz/c)]
 [->tzid             (-> moment-provider? (or/c string? false/c))]
 [adjust-timezone    (-> moment-provider? tz/c moment-provider?)]

 ;; format
 [~t                 (->i ([t (or/c date-provider? time-provider?)]
                           [pattern string?])
                          (#:locale [locale string?])
                          [result string?])]

 ;; parse
 [iso8601->date          (-> string? date?)]
 [iso8601->time          (-> string? time?)]
 [iso8601->datetime      (-> string? datetime?)]
 [iso8601->moment        (-> string? moment?)]
 [iso8601/tzid->moment   (-> string? moment?)]

 [current-two-digit-year-resolver (parameter/c (-> (integer-in -99 99) exact-integer?))]

 [parse-date         (->i ([input string?]
                           [pattern string?])
                          (#:ci? [ci? boolean?]
                                 #:locale [locale string?])
                          [d date?])]
 [parse-time         (->i ([input string?]
                           [pattern string?])
                          (#:ci? [ci? boolean?]
                                 #:locale [locale string?])
                          [t time?])]
 [parse-datetime     (->i ([input string?]
                           [pattern string?])
                          (#:ci? [ci? boolean?]
                                 #:locale [locale string?])
                          [dt datetime?])]
 [parse-moment       (->i ([input string?]
                           [pattern string?])
                          (#:ci? [ci? boolean?]
                                 #:locale [locale string?]
                                 #:resolve-offset [resolve offset-resolver/c])
                          [m moment?])]

 ;; offset resolvers
 [gap-resolver/c     any/c]
 [overlap-resolver/c any/c]
 [offset-resolver/c  any/c]

 [resolve-gap/pre                     gap-resolver/c]
 [resolve-gap/post                    gap-resolver/c]
 [resolve-gap/push                    gap-resolver/c]

 [resolve-overlap/pre                 overlap-resolver/c]
 [resolve-overlap/post                overlap-resolver/c]
 [resolve-overlap/retain              overlap-resolver/c]

 [resolve-offset/pre                  offset-resolver/c]
 [resolve-offset/post                 offset-resolver/c]
 [resolve-offset/post-gap/pre-overlap offset-resolver/c]
 [resolve-offset/retain               offset-resolver/c]
 [resolve-offset/push                 offset-resolver/c]
 [resolve-offset/raise                offset-resolver/c]
 [offset-resolver                     (-> gap-resolver/c overlap-resolver/c offset-resolver/c)]

 ;; clock
 [current-clock         (parameter/c (-> rational?))]
 [current-posix-seconds (-> rational?)]
 [now/moment            (->i () (#:tz [tz tz/c]) [res moment?])]
 [now                   (->i () (#:tz [tz tz/c]) [res datetime?])]
 [today                 (->i () (#:tz [tz tz/c]) [res date?])]
 [current-time          (->i () (#:tz [tz tz/c]) [res time?])]
 [now/moment/utc        (-> moment?)]
 [now/utc               (-> datetime?)]
 [today/utc             (-> date?)]
 [current-time/utc      (-> time?)]

 ;; queries
 [leap-year?        (-> exact-integer? boolean?)]
 [days-in-year      (-> exact-integer? (or/c 365 366))]
 [days-in-month     (-> exact-integer? (integer-in 1 12) (integer-in 28 31))]
 [iso-weeks-in-year (-> exact-integer? (or/c 52 53))])

(provide gen:date-provider
         gen:time-provider
         gen:datetime-provider
         gen:moment-provider)
