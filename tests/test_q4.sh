#!/usr/bin/env bash
# Output tests for S2 (code/grp13_q4.rkt).
# Copies the solution to a temp file, appends one call (like the grader),
# pipes the input in and compares the whole output, including the final newline.
cd "$(dirname "$0")/.." || exit 1
code="code/grp13_q4.rkt"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cp "$code" "$tmp/run.rkt"
printf '\n(print-insert-result)\n' >> "$tmp/run.rkt"
pass=0; fail=0

# check NAME INPUT EXPECTED   (EXPECTED is the printed line without its final newline)
check () {
  actual=$(printf '%s\n' "$2" | racket "$tmp/run.rkt" 2>&1; echo END)
  want="$3"$'\n'END
  if [ "$actual" = "$want" ]; then
    pass=$((pass+1)); echo "PASS: $1"
  else
    fail=$((fail+1)); echo "FAIL: $1"
    echo "  expected: $(printf '%s' "$3" | cut -c1-200)"
    echo "  actual:   $(printf '%s' "${actual%END}" | cut -c1-200)"
  fi
}

# --- Examples from the PDF ---
check "PDF example 1" "42 ((1 2) (3 4 5) (6) ()) 3"          "((42 1 2) (3 4 5) (42 6) (42))"
check "PDF example 2" "0 (((1) 2) (3) ((4 5 6) ())) 3"       "((0 (0 1) 2) (0 3) (0 (4 5 6) (0)))"
check "PDF example 3" "7 () 3"                               "(7)"
check "PDF example 4" "7 () 0"                               "()"

# --- n = 0: nothing is shorter than 0 ---
check "n=0 nested"    "9 (1 (2) ()) 0"                       "(1 (2) ())"

# --- n = 1: only empty lists get x ---
check "n=1 nested"    "9 (1 (2) ()) 1"                       "(1 (2) (9))"
check "n=1 empty top" "9 () 1"                               "(9)"

# --- Symbols as atoms and as x ---
check "symbols"       "x (a (b c) ()) 2"                     "(a (b c) (x))"

# --- Nested 100 deep: each list has one element, the innermost is () ---
D=100
in="()"
want="(0)"
for i in $(seq 2 $D); do in="($in)"; want="(0 $want)"; done
check "nested $D deep (n=2)" "0 $in 2" "$want"

# --- 10,000 elements ---
nums=$(seq 1 10000 | tr '\n' ' ')
nums=${nums% }
check "10000 elements, top list gets x (n=10001)"  "0 ($nums) 10001" "(0 $nums)"
check "10000 elements, top list unchanged (n=10000)" "0 ($nums) 10000" "($nums)"

# --- 10,000 empty sublists: each becomes (7), top list is not shorter than 1 ---
empties=$(yes '()' | head -n 10000 | tr '\n' ' ')
empties=${empties% }
sevens=$(yes '(7)' | head -n 10000 | tr '\n' ' ')
sevens=${sevens% }
check "10000 empty sublists (n=1)" "7 ($empties) 1" "($sevens)"

echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]