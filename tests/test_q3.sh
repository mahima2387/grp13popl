#!/usr/bin/env bash
# Output tests for S1 (code/grp13_q3.rkt).
# For each case: copy the solution to a temp file, append one call (like the grader),
# run it with racket and compare the whole output, including the final newline.
cd "$(dirname "$0")/.." || exit 1
code="code/grp13_q3.rkt"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
pass=0; fail=0

# check NAME CALL EXPECTED   (EXPECTED may contain newlines; give the output without the final newline)
check () {
  cp "$code" "$tmp/run.rkt"
  printf '\n%s\n' "$2" >> "$tmp/run.rkt"
  actual=$(racket "$tmp/run.rkt" 2>&1; echo END)
  want="$3"$'\n'END
  if [ "$actual" = "$want" ]; then
    pass=$((pass+1)); echo "PASS: $1"
  else
    fail=$((fail+1)); echo "FAIL: $1"
    echo "  expected: $3"
    echo "  actual:   ${actual%END}"
  fi
}

T1="'(4 (2 (1 () ()) (3 () ())) (6 (5 () ()) (7 () ())))"
T2="'(1 () (2 () (3 () ())))"
T3="'(a (b () ()) (c () ()))"
EMPTY="'()"
SINGLE="'(5 () ())"

# --- Examples from the PDF ---
check "t1 inorder"        "(print-inorder $T1)"             "(1 2 3 4 5 6 7)"
check "t1 all traversals" "(print-all-traversals $T1)"      $'(1 2 3 4 5 6 7)\n(4 2 1 3 6 5 7)\n(1 3 2 5 7 6 4)'
check "t1 height/leaves"  "(print-height-and-leaves $T1)"   "(3 4)"
check "t2 all traversals" "(print-all-traversals $T2)"      $'(1 2 3)\n(1 2 3)\n(3 2 1)'
check "t2 height/leaves"  "(print-height-and-leaves $T2)"   "(3 1)"
check "t3 all traversals" "(print-all-traversals $T3)"      $'(b a c)\n(a b c)\n(b c a)'
check "t3 height/leaves"  "(print-height-and-leaves $T3)"   "(2 2)"
check "empty inorder"     "(print-inorder $EMPTY)"          "()"
check "empty traversals"  "(print-all-traversals $EMPTY)"   $'()\n()\n()'
check "empty height/leaves" "(print-height-and-leaves $EMPTY)" "(0 0)"

# --- Own edge cases ---
check "single node traversals"   "(print-all-traversals $SINGLE)"      $'(5)\n(5)\n(5)'
check "single node height/leaves" "(print-height-and-leaves $SINGLE)"  "(1 1)"
check "left-only chain" "(print-all-traversals '(3 (2 (1 () ()) ()) ()))" $'(1 2 3)\n(3 2 1)\n(1 2 3)'
check "left-only chain height/leaves" "(print-height-and-leaves '(3 (2 (1 () ()) ()) ()))" "(3 1)"

# --- Deep chain: right chain 1..N, node i has right child i+1 ---
N=1000
chain=""
for i in $(seq 1 $N); do chain="$chain($i () "; done
chain="$chain()"
for i in $(seq 1 $N); do chain="$chain)"; done
up=$(seq 1 $N | tr '\n' ' ')
up=${up% }
down=$(seq $N -1 1 | tr '\n' ' ')
down=${down% }
expected="($up)"$'\n'"($up)"$'\n'"($down)"
check "deep chain ($N) traversals" "(print-all-traversals '$chain)" "$expected"
check "deep chain ($N) height/leaves" "(print-height-and-leaves '$chain)" "($N 1)"

echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]