#lang racket/base

;; (my-length lst) -> number
;; lst : a proper list
;; Returns the number of top-level elements of lst.
;; Recursive reading: the length of () is 0; the length of (a . rest)
;; is 1 more than the length of rest. The loop carries the count so far.
;; Tail recursive: yes (accumulator).
(define (my-length lst)
  (let loop ((rest lst) (acc 0))
    (if (null? rest)
        acc
        (loop (cdr rest) (+ acc 1)))))

;; (my-map f lst) -> list
;; f   : a function of one argument
;; lst : a proper list
;; Returns a new list holding (f e) for each element e of lst, in the same order.
;; Recursive reading: the map of f over () is (); the map of f over
;; (a . rest) is (f a) consed onto the map of f over rest.
;; Tail recursive: no. The recursion depth equals the length of lst,
;; which is fine for lists of 10,000 elements in Racket.
(define (my-map f lst)
  (if (null? lst)
      '()
      (cons (f (car lst))
            (my-map f (cdr lst)))))
