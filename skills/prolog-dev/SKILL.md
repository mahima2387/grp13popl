---
name: prolog-dev
description: Conventions, run/test commands, self-review checklist and known AI failure modes for writing SWI-Prolog 9.x code for CS F301 Assignment 2 (problems P1 and P2). Use for any Prolog predicate, test file or review in this repository.
---

# prolog-dev

## 1. Language and environment

- **SWI-Prolog 9.x.** Write standard ISO-style Prolog plus SWI built-ins only.
- Solution files: `code/id_q1.pl`, `code/id_q2.pl`. Write code **below the template line** and leave the template untouched.
- **Allowed libraries (solution code):** `lists`, `apply`, `yall`, `aggregate`. Load them explicitly at the top of the file:
  ```prolog
  :- use_module(library(lists)).
  :- use_module(library(apply)).
  :- use_module(library(yall)).
  :- use_module(library(aggregate)).
  ```
  Do not load or rely on anything else (`clpfd`, `dcg/basics`, `strings`, `readutil`, `solution_sequences`, etc.).
- `library(plunit)` may be used **only in test files** under `tests/`, never in `code/`. The library limit applies to the solution files. If the course staff say plunit is banned in tests too, use the plain-Prolog test runner in section 5.2 instead, which needs only `lists`.

## 2. Hard rules (never break these)

- No `assert/1`, `asserta/1`, `assertz/1`, `retract/1`, `retractall/1`, or `abolish/1`.
- No global variables: no `b_setval/2`, `b_getval/2`, `nb_setval/2`, `nb_getval/2`.
- Never call `halt/0` or `halt/1` in solution code.
- Never use `:- initialization(main, main).` (or any `initialization/1,2` directive that runs `main`).
- No printing except the output the problem specifies. No debug `format/2`, `writeln/1` or `print/1` left in.
- P1: do not hard-code the answer; derive it from the `clue/2` clauses.
- P2: do not build a string and parse it back (`term_string/2`, `term_to_atom/2`, `read_term_from_atom/3`, `number_codes` on expressions, etc.) to evaluate an expression. Evaluate the expression tree directly.
- P2: never loop or raise an error. Failing is the correct behaviour when there is no answer (including lists of length 0 or 1).

## 3. Naming and comment conventions

- Predicate names: `snake_case`, descriptive (`split_list/3`, `eval_expr/2`, `clue/2`).
- Variable names: `CamelCase`, meaningful (`Solution`, `Left`, `Right`, `Value`). Use `_` or `_Name` for unused variables. Never leave singleton warnings.
- Helper predicates sit directly below the predicate that uses them.
- **Every predicate gets a header comment** in this form:
  ```prolog
  %! split_list(+List, -Prefix, -Suffix) is nondet.
  %
  %  Declarative reading: Prefix and Suffix are both non-empty
  %  and Prefix appended to Suffix is List.
  ```
  - First line: name, argument modes (`+` input, `-` output, `?` either) and determinism (`det`, `semidet`, `nondet`).
  - Then a **declarative reading**: what relation holds when the predicate is true. Describe the logic, not the steps ("X is the sum of ..." rather than "loop over ... and add").
- Each clause of a multi-clause predicate gets a one-line comment when its case is not obvious (base case, recursive case, error case).
- P1 clues: each clue is its own clause `clue(N, Solution)` with the English clue as a comment directly above it. Clue 9 must use the exact prefix `% CLUE 9:`.

## 4. How to run code

Run from the directory that contains the file.

**How `main/0` gets run.** The grader runs P1 with `swipl -q -f id_q1.pl` and expects `main` to run. Code is written below the course template line, and the template is responsible for starting `main`. So:
- Never add a directive that starts `main` yourself: no `initialization(main, main)`, and also no `:- initialization(main).` or `:- main.`. Those would also run `main` during `swipl -q -f id_q1.pl -g "<goal>" -t halt` and print extra lines before the goal's output.
- Only define `main/0`. Do not touch or duplicate the template line.
- If the template does not start `main`, ask the course staff instead of adding a directive.
- When testing locally, call `main` explicitly so the result does not depend on the template:

```bash
# Run main/0 explicitly and exit
swipl -q -f id_q1.pl -g main -t halt

# Run main/0 the way the grader does (needs the template)
swipl -q -f id_q1.pl

# Run any other goal and exit
swipl -q -f id_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8], N), print(N), nl" -t halt
swipl -q -f id_q2.pl -g "all_equations([4,2,5,3], Es), print(Es), nl" -t halt

# Check for warnings (singletons, discontiguous clauses, undefined procedures)
swipl -q -f id_q2.pl -g "check" -t halt
```

