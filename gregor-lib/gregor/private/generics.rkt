#lang racket/base

(require racket/generic
         racket/match
         racket/math
         "core/structs.rkt"
         "core/math.rkt"
         "core/ymd.rkt"
         "core/hmsn.rkt"
         "difference.rkt"
         "date.rkt"
         "time.rkt"
         "datetime.rkt"
         "moment.rkt"
         "offset-resolvers.rkt")

(provide (all-defined-out))

(define-generics date-provider
  (->date       date-provider)
  (->ymd        date-provider)
  (->jdn        date-provider)
  (->year       date-provider)
  (->quarter    date-provider)
  (->month      date-provider)
  (->day        date-provider)
  (->wday       date-provider)
  (->yday       date-provider)
  (->iso-week   date-provider)
  (->iso-wyear  date-provider)
  (->iso-wday   date-provider)

  (+years       date-provider n #:resolve-offset [resolve-offset])
  (+months      date-provider n #:resolve-offset [resolve-offset])
  (+weeks       date-provider n #:resolve-offset [resolve-offset])
  (+days        date-provider n #:resolve-offset [resolve-offset])

  (-years       date-provider n #:resolve-offset [resolve-offset])
  (-months      date-provider n #:resolve-offset [resolve-offset])
  (-weeks       date-provider n #:resolve-offset [resolve-offset])
  (-days        date-provider n #:resolve-offset [resolve-offset])

  (sunday?      date-provider)
  (monday?      date-provider)
  (tuesday?     date-provider)
  (wednesday?   date-provider)
  (thursday?    date-provider)
  (friday?      date-provider)
  (saturday?    date-provider)

  (with-ymd     date-provider ymd #:resolve-offset [resolve-offset])
  (with-jdn     date-provider jdn #:resolve-offset [resolve-offset])

  (at-time      date-provider t #:resolve-offset [resolve-offset])
  (at-midnight  date-provider #:resolve-offset [resolve-offset])
  (at-noon      date-provider #:resolve-offset [resolve-offset])

  #:defaults
  ([date?
    (define ->date      (λ (x) x))
    (define with-ymd    (λ (d ymd #:resolve-offset [_ resolve-offset/raise])
                          (ymd->date ymd)))
    (define with-jdn    (λ (d jdn #:resolve-offset [_ resolve-offset/raise])
                          (jdn->date jdn)))
    (define at-time     (λ (d t #:resolve-offset [_ resolve-offset/raise])
                          (date+time->datetime d (->time t))))]

   [datetime?
    (define ->date      datetime->date)
    (define with-ymd    (λ (dt ymd #:resolve-offset [_ resolve-offset/raise])
                          (date+time->datetime (ymd->date ymd) (datetime->time dt))))
    (define with-jdn    (λ (dt jdn #:resolve-offset [_ resolve-offset/raise])
                          (date+time->datetime (jdn->date jdn) (datetime->time dt))))
    (define at-time     (λ (dt t #:resolve-offset [_ resolve-offset/raise])
                          (date+time->datetime (datetime->date dt) (->time t))))]

   [moment?
    (define/generic /ymd with-ymd)
    (define/generic /jdn with-jdn)
    (define/generic @time at-time)

    (define ->date      (compose1 datetime->date moment->datetime/local))
    (define with-ymd    (λ (m ymd #:resolve-offset [r resolve-offset/raise])
                          (define dt (/ymd (moment->datetime/local m) ymd))
                          (datetime+tz->moment dt (moment->timezone m) r)))
    (define with-jdn    (λ (m jdn #:resolve-offset [r resolve-offset/raise])
                          (define dt (/jdn (moment->datetime/local m) jdn))
                          (datetime+tz->moment dt (moment->timezone m) r)))
    (define at-time     (λ (m t #:resolve-offset [r resolve-offset/raise])
                          (define dt (@time (moment->datetime/local m) (->time t)))
                          (datetime+tz->moment dt (moment->timezone m) r)))])

  #:fallbacks
  [(define/generic as-date ->date)
   (define ->ymd (compose1 date->ymd as-date))
   (define ->jdn (compose1 date->jdn as-date))

   (define/generic from-ymd with-ymd)
   (define/generic from-jdn with-jdn)

   (define ->year      (compose1 YMD-y ->ymd))
   (define ->quarter   (compose1 ymd->quarter ->ymd))
   (define ->month     (compose1 YMD-m ->ymd))
   (define ->day       (compose1 YMD-d ->ymd))
   (define ->wday      (compose1 jdn->wday ->jdn))
   (define ->yday      (compose1 ymd->yday ->ymd))
   (define ->iso-week  (compose1 date->iso-week as-date))
   (define ->iso-wyear (compose1 date->iso-wyear as-date))
   (define ->iso-wday  (compose1 jdn->iso-wday ->jdn))

   (define (resolve/orig resolve orig)
     (λ (g/o dt tzid m)
       (resolve g/o dt tzid (or m (and (moment? orig) orig)))))

   (define (d+ from as fn)
     (λ (d n #:resolve-offset [resolve resolve-offset/retain])
       (from d (fn (as d) n) #:resolve-offset (resolve/orig resolve d))))

   (define (d- from as fn)
     (λ (d n #:resolve-offset [resolve resolve-offset/retain])
       (from d (fn (as d) (- n)) #:resolve-offset (resolve/orig resolve d))))

   (define (ymd+ fn)   (d+ from-ymd ->ymd fn))
   (define (ymd- fn)   (d- from-ymd ->ymd fn))
   (define (jdn+ fn)   (d+ from-jdn ->jdn fn))

   (define +years   (ymd+ ymd-add-years))
   (define +months  (ymd+ ymd-add-months))
   (define +days    (jdn+ +))
   (define +weeks   (jdn+ (λ (x y) (+ x (* y 7)))))

   (define -years   (ymd- ymd-add-years))
   (define -months  (ymd- ymd-add-months))
   (define -days    (jdn+ -))
   (define -weeks   (jdn+ (λ (x y) (- x (* y 7)))))

   (define (dow? n)    (λ (d) (= n (->wday d))))

   (define sunday?     (dow? 0))
   (define monday?     (dow? 1))
   (define tuesday?    (dow? 2))
   (define wednesday?  (dow? 3))
   (define thursday?   (dow? 4))
   (define friday?     (dow? 5))
   (define saturday?   (dow? 6))

   (define/generic @time at-time)
   (define at-midnight (λ (d #:resolve-offset [_ resolve-offset/raise])
                         (@time d MIDNIGHT #:resolve-offset _)))
   (define at-noon     (λ (d #:resolve-offset [_ resolve-offset/raise])
                         (@time d NOON #:resolve-offset _)))])

(define-generics  time-provider
  (->time         time-provider)
  (->hmsn         time-provider)
  (->hours        time-provider)
  (->minutes      time-provider)
  (->seconds      time-provider [fractional?])
  (->milliseconds time-provider)
  (->microseconds time-provider)
  (->nanoseconds  time-provider)

  (+hours         time-provider n)
  (+minutes       time-provider n)
  (+seconds       time-provider n)
  (+milliseconds  time-provider n)
  (+microseconds  time-provider n)
  (+nanoseconds   time-provider n)

  (-hours         time-provider n)
  (-minutes       time-provider n)
  (-seconds       time-provider n)
  (-milliseconds  time-provider n)
  (-microseconds  time-provider n)
  (-nanoseconds   time-provider n)

  (on-date        time-provider d #:resolve-offset [resolve-offset])

  #:defaults
  ([time?
    (define ->time          (λ (x) x))

    (define (+nanoseconds t n)
      (day-ns->time
       (mod (+ (time->ns t) n)
            NS/DAY)))

    (define (on-date t d #:resolve-offset [_ resolve-offset/raise])
      (date+time->datetime (->date d) t))]

   [datetime?
    (define ->time          datetime->time)
    (define +nanoseconds    datetime-add-nanoseconds)
    (define on-date         (λ (dt d #:resolve-offset [_ resolve-offset/raise])
                              (date+time->datetime (->date d) (->time dt))))]

   [moment?
    (define/generic on-date/g on-date)

    (define ->time          (compose1 datetime->time moment->datetime/local))
    (define +nanoseconds    moment-add-nanoseconds)
    (define on-date         (λ (m d #:resolve-offset [r resolve-offset/raise])
                              (define dt (on-date/g (moment->datetime/local m) d))
                              (datetime+tz->moment dt (moment->timezone m) r)))])

  #:fallbacks
  [(define/generic as-time ->time)

   (define ->hmsn          (compose1 time->hmsn as-time))

   (define ->hours         (compose1 HMSN-h ->hmsn))
   (define ->minutes       (compose1 HMSN-m ->hmsn))

   (define ->seconds       (λ (t [fractional? #f])
                             (match-define (HMSN _ _ s n) (->hmsn t))

                             (+ s (if fractional?
                                      (/ n NS/SECOND)
                                      0))))

   (define ->nanoseconds   (compose1 HMSN-n ->hmsn))
   (define ->milliseconds  (λ (t) (exact-floor (/ (->nanoseconds t) 1000000))))
   (define ->microseconds  (λ (t) (exact-floor (/ (->nanoseconds t) 1000))))

   (define/generic ns+ +nanoseconds)

   (define (-nanoseconds t n) (ns+ t (- n)))

   (define (t+/- NS/UNIT i)
     (λ (t n)
       (ns+ t (* n NS/UNIT i))))

   (define (t+ NS/UNIT) (t+/- NS/UNIT 1))
   (define (t- NS/UNIT) (t+/- NS/UNIT -1))

   (define +hours          (t+ NS/HOUR))
   (define +minutes        (t+ NS/MINUTE))
   (define +seconds        (t+ NS/SECOND))
   (define +milliseconds   (t+ NS/MILLI))
   (define +microseconds   (t+ NS/MICRO))

   (define -hours          (t- NS/HOUR))
   (define -minutes        (t- NS/MINUTE))
   (define -seconds        (t- NS/SECOND))
   (define -milliseconds   (t- NS/MILLI))
   (define -microseconds   (t- NS/MICRO))])


(define-generics datetime-provider
  (->datetime/local      datetime-provider)
  (->datetime/utc        datetime-provider)
  (->datetime/similar    datetime-provider other)
  (->posix               datetime-provider)
  (->jd                  datetime-provider)

  (years-between         datetime-provider other)
  (months-between        datetime-provider other)
  (weeks-between         datetime-provider other)
  (days-between          datetime-provider other)
  (hours-between         datetime-provider other)
  (minutes-between       datetime-provider other)
  (seconds-between       datetime-provider other)
  (milliseconds-between  datetime-provider other)
  (microseconds-between  datetime-provider other)
  (nanoseconds-between   datetime-provider other)

  (with-timezone         datetime-provider tz #:resolve-offset [resolve-offset])

  #:defaults
  ([date?
    (define ->datetime/local at-midnight)
    (define ->datetime/utc   at-midnight)]

   [datetime?
    (define ->datetime/local  (λ (x) x))
    (define ->datetime/utc    ->datetime/local)]

   [moment?
    (define/generic ->dt/l ->datetime/local)

    (define ->datetime/local  moment->datetime/local)
    (define ->datetime/utc    (compose1 moment->datetime/local moment-in-utc))

    (define (->datetime/similar self other)
      (->dt/l
       (cond [(moment-provider? other)
              (timezone-adjust other (->timezone self))]
             [else
              other])))])

  #:fallbacks
  [(define/generic ->dt ->datetime/utc)
   (define/generic ->dt/l ->datetime/local)
   (define/generic ->dt/s ->datetime/similar)

   (define (->datetime/similar _ dt) (->dt/l dt))
   (define (->jd dt)    (datetime->jd (->dt dt)))
   (define (->posix dt) (/ (nanoseconds-between (moment 1970 #:tz UTC) dt) NS/SECOND))

   (define (lift/date fn) (λ (d1 d2) (fn (->dt/l d1) (->dt/s d1 d2))))
   (define (lift/time fn) (λ (d1 d2) (fn (->dt d1) (->dt d2))))
   (define (quot fn n)    (λ (d1 d2) (quotient (fn d1 d2) n)))

   (define months-between          (lift/date datetime-months-between))
   (define years-between           (quot months-between 12))
   (define days-between            (lift/date datetime-days-between))
   (define weeks-between           (quot days-between 7))
   (define nanoseconds-between     (lift/time datetime-nanoseconds-between))
   (define hours-between           (quot nanoseconds-between NS/HOUR))
   (define minutes-between         (quot nanoseconds-between NS/MINUTE))
   (define seconds-between         (quot nanoseconds-between NS/SECOND))
   (define milliseconds-between    (quot nanoseconds-between NS/MILLI))
   (define microseconds-between    (quot nanoseconds-between NS/MICRO))

   (define (with-timezone t tz #:resolve-offset [r resolve-offset/raise])
     (datetime+tz->moment (->dt/l t) tz r))])


(define-generics   moment-provider
  (->moment        moment-provider)
  (->utc-offset    moment-provider)
  (->timezone      moment-provider)
  (->tzid          moment-provider)
  (adjust-timezone moment-provider tz)

  #:defaults
  ([moment?
    (define ->moment        (λ (x) x))
    (define ->utc-offset    moment->utc-offset)
    (define ->timezone      moment->timezone)
    (define ->tzid          moment->tzid)
    (define adjust-timezone timezone-adjust)]))

(define (tzid-provider? x)
  (and (moment-provider? x)
       (->tzid x)))
