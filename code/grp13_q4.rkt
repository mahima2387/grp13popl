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

;; (make-inserter x len-ok?) -> function
;; x       : an atom to insert
;; len-ok? : a function of one number that returns true when a list of that length should get x
;; Returns a function of one argument (a list) that inserts x at the front of
;; every list, at every level of nesting, whose length satisfies len-ok?.
;; Lengths are measured on the original list before any insertion, and () is
;; treated like any other list.
;; Recursive reading: the returned function, called insert, first processes each
;; element of the list (an atom stays as it is, a sublist is processed by insert),
;; giving new-elements. Then, if (len-ok? (my-length original-list)) holds, the
;; result is x consed onto new-elements; otherwise it is new-elements.
;; Tail recursive: no. The recursion depth is the nesting depth plus the length of
;; the longest list, which is fine for depth 100 and 10,000 elements.
(define (make-inserter x len-ok?)
  (letrec ((insert
            (lambda (lst)
              (let ((new-elements
                     (my-map (lambda (e)
                               (if (or (null? e) (pair? e))
                                   (insert e)
                                   e))
                             lst)))
                (if (len-ok? (my-length lst))
                    (cons x new-elements)
                    new-elements)))))
    insert))

;; (insert-if-short x lst n) -> list
;; x   : an atom
;; lst : a (possibly nested) list whose elements are atoms or lists
;; n   : an integer, n >= 0
;; Returns lst with x inserted at the front of every list, at every level of
;; nesting, whose length is less than n.
;; Recursive reading: not recursive itself; it builds the inserter for x that
;; accepts lengths below n, and applies it to lst.
;; Tail recursive: not applicable.
(define (insert-if-short x lst n)
  ((make-inserter x (lambda (len) (< len n))) lst))

;; (print-insert-result) -> prints one line
;; Takes no arguments. Reads x, then lst, then n from standard input
;; (in that order, with read), and prints the result of
;; (insert-if-short x lst n) with display, followed by a newline.
;; Prints no prompt or any other text.
;; Recursive reading: not recursive; it reads the three values and displays
;; the result of insert-if-short on them.
;; Tail recursive: not applicable.
(define (print-insert-result)
  (let* ((x (read))
         (lst (read))
         (n (read)))
    (display (insert-if-short x lst n))
    (newline)))