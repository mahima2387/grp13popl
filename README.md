# CS F301 Principles of Programming Languages - Assignment 2 (Group 13)

## Members
| Name | Work |
|---|---|
| Mahima | Skill files, P1 (Prolog puzzle) and P1_REPORT.md, final checks |
| Aditi | P2 (Prolog arithmetic equation) |
| Anushka | S1 (Scheme tree traversals), S2 (Scheme conditional insert) |

## Layout
- `code/` - solutions: `grp13_q1.pl`, `grp13_q2.pl`, `grp13_q3.rkt`, `grp13_q4.rkt`
- `tests/` - tests: `test_q1.pl`, `test_q2.pl`, `test_q3.sh`, `test_q4.sh`
- `skills/` - `prolog-dev/SKILL.md`, `scheme-dev/SKILL.md`
- `prompts/` - AI prompts used, word for word: `P1.md`, `P2.md`, `S1.md`, `S2.md`
- `P1_REPORT.md` - value of N for clues 1-8 and what it means

## Environment
SWI-Prolog 9.x and Racket 8.x (`#lang racket/base`).

## Running

swipl -q -f code/grp13_q1.pl -g main -t halt
swipl -q -f code/grp13_q1.pl -g “count_solutions([1,2,3,4,5,6,7,8],N), print(N), nl” -t halt
swipl -q -f code/grp13_q2.pl -g “all_equations([4,2,5,3],E), print(E), nl” -t halt


## Tests

swipl -q -g “consult(‘code/grp13_q1.pl’), consult(‘tests/test_q1.pl’), run_tests” -t halt
swipl -q -g “consult(‘code/grp13_q2.pl’), consult(‘tests/test_q2.pl’), run_tests” -t halt
bash tests/test_q3.sh
bash tests/test_q4.sh

