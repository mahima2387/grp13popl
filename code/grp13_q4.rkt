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

;; (insert-if-short x lst n) -> list
;; x   : an atom
;; lst : a (possibly nested) list whose elements are atoms or lists
;; n   : an integer, n >= 0
;; Returns lst with x inserted at the front of every list, at every level
;; of nesting, whose length is less than n. Lengths are measured on the
;; original list before any insertion, and () is treated like any other list.
;; Recursive reading: first process each element of lst (an atom stays as it
;; is, a sublist is processed the same way), giving new-elements. Then, if
;; the length of the original lst is less than n, the result is x consed
;; onto new-elements; otherwise it is new-elements.
;; Tail recursive: no. The recursion depth is the nesting depth plus the
;; length of the longest list, which is fine for depth 100 and 10,000 elements.
(define (insert-if-short x lst n)
  (let ((new-elements
         (my-map (lambda (e)
                   (if (or (null? e) (pair? e))
                       (insert-if-short x e n)
                       e))
                 lst)))
    (if (< (my-length lst) n)
        (cons x new-elements)
        new-elements)))
