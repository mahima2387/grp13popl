---
name: scheme-dev
description: Conventions, allowed and forbidden built-ins, run/test commands, self-review checklist and known AI failure modes for writing Racket 8.x (#lang racket/base) code for CS F301 Assignment 2 (problems S1 and S2). Use for any Scheme function, test file or review in this repository.
---

# scheme-dev

## 1. Language and environment

- **Racket 8.x**, every file starts with `#lang racket/base`.
- Solution files: `code/id_q3.rkt` (S1), `code/id_q4.rkt` (S2). Write code **below the template line** and leave the template untouched.
- The template defines the test data and calls the functions. Do not add your own top-level calls, `provide`, `require` or `module+` to the solution files.
- No `require` of any kind in solution files (no `racket/list`, `racket/string`, etc.).

## 2. Built-ins

### 2.1 Allowed (exact list from the assignment)

Only these may appear in solution files:

| Group | Allowed |
|---|---|
| Definitions and binding | `define`, `lambda`, `let`, `let*`, `letrec`, named `let` |
| Control | `if`, `cond` (with `else`), `and`, `or`, `not`, `begin` |
| Quoting | `quote` (written `'`) |
| Pairs and lists | `cons`, `car`, `cdr`, `list` |
| `car`/`cdr` compositions (up to four levels) | `caar`, `cadr`, `cdar`, `cddr`, `caaar`, `caadr`, `cadar`, `caddr`, `cdaar`, `cdadr`, `cddar`, `cdddr`, `caaaar`, `caaadr`, `caadar`, `caaddr`, `cadaar`, `cadadr`, `caddar`, `cadddr`, `cdaaar`, `cdaadr`, `cdadar`, `cdaddr`, `cddaar`, `cddadr`, `cdddar`, `cddddr` |
| Predicates | `null?`, `pair?`, `eq?` |
| Association lists | `assq`, `assoc` |
| Arithmetic and comparison | `+`, `-`, `*`, `<`, `>`, `<=`, `>=`, `=` |
| Output | `display`, `newline` |
| **S2 only** | `read` |

Literals `#t`, `#f`, numbers and quoted data are fine.

### 2.2 Forbidden (explicitly named in the assignment)

- `set!` and its relatives (`set-car!`, `set-cdr!`, `set-box!`, any mutation)
- vectors, hash tables, strings
- loops: `do`, `for` (and every `for/...` form)
- `length`, `append`, `reverse`, `map`, `filter`, `member`, `memq`, `list-ref`, `list-tail`

### 2.3 Also forbidden because they are not on the allowed list

Anything else from `racket/base`. AI tools reach for these often, so check for them specifically:

- `equal?`, `eqv?`, `list?`, `number?`, `symbol?`, `zero?`, `empty?`, `cons?`
- `add1`, `sub1`, `max`, `min`, `abs`, `/`, `quotient`, `remainder`, `modulo`
- `when`, `unless`, `case`, `match`, `define-values`, `let-values`, `values`
- `apply`, `foldl`, `foldr`, `andmap`, `ormap`, `for-each`, `build-list`, `void`
- `printf`, `write`, `print`, `displayln`, `format`, `~a`
- `first`, `rest`, `second`, `last`, `empty`, `null`, `list*`, `cons*`
- `read` in S1 (it is allowed only in S2)

If one of these is needed, write a helper from allowed built-ins and prefix it with `my-` (e.g. `my-reverse`, `my-length`, `my-map`, `my-max`, `my-append`).

## 3. Naming and comment conventions

- Function names: `kebab-case`, predicates end in `?` (`leaf?`, `len-ok?`), helpers that replace forbidden built-ins start with `my-`.
- Accumulator parameters are named `acc` (or `acc-...` when there are several).
- Helper functions sit directly below the function that uses them, or inside it with `letrec` / named `let` when they are private to it.
- **Every function gets a header comment** in this form:
  ```racket
  ;; (my-reverse lst) -> list
  ;; lst : a proper list
  ;; Returns the elements of lst in reverse order.
  ;; Recursive reading: the reverse of () is acc; the reverse of
  ;; (a . rest) onto acc is the reverse of rest onto (a . acc).
  ;; Tail recursive: yes (accumulator).
  ```
  - Line 1: call shape and result type.
  - Then one line per parameter with its type.
  - A one-line purpose.
  - A **recursive reading**: the base case and how the result for the whole structure is built from the result for the smaller part. Describe the structure, not the steps.
  - Whether the function is tail recursive.
- Pass all state through function arguments. No mutation, no top-level variables that change.

## 4. How to run code

```bash
# S1: the template defines the trees and calls the functions
racket code/id_q3.rkt

# S2: input is read from standard input in the order x, lst, n
echo "42 ((1 2) (3 4 5) (6) ()) 3" | racket code/id_q4.rkt

# Syntax / unbound identifier check without running the program
raco make code/id_q3.rkt
```

`raco make` reports unbound identifiers, which catches most misspelled helpers. It does not catch use of a built-in that exists in `racket/base` but is forbidden here, so check those by reading the code against section 2.

To list every identifier used, as a quick audit against section 2:

```bash
# Splits the code into tokens; skip the comment words when reading the list
grep -v '^ *;' code/id_q3.rkt | tr "()'" '   ' | tr -s ' \t' '\n' | sort -u
```

## 5. How to test

One test file per problem in `tests/`. Output tests are the main check, because both problems are graded on what they print.

### 5.1 Output tests (main method)

`tests/test_q4.sh`, one case per line of input and expected output:

```bash
#!/usr/bin/env bash
# Each case: standard input, then expected output (from the PDF and own edge cases)
cd "$(dirname "$0")/.."
pass=0; fail=0
check () {
  actual=$(printf '%s' "$1" | racket code/id_q4.rkt)
  if [ "$actual" = "$2" ]; then pass=$((pass+1)); echo "PASS: $1"
  else fail=$((fail+1)); echo "FAIL: $1"; echo "  expected: $2"; echo "  actual:   $actual"; fi
}
check "42 ((1 2) (3 4 5) (6) ()) 3" "((42 1 2) (3 4 5) (42 6) (42))"
check "0 (((1) 2) (3) ((4 5 6) ())) 3" "((0 (0 1) 2) (0 3) (0 (4 5 6) (0)))"
check "7 () 3" "(7)"
check "7 () 0" "()"
echo "$pass passed, $fail failed"
```

Run with `bash tests/test_q4.sh`.

For S1 the output is fixed by the template, so `tests/test_q3.sh` compares the whole output of `racket code/id_q3.rkt` with an expected-output file (`tests/expected_q3.txt`) using `diff`. For function-level S1 cases (t1, t2, t3, `'()`, own edge cases), use 5.2.

### 5.2 Function tests with rackunit

`rackunit` and the extra built-ins below are used **only in test files**, never in `code/`. The solution files have no `provide`, so the test reaches inside the module with `module->namespace`. Output is captured as a string so `display` output can be compared.

```racket
#lang racket/base
(require rackunit racket/port racket/runtime-path)
(define-runtime-path q3 "../code/id_q3.rkt")

;; Load the module (silencing the template's own output), then get its namespace.
(with-output-to-string (lambda () (dynamic-require q3 #f)))
(define ns (module->namespace q3))
(define (fn name) (eval name ns))

;; Calls (f arg) and returns everything it printed.
(define (output-of f arg) (with-output-to-string (lambda () (f arg))))

(define t1 '(4 (2 (1 () ()) (3 () ())) (6 (5 () ()) (7 () ()))))
(define t2 '(1 () (2 () (3 () ()))))
(define t3 '(a (b () ()) (c () ())))

(check-equal? (output-of (fn 'print-inorder) t1) "(1 2 3 4 5 6 7)\n")
(check-equal? (output-of (fn 'print-all-traversals) t3) "(b a c)\n(a b c)\n(b c a)\n")
(check-equal? (output-of (fn 'print-height-and-leaves) t2) "(3 1)\n")
(check-equal? (output-of (fn 'print-height-and-leaves) '()) "(0 0)\n")
```

For S2, the module calls `read` when loaded, so give it input while loading:

```racket
(with-input-from-string "1 () 1"
  (lambda () (with-output-to-string (lambda () (dynamic-require q4 #f)))))
(define ns (module->namespace q4))
(check-equal? ((eval 'insert-if-short ns) 'x '((1) (2 3)) 2) '(x (x 1) (2 3)))
```

Run with `raco test tests/test_q3.rkt` (or `racket tests/test_q3.rkt`).

Testing conventions:
- Include **every example from the PDF**, then edge cases: empty tree / empty list, single node, left-only and right-only chains, symbol values, `n = 0`, `n = 1`, deeply nested lists, atoms that are symbols vs digits.
- **Size tests for S2:** the hidden tests use nesting depth 100 and lists of 10,000 elements. Generate these in the test file (with any Racket you like, since tests are not limited) and check the program finishes quickly and the result has the right shape.
- Compare output strings exactly, including the final newline.

## 6. Self-review checklist (apply before every answer)

Go through every item. If any item fails, fix the code before answering.

1. **Built-ins:** every identifier in the solution is either in section 2.1 or defined in the file. Check especially for `equal?`, `list?`, `number?`, `symbol?`, `zero?`, `add1`, `max`, `when`, `apply`, `length`, `append`, `reverse`, `map`. `read` appears only in S2.
2. **No mutation:** no `set!` or any `...!` form, no vectors, hash tables or strings (including string literals in `display`).
3. **No extra forms in `code/`:** no `require`, `provide`, `module+`, or top-level calls beyond what the template has.
4. **Output:** exactly what the spec says. Each print function ends with `newline`. Lists printed with one `display` of a list (so the format is `(1 2 3)`), not element by element. Empty list prints `()`. No prompt text in S2.
5. **Order:** subtrees visited left first, then right. Inorder = left, node, right; preorder = node, left, right; postorder = left, right, node. Accumulator-built lists are reversed (or built back to front) so the final order is correct.
6. **Definitions match the spec:** height of `()` is 0 and a single node is 1; a leaf has both subtrees `()`; the empty tree has 0 leaves. In S2, length is measured on the **original** list before insertion, the top-level list is treated like any other, and `()` becomes `(x)` when `0 < n`.
7. **Atoms vs lists (S2):** a list element is a list exactly when it is `null?` or `pair?`; everything else is an atom and is left alone. Do not use `list?`.
8. **Base cases:** every recursive function handles `()` first and recurses on a strictly smaller structure (`cdr`, a subtree, a sublist).
9. **Tail recursion:** use an accumulator where it is natural (traversals, `my-length`, `my-reverse`). Non-tail recursion is acceptable for tree recursion and `my-map`, but check it works on 10,000-element lists and depth-100 nesting.
10. **Efficiency:** no repeated `my-append` inside a loop that makes traversals quadratic; no recomputing `my-length` of the same list inside the recursion over it.
11. **Comments:** every function has a header with call shape, parameter types, purpose, recursive reading and tail-recursion note.
12. **Run it:** run the file (and the S2 examples through standard input) and report the actual output, not the expected one.
13. **Scope:** answer only the one piece requested (one function, test file or review). Do not write the rest of the problem.

## 7. Common mistakes AI tools make in Scheme

- **Using forbidden built-ins out of habit:** `length`, `append`, `reverse`, `map`, `filter`, `apply`, `foldl`, and especially `equal?`, `list?`, `number?`, `symbol?`, `add1`, `max`, `zero?` that are not on the allowed list even though they are not named as forbidden.
- **Using `when` / `unless` / `case`** instead of `if` / `cond`.
- **Printing element by element** with `display` and spaces, which needs strings (forbidden) and often gets spacing or parentheses wrong. Build the list, then `display` it once.
- **Forgetting `newline`** at the end, or adding an extra one.
- **Reversed accumulator output:** building a list with `cons` onto an accumulator and forgetting it comes out backwards.
- **Quadratic append:** writing inorder as `(my-append (inorder left) (cons v (inorder right)))` repeatedly. Correct for small trees, slow for large ones. Prefer an accumulator that is threaded right to left: `(inorder left (cons v (inorder right acc)))`.
- **Wrong height convention:** treating a single node as height 0, or the empty tree as -1.
- **Counting `()` as a leaf**, or counting a node with one empty child as a leaf.
- **Measuring length after insertion** in S2, so a list of length `n-1` grows to `n` and the decision is wrong for its parent; or forgetting to treat the top-level list like the others.
- **Treating `'()` as an atom** in S2, so empty sublists never get `x` inserted. In Racket `(pair? '())` is `#f`, so check `null?` too.
- **Using `list?`** to detect sublists (not allowed here; use `null?` / `pair?`).
- **Mixing `eq?` on numbers:** `eq?` on small integers usually works in Racket but is not guaranteed; compare numbers with `=`.
- **Mutation:** reaching for `set!` to keep a counter or accumulator instead of passing it as an argument.
- **Adding `provide`, `require` or test code** (`module+ test`) to the solution file.
- **Calling `read` the wrong number of times or in the wrong order** in S2 (must be `x`, then `lst`, then `n`), or printing a prompt before reading.
- **Shadowing built-ins** by naming a parameter `list` and then calling `(list ...)` in the same scope.
- **Claiming code was tested when it was not.** Always run the code and show real output.