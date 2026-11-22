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

;; (preorder tree acc) -> list
;; tree : a binary tree, either () or (value left right)
;; acc  : a list of values (the preorder result of everything to the right so far)
;; Returns the preorder values of tree, followed by the elements of acc.
;; Recursive reading: the preorder of () onto acc is acc; the preorder of
;; (v l r) onto acc is v followed by the preorder of l onto (the preorder of r onto acc).
;; Tail recursive: partly. The call on the right subtree is nested, so it is not a tail call.
;; The depth of the recursion is only the height of the tree, so this is fine.
(define (preorder tree acc)
  (if (null? tree)
      acc
      (cons (car tree)
            (preorder (cadr tree)
                      (preorder (caddr tree) acc)))))

;; (postorder tree acc) -> list
;; tree : a binary tree, either () or (value left right)
;; acc  : a list of values (the postorder result of everything to the right so far)
;; Returns the postorder values of tree, followed by the elements of acc.
;; Recursive reading: the postorder of () onto acc is acc; the postorder of
;; (v l r) onto acc is the postorder of l onto (the postorder of r onto (v followed by acc)).
;; Tail recursive: partly. The call on the right subtree is nested inside the call on the left.
;; The depth of the recursion is only the height of the tree, so this is fine.
(define (postorder tree acc)
  (if (null? tree)
      acc
      (postorder (cadr tree)
                 (postorder (caddr tree)
                            (cons (car tree) acc)))))

;; (print-all-traversals tree) -> prints three lines
;; tree : a binary tree, either () or (value left right)
;; Prints the inorder list, then the preorder list, then the postorder list,
;; each on its own line.
;; Recursive reading: not recursive itself; it displays each traversal
;; of tree onto '() and then a newline.
;; Tail recursive: not applicable.
(define (print-all-traversals tree)
  (display (inorder tree '()))
  (newline)
  (display (preorder tree '()))
  (newline)
  (display (postorder tree '()))
  (newline))