`halt` appears only on the command line (`-t halt`), never in the file.

## 5. How to test

### 5.1 Default: plunit

One test file per problem in `tests/`, e.g. `tests/test_q1.pl`, `tests/test_q2.pl`:

```prolog
:- use_module(library(plunit)).
:- consult('../code/id_q2.pl').

:- begin_tests(q2).

% Examples from the assignment PDF
test(all_4253) :-
    all_equations([4,2,5,3], Es),
    Es == ["4*2-5=3","4*2=5+3","4-2=5-3","4/2=5-3",
           "4=2*(5-3)","4=2+(5-3)","4=2+5-3"].
test(none_234, [fail]) :-
    generate_equation([2,3,4], _).
test(empty_list, [fail]) :-
    generate_equation([], _).
test(result_is_string, [true(string(E))]) :-
    generate_equation([2,4,8], E).

:- end_tests(q2).
```

Run with:

```bash
cd tests
swipl -q -f test_q2.pl -g run_tests -t halt
```

Testing conventions:
- Include **every example from the PDF**, then add edge cases: empty list, single element, zeros, division by zero, inexact division, negative intermediate values, duplicate-producing inputs.
- Use `==` (not `=`) to compare results so an unbound output cannot pass by accident.
- Use `[fail]` for goals that must fail, `[true(Cond)]` for property checks, `[nondet]` if a choice point is expected, and `[setup(...)]` only if needed.
- For "must not loop" cases, wrap with `call_with_time_limit/2` only inside tests (it is in `library(time)`, which is fine in tests but not in `code/`).
- Test **determinism**: a predicate documented as `det` should not leave choice points (plunit warns about this, so do not silence it with `[nondet]` unless it really is nondeterministic).

### 5.2 Fallback: plain-Prolog test runner (no plunit)

Use this only if plunit is not allowed in tests. It uses only `library(lists)` and core built-ins, so it follows the same library rules as `code/`. Use the same file names and test cases as 5.1.

```prolog
:- use_module(library(lists)).
:- consult('../code/id_q2.pl').

%! expect_true(+Name, :Goal) is det.
%
%  Declarative reading: prints "PASS Name" if Goal succeeds,
%  otherwise "FAIL Name". Never fails itself; errors count as FAIL.
expect_true(Name, Goal) :-
    (   catch(once(Goal), _, fail)
    ->  format("PASS ~w~n", [Name])
    ;   format("FAIL ~w~n", [Name])
    ).

%! expect_fail(+Name, :Goal) is det.
%
%  Declarative reading: prints "PASS Name" if Goal fails without
%  throwing an error, otherwise "FAIL Name".
expect_fail(Name, Goal) :-
    (   catch(\+ Goal, _, fail)
    ->  format("PASS ~w~n", [Name])
    ;   format("FAIL ~w~n", [Name])
    ).

%! run_all is det.
%
%  Declarative reading: runs every test case for this problem.
run_all :-
    expect_true(all_4253,
        ( all_equations([4,2,5,3], Es),
          Es == ["4*2-5=3","4*2=5+3","4-2=5-3","4/2=5-3",
                 "4=2*(5-3)","4=2+(5-3)","4=2+5-3"] )),
    expect_fail(none_234, generate_equation([2,3,4], _)),
    expect_fail(empty_list, generate_equation([], _)),
    expect_true(result_is_string,
        ( generate_equation([2,4,8], E), string(E) )).
```

Run with:

```bash
cd tests
swipl -q -f test_q2.pl -g run_all -t halt
```

Any line starting with `FAIL` is a failing test. This runner does not check for leftover choice points, so test determinism by hand: after `once/1` is removed, the goal should give exactly one answer at the toplevel.

## 6. Self-review checklist (apply before every answer)

Go through every item. If any item fails, fix the code before answering.

