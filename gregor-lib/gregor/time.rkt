#lang racket/base

(require racket/contract/base
         data/order

         "private/time.rkt"

         "private/core/hmsn.rkt")

(provide/contract
 [time            (->i ([hour (integer-in 0 23)])
                       ([minute (integer-in 0 59)]
                        [second (integer-in 0 59)]
                        [nanosecond (integer-in 0 (sub1 NS/SECOND))])
                       [t time?])]
 [time?           (-> any/c boolean?)]
 [time->iso8601   (-> time? string?)]
 [time=?          (-> time? time? boolean?)]
 [time<?          (-> time? time? boolean?)]
 [time<=?         (-> time? time? boolean?)]
 [time>?          (-> time? time? boolean?)]
 [time>=?         (-> time? time? boolean?)]
 [time-order      order?]
 [MIDNIGHT        time?]
 [NOON            time?])
