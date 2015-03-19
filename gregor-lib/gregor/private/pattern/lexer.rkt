#lang racket/base

(require racket/string
         parser-tools/lex
         (prefix-in : parser-tools/lex-sre))
         
(provide scan-pattern
         pattern->ast-list)

(require "ast.rkt"
         "ast/era.rkt"
         "ast/quarter.rkt"
         "ast/year.rkt"
         "ast/month.rkt"
         "ast/week.rkt"
         "ast/day.rkt"
         "ast/weekday.rkt"
         "ast/period.rkt"
         "ast/hour.rkt"
         "ast/minute.rkt"
         "ast/second.rkt"
         "ast/zone.rkt"
         "ast/separator.rkt"
         "ast/literal.rkt"
         "../exn.rkt")

(define (pattern->ast-list str)
  (define in (open-input-string str))
  (let loop ([res '()])
    (define t (scan-pattern in))
    (if t
        (loop (cons t res))
        (reverse res))))

(define scan-pattern
  (lexer
   [era:abbrev         (Era lexeme 'eraAbbr)]
   [era:wide           (Era lexeme 'eraNames)]
   [era:narrow         (Era lexeme 'eraNarrow)]
   
   [year               (Year lexeme 'normal (string-length lexeme))]
   [year/week          (Year lexeme 'week (string-length lexeme))]
   [year/ext           (Year lexeme 'ext (string-length lexeme))]
   [year/cyclic:abbrev (Year lexeme 'cyclic 'abbreviated)]
   [year/cyclic:wide   (Year lexeme 'cyclic 'wide)]
   [year/cyclic:narrow (Year lexeme 'cyclic 'narrow)]
   [year/related       (Year lexeme 'related (string-length lexeme))]
   
   [quarter:fmt:numeric (Quarter lexeme 'numeric (string-length lexeme))]
   [quarter:fmt:abbrev  (Quarter lexeme 'format 'abbreviated)]
   [quarter:fmt:wide    (Quarter lexeme 'format 'wide)]
   [quarter:fmt:narrow  (Quarter lexeme 'format 'narrow)]

   [quarter:sa:numeric (Quarter lexeme 'numeric (string-length lexeme))]
   [quarter:sa:abbrev  (Quarter lexeme 'stand-alone 'abbreviated)]
   [quarter:sa:wide    (Quarter lexeme 'stand-alone 'wide)]
   [quarter:sa:narrow  (Quarter lexeme 'stand-alone 'narrow)]

   [month:fmt:numeric (Month lexeme 'numeric (string-length lexeme))]
   [month:fmt:abbrev  (Month lexeme 'format 'abbreviated)]
   [month:fmt:wide    (Month lexeme 'format 'wide)]
   [month:fmt:narrow  (Month lexeme 'format 'narrow)]
   
   [month:sa:numeric (Month lexeme 'numeric (string-length lexeme))]
   [month:sa:abbrev  (Month lexeme 'stand-alone 'abbreviated)]
   [month:sa:wide    (Month lexeme 'stand-alone 'wide)]
   [month:sa:narrow  (Month lexeme 'stand-alone 'narrow)]
   
   [week/year  (Week lexeme 'year  (string-length lexeme))]
   [week/month (Week lexeme 'month (string-length lexeme))]
   
   [day/month      (Day lexeme 'month (string-length lexeme))]
   [day/year       (Day lexeme 'year (string-length lexeme))]
   [day/week/month (Day lexeme 'week/month (string-length lexeme))]
   [day/jdn        (Day lexeme 'jdn (string-length lexeme))]
   
   [weekday:fmt:abbrev (Weekday/Std lexeme 'format 'abbreviated)]
   [weekday:fmt:wide   (Weekday/Std lexeme 'format 'wide)]
   [weekday:fmt:narrow (Weekday/Std lexeme 'format 'narrow)]
   [weekday:fmt:short  (Weekday/Std lexeme 'format 'short)]
   
   [weekday/local:fmt:numeric (Weekday/Loc lexeme 'numeric (string-length lexeme))]
   [weekday/local:fmt:abbrev  (Weekday/Loc lexeme 'format 'abbreviated)]
   [weekday/local:fmt:wide    (Weekday/Loc lexeme 'format 'wide)]
   [weekday/local:fmt:narrow  (Weekday/Loc lexeme 'format 'narrow)]
   [weekday/local:fmt:short   (Weekday/Loc lexeme 'format 'short)]
  
   [weekday/local:sa:numeric (Weekday/Loc lexeme 'numeric (string-length lexeme))]
   [weekday/local:sa:abbrev  (Weekday/Loc lexeme 'stand-alone 'abbreviated)]
   [weekday/local:sa:wide    (Weekday/Loc lexeme 'stand-alone 'wide)]
   [weekday/local:sa:narrow  (Weekday/Loc lexeme 'stand-alone 'narrow)]
   [weekday/local:sa:short   (Weekday/Loc lexeme 'stand-alone 'short)]
   
   [period:abbrev (Period lexeme 'abbreviated)]
   [period:wide   (Period lexeme 'wide)]
   [period:narrow (Period lexeme 'narrow)]
   
   [hour/half      (Hour lexeme 'half (string-length lexeme))]
   [hour/full      (Hour lexeme 'full (string-length lexeme))]
   [hour/half/zero (Hour lexeme 'half/zero (string-length lexeme))]
   [hour/full/one  (Hour lexeme 'full/one  (string-length lexeme))]
   
   [minute          (Minute lexeme (string-length lexeme))]
   
   [second          (Second lexeme (string-length lexeme))]
   [second-fraction (SecondFraction lexeme (string-length lexeme))]
   [millisecond     (Millisecond lexeme (string-length lexeme))]
   
   [zone/short/noloc      (Zone lexeme 'offset-name 'short)]
   [zone/long/noloc       (Zone lexeme 'offset-name 'long)]
   [zone/iso/basic:hm-o   (Zone lexeme 'iso/basic   'hm-s)]
   [zone/gmt/long1        (Zone lexeme 'gmt         'long)]
   [zone/iso/ext          (Zone lexeme 'iso/ext     'hm-s)]
   [zone/gmt/short        (Zone lexeme 'gmt         'short)]
   [zone/gmt/long2        (Zone lexeme 'gmt         'long)]
   [zone/short/generic    (Zone lexeme 'generic     'short)]
   [zone/long/generic     (Zone lexeme 'generic     'long)]
   [zone/short/id         (Zone lexeme 'id          'short)]
   [zone/long/id          (Zone lexeme 'id          'long)]
   [zone/city             (Zone lexeme 'city        #f)]
   [zone/generic/loc      (Zone lexeme 'generic/loc #f)]
   [zone/iso/basic:h-m/z  (Zone lexeme 'iso/basic/z 'h-m)]
   [zone/iso/basic:hm/z   (Zone lexeme 'iso/basic/z 'hm)]
   [zone/iso/ext:hm/z     (Zone lexeme 'iso/ext/z   'hm)]
   [zone/iso/basic:hm-s/z (Zone lexeme 'iso/basic/z 'hm-s)]
   [zone/iso/ext:hm-s/z   (Zone lexeme 'iso/ext/z   'hm-s)]
   [zone/iso/basic:h-m    (Zone lexeme 'iso/basic   'h-m)]
   [zone/iso/basic:hm     (Zone lexeme 'iso/basic   'hm)]
   [zone/iso/ext:hm       (Zone lexeme 'iso/ext     'hm)]
   [zone/iso/basic:hm-s   (Zone lexeme 'iso/basic   'hm-s)]
   [zone/iso/ext:hm-s     (Zone lexeme 'iso/ext     'hm-s)]
   
   [quoted-literal        (Literal lexeme 
                                   (let ([len (string-length lexeme)])
                                     (string-replace
                                      (substring lexeme 1 (sub1 len))
                                      "''"
                                      "'")))]
   [time-separator        (TimeSeparator lexeme)]
   [reserved              (raise-pattern-error lexeme)]
   [any-char              (Literal lexeme lexeme)]
   [(eof)                 #f]))

(define-lex-abbrevs
  [quoted-literal (:: "'"
                      (:*
                       (:or (:~ "'")
                            "''"))
                      "'")])

(define-lex-abbrevs
  [era:abbrev (:** 1 3 "G")]
  [era:wide   (:= 4 "G")]
  [era:narrow (:= 5 "G")]
  
  [year (:+ "y")]
  
  [year/week (:+ "Y")]
  
  [year/ext  (:+ "u")]
  
  [year/cyclic:abbrev (:** 1 3 "U")]
  [year/cyclic:wide   (:= 4 "U")]
  [year/cyclic:narrow (:= 5 "U")]
  
  [year/related (:+ "r")]
  
  [quarter:fmt:numeric (:** 1 2 "Q")]
  [quarter:fmt:abbrev  (:= 3 "Q")]
  [quarter:fmt:wide    (:= 4 "Q")]
  [quarter:fmt:narrow  (:= 5 "Q")]
  
  [quarter:sa:numeric (:** 1 2 "q")]
  [quarter:sa:abbrev  (:= 3 "q")]
  [quarter:sa:wide    (:= 4 "q")]
  [quarter:sa:narrow  (:= 5 "q")]
  
  [month:fmt:numeric (:** 1 2 "M")]
  [month:fmt:abbrev  (:= 3 "M")]
  [month:fmt:wide    (:= 4 "M")]
  [month:fmt:narrow  (:= 5 "M")]
  
  [month:sa:numeric (:** 1 2 "L")]
  [month:sa:abbrev  (:= 3 "L")]
  [month:sa:wide    (:= 4 "L")]
  [month:sa:narrow  (:= 5 "L")]
  
  [week/year (:** 1 2 "w")]
  [week/month (:= 1 "W")]
  
  [day/month (:** 1 2 "d")]
  [day/year (:** 1 3 "D")]
  [day/week/month (:= 1 "F")]
  [day/jdn (:+ "g")]
  
  [weekday:fmt:abbrev (:** 1 3 "E")]
  [weekday:fmt:wide   (:= 4 "E")]
  [weekday:fmt:narrow (:= 5 "E")]
  [weekday:fmt:short  (:= 6 "E")]
  
  [weekday/local:fmt:numeric (:** 1 2 "e")]
  [weekday/local:fmt:abbrev  (:= 3 "e")]
  [weekday/local:fmt:wide    (:= 4 "e")]
  [weekday/local:fmt:narrow  (:= 5 "e")]
  [weekday/local:fmt:short   (:= 6 "e")]
  
  [weekday/local:sa:numeric (:= 1 "c")]
  [weekday/local:sa:abbrev  (:= 3 "c")]
  [weekday/local:sa:wide    (:= 4 "c")]
  [weekday/local:sa:narrow  (:= 5 "c")]
  [weekday/local:sa:short   (:= 6 "c")]
  
  [period:abbrev (:** 1 3 "a")]
  [period:wide   (:= 4 "a")]
  [period:narrow (:= 5 "a")]
  
  [hour/half (:** 1 2 "h")]
  [hour/full (:** 1 2 "H")]
  [hour/half/zero (:** 1 2 "K")]
  [hour/full/one  (:** 1 2 "k")]
  ;[hour/pref/period (:** 1 2 "j")]
  ;[hour/pref        (:** 1 2 "J")]
  
  [minute (:** 1 2 "m")]
  
  [second (:** 1 2 "s")]
  [second-fraction (:+ "S")]
  [millisecond (:+ "A")]
  
  [zone/short/noloc (:** 1 3 "z")]
  [zone/long/noloc  (:= 4 "z")]
  
  [zone/iso/basic:hm-o (:** 1 3 "Z")]
  [zone/gmt/long1      (:= 4 "Z")]
  [zone/iso/ext        (:= 5 "Z")]
  
  [zone/gmt/short   (:= 1 "O")]
  [zone/gmt/long2   (:= 4 "O")]
  
  [zone/short/generic (:= 1 "v")]
  [zone/long/generic  (:= 4 "v")]
  
  [zone/short/id    (:= 1 "V")]
  [zone/long/id     (:= 2 "V")]
  [zone/city        (:= 3 "V")]
  [zone/generic/loc (:= 4 "V")]
  
  [zone/iso/basic:h-m/z  (:= 1 "X")]
  [zone/iso/basic:hm/z   (:= 2 "X")]
  [zone/iso/ext:hm/z     (:= 3 "X")]
  [zone/iso/basic:hm-s/z (:= 4 "X")]
  [zone/iso/ext:hm-s/z   (:= 5 "X")]
  
  [zone/iso/basic:h-m  (:= 1 "x")]
  [zone/iso/basic:hm   (:= 2 "x")]
  [zone/iso/ext:hm     (:= 3 "x")]
  [zone/iso/basic:hm-s (:= 4 "x")]
  [zone/iso/ext:hm-s   (:= 5 "x")]

  [time-separator      ":"]

  [reserved            (:or (:/ #\a #\z) (:/ #\A #\Z))])
