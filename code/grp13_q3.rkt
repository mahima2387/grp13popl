#lang racket/base

;; (inorder tree acc) -> list
;; tree : a binary tree, either () or (value left right)
;; acc  : a list of values (the inorder result of everything to the right so far)
;; Returns the inorder values of tree, followed by the elements of acc.
;; Recursive reading: the inorder of () onto acc is acc; the inorder of
;; (v l r) onto acc is the inorder of l onto (v followed by the inorder of r onto acc).
;; Tail recursive: partly. The call on the left subtree is a tail call,
;; and the call on the right subtree is not. The depth of the recursion is
;; only the height of the tree, so this is fine.
(define (inorder tree acc)
  (if (null? tree)
      acc
      (inorder (cadr tree)
               (cons (car tree)
                     (inorder (caddr tree) acc)))))

;; (print-inorder tree) -> prints one line
;; tree : a binary tree, either () or (value left right)
;; Prints the list of the tree's values in inorder on one line.
;; Recursive reading: not recursive itself; it displays (inorder tree '()) and then a newline.
;; Tail recursive: not applicable.
(define (print-inorder tree)
  (display (inorder tree '()))
  (newline))
