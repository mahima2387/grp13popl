:- use_module(library(plunit)).
:- consult('../code/grp13_q2.pl').

% Run with: swipl -q -f tests/test_q2.pl -g run_tests -t halt

:- begin_tests(split).

test(three_elements) :-
    findall(L-R, split([1,2,3], L, R), Ps),
    Ps == [[1]-[2,3], [1,2]-[3]].
test(one_element, [fail]) :- split([1], _, _).
test(empty, [fail])       :- split([], _, _).

:- end_tests(split).

:- begin_tests(expr).

test(single_number) :-
    expr([7], T, V), T == 7, V == 7.
test(empty, [fail]) :- expr([], _, _).
test(inexact_division_rejected) :-
    findall(V, expr([2,4], _, V), Vs),
    Vs == [6, -2, 8].
test(division_by_zero_rejected) :-
    findall(V, expr([5,0], _, V), Vs),
    Vs == [5, 5, 0].
test(zero_over_zero_rejected) :-
    findall(V, expr([0,0], _, V), Vs),
    Vs == [0, 0, 0].
test(negative_intermediate) :-
    expr([3,5], bin(-,3,5), V), V == -2.

:- end_tests(expr).

:- begin_tests(tree_string).

test(canonical_forms) :-
    forall(member(T-Expected,
                  [ bin(*,bin(+,4,2),3)   - "(4+2)*3",
                    bin(+,4,bin(*,2,3))   - "4+2*3",
                    bin(*,bin(/,8,4),2)   - "8/4*2",
                    bin(/,8,bin(*,4,2))   - "8/(4*2)",
                    bin(-,bin(-,1,2),3)   - "1-2-3",
                    bin(-,1,bin(-,2,3))   - "1-(2-3)",
                    bin(+,1,bin(+,2,3))   - "1+(2+3)",
                    bin(+,bin(+,1,2),3)   - "1+2+3"
                  ]),
           ( tree_string(T, S), S == Expected )).
test(result_is_string) :-
    tree_string(bin(+,1,2), S), string(S).
test(single_number_no_parens) :-
    tree_string(5, S), S == "5".

:- end_tests(tree_string).

:- begin_tests(generate_equation).

test(pdf_example) :-
    generate_equation([4,2,5,3], E),
    memberchk(E, ["4*2-5=3", "4*2=5+3", "4-2=5-3", "4/2=5-3",
                  "4=2*(5-3)", "4=2+(5-3)", "4=2+5-3"]).
test(two_four_eight) :-
    generate_equation([2,4,8], E), E == "2*4=8".
test(no_solution, [fail])  :- generate_equation([2,3,4], _).
test(empty, [fail])        :- generate_equation([], _).
test(one_element, [fail])  :- generate_equation([7], _).

:- end_tests(generate_equation).

% These need all_equations/2 and count_equations/2 (next prompt).
:- begin_tests(all_equations).

test(pdf_example) :-
    all_equations([4,2,5,3], Es),
    Es == ["4*2-5=3", "4*2=5+3", "4-2=5-3", "4/2=5-3",
           "4=2*(5-3)", "4=2+(5-3)", "4=2+5-3"].
test(pdf_count) :-
    count_equations([4,2,5,3], N), N == 7.
test(no_solution) :-
    all_equations([2,3,4], Es), Es == [].
test(two_four_eight) :-
    all_equations([2,4,8], Es), Es == ["2*4=8"].
test(empty) :-
    all_equations([], Es), Es == [], count_equations([], N), N == 0.
test(one_element) :-
    all_equations([7], Es), Es == [], count_equations([7], N), N == 0.
test(zero_zero) :-
    all_equations([0,0], Es), Es == ["0=0"].
test(division_by_zero_five_zero_zero) :-
    all_equations([5,0,0], Es), Es == ["5*0=0"].
test(zeros_no_zero_division) :-
    all_equations([0,0,0], Es),
    Es == ["0*0=0", "0+0=0", "0-0=0", "0=0*0", "0=0+0", "0=0-0"],
    count_equations([0,0,0], N), N == 6.
test(negative_intermediate) :-
    all_equations([3,5,2,4], Es),
    memberchk("3-5=2-4", Es).
test(inexact_division_gives_none) :-
    all_equations([7,2,3], Es), Es == [].
test(no_duplicates) :-
    all_equations([1,2,3,4], Es),
    sort(Es, Sorted), Es == Sorted.

:- end_tests(all_equations).