1. **Rules:** no `assert`/`retract`, no global variables, no `halt`, no directive that starts `main` (`initialization(main, main)`, `initialization(main)` or `:- main.`), no libraries outside `lists`/`apply`/`yall`/`aggregate` in `code/`.
2. **Output:** prints exactly what the spec says and nothing else. Check spacing, commas, brackets, quoting and the trailing newline. `'c++'` and `'AI'` print as `c++` and `AI` with `write/1` or `format("~w")` (not `print/1` or `~q`, which add quotes).
3. **Types:** P2 equations are **strings** (`"..."`), not atoms or code lists. Check with `string/1`. Use `format(string(S), ...)`, `string_concat/3` or `atomics_to_string/2` to build them.
4. **Arithmetic:** uses `is/2` and `=:=`, not `=` for numeric comparison. Division is checked for a zero divisor and exactness (`Y =\= 0, X mod Y =:= 0`) **before** computing `X // Y`. Note that `/` can return a float or a rational in SWI, so use `//` once exactness is known.
5. **Termination:** every recursive predicate has a base case reached on all inputs, and recursion is on a strictly smaller structure. No left recursion. Generators over infinite domains are bounded.
6. **Failure vs error:** the predicate fails (rather than throwing) on unsolvable or degenerate inputs: `[]`, `[X]`, division by zero, unbound arguments in `is/2`.
7. **Instantiation order:** all variables in an arithmetic goal are bound before `is/2` or a comparison runs. In P1, `\=` and `\+` checks run only on bound values (or only after the solution is fully filled in).
8. **Duplicates and order:** `all_equations` removes duplicates and sorts with `sort/2` (which does both). `findall/3` + `length/2` or `aggregate_all(count, ...)` count correctly when there are no solutions (0, not failure).
9. **Determinism:** `main/0` and other `det` predicates leave no spurious choice points and print once. Use `once/1` where only the first solution is wanted.
10. **Comments:** every predicate has a mode line and a declarative reading. No singleton-variable warnings. No discontiguous-clause warnings (keep all clauses of a predicate together, e.g. all `clue/2` clauses in a row).
11. **Run it:** load the file with `swipl` and run the PDF examples plus at least one edge case. Report the actual output, not the expected one.
12. **Scope:** answer only the one piece requested (one predicate, test file or review). Do not write the rest of the problem.

## 7. Common mistakes AI tools make in Prolog

- **Using `=` for arithmetic:** writing `X = Y + 1` and expecting `X` to be a number. It unifies with the term `Y+1`. Use `X is Y + 1`.
- **Comparing with `==` or `=` instead of `=:=`:** `2+2 == 4` fails. Use `=:=` for numeric equality.
- **Calling `is/2` on unbound variables:** produces an instantiation error instead of failure. Order goals so inputs are bound first.
- **Negation on unbound variables:** `\+ X = a` or `X \= Y` before `X`/`Y` are bound gives wrong answers, because negation-as-failure is not logical negation. Constrain only after binding.
- **Float/rational division:** using `/` and getting `2.0` or `1r2`, then printing or comparing wrongly. Check exactness, then use `//`.
- **Forgetting division by zero** inside nested sub-expressions (not just the top-level one).
- **Atoms vs strings vs code lists:** returning `'4*2=5+3'` (atom) or a code list instead of the string `"4*2=5+3"`. The double-quote flag in SWI 9 makes `"..."` a string by default, but AI-generated code often mixes in `atom_concat/3` and `atom_codes/2`.
- **Quoting in output:** printing `'c++'` or `'AI'` with quotes by using `print/1`, `writeq/1` or `~q`.
- **Hallucinated built-ins or libraries:** e.g. `sum/2`, `string_join/3`, `list_to_string/2`, or `between/3` assumed to accept unbound bounds; reaching for `clpfd` (not allowed here).
- **Leaving debug output** (`writeln`, `format`) or calling `halt` inside the file, or adding `:- initialization(main, main).`.
- **Infinite loops from left recursion** or from generating expressions without splitting the input list into strictly smaller parts first.
- **Duplicate solutions** because two clauses can produce the same term (e.g. both `split` orders, or redundant parenthesisation cases), then counting them twice.
- **Wrong parenthesisation for non-associative operators:** treating `-` and `/` as associative so `1-(2-3)` prints as `1-2-3`. Right operands of equal precedence need parentheses.
- **Cut misuse:** a red cut (`!`) that silently removes valid solutions, or a missing cut that leaves extra solutions in a `det` predicate. Prefer `once/1` or `->` with explicit else branches.
- **Discontiguous clauses:** spreading clauses of the same predicate (like `clue/2`) across the file, which triggers warnings and can be misread by the grader.
- **Singleton variables and typos** in variable names (e.g. `Soluton`) that silently create a fresh variable and make a clue always true.
- **Brute-force generate-and-test that is too slow:** generating all 24^3 permutations before applying any constraint is fine for P1, but test early where it helps. For P2 avoid regenerating the same sub-expression many times when not needed.
- **Claiming code was tested when it was not.** Always run the code and show real output.