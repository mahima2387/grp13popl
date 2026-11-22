% Tests for P1 (code/grp13_q1.pl).
%
% Run from the repository root or from tests/:
%   swipl -q -f tests/test_q1.pl -g run_tests -t halt
%
% The file loads code/grp13_q1.pl itself, relative to this file's own
% folder, so it works from any working directory. Loading it again after
% you have already consulted code/grp13_q1.pl is harmless.

:- use_module(library(plunit)).
:- use_module(library(lists)).
:- use_module(library(apply)).

:- prolog_load_context(directory, Dir),
   atom_concat(Dir, '/../code/grp13_q1.pl', File),
   consult(File).

%! satisfies_all(+Clues, +S) is semidet.
%
%  Declarative reading: S satisfies every clue whose number is in Clues.
satisfies_all(Clues, S) :-
    forall(member(K, Clues), clue(K, S)).

%! main_lines(-Lines) is det.
%
%  Declarative reading: Lines is the list of lines main/0 prints, without
%  the newline characters. The text after the last newline must be empty,
%  so output that does not end in a newline makes this fail.
main_lines(Lines) :-
    with_output_to(string(Out), main),
    split_string(Out, "\n", "", Parts),
    once(append(Lines, [""], Parts)).

%! parse_line(+Line, -Friend) is semidet.
%
%  Declarative reading: Line has exactly the form
%  "Name = [Dept, Lang, Project]" and Friend is p(Name, Dept, Lang, Project)
%  with each part turned back into an atom ('c++' and 'AI' included).
parse_line(Line, p(Name, Dept, Lang, Project)) :-
    once(sub_string(Line, B, 4, A, " = [")),
    sub_string(Line, 0, B, _, NameS),
    sub_string(Line, _, A, 0, RestS),
    string_concat(Inside, "]", RestS),
    split_string(Inside, ",", "", [DeptS, LangS0, ProjectS0]),
    string_concat(" ", LangS, LangS0),
    string_concat(" ", ProjectS, ProjectS0),
    maplist([S, At]>>atom_string(At, S),
            [NameS, DeptS, LangS, ProjectS],
            [Name, Dept, Lang, Project]).

:- begin_tests(q1).

% --- P1.b: count_solutions ------------------------------------------------

test(count_clues_1_to_8, [true(N =:= 3)]) :-
    count_solutions([1,2,3,4,5,6,7,8], N).

test(count_no_clues, [true(N =:= 13824)]) :-
    count_solutions([], N).

test(count_order_does_not_matter, [true(N =:= 3)]) :-
    count_solutions([8,7,6,5,4,3,2,1], N).

% --- P1.c: clue 9 ---------------------------------------------------------

test(count_clues_1_to_9, [true(N =:= 1)]) :-
    count_solutions([1,2,3,4,5,6,7,8,9], N).

test(clue_9_alone_is_not_always_true, [true(N < 13824)]) :-
    count_solutions([9], N).

test(clue_9_keeps_one_of_the_three) :-
    findall(S, (solution(S), satisfies_all([1,2,3,4,5,6,7,8], S)), Sols),
    include(clue(9), Sols, Kept),
    length(Kept, 1).

% --- Clues ----------------------------------------------------------------

test(every_solution_satisfies_each_clue) :-
    findall(S, (solution(S), satisfies_all([1,2,3,4,5,6,7,8], S)), Sols),
    Sols \== [],
    forall(member(S, Sols),
           forall(between(1, 8, K), clue(K, S))).

test(each_clue_rules_something_out) :-
    forall(between(1, 9, K),
           ( count_solutions([K], N), N > 0, N < 13824 )).

% --- P1.a: main -----------------------------------------------------------

test(main_prints_four_lines, [true(Len =:= 4)]) :-
    main_lines(Lines),
    length(Lines, Len).

test(main_names_in_order, [true(Names == ['Alex','Ben','Carla','Dana'])]) :-
    main_lines(Lines),
    maplist(parse_line, Lines, Friends),
    maplist([p(Name,_,_,_), Name]>>true, Friends, Names).

test(main_lines_have_exact_format) :-
    main_lines(Lines),
    forall(member(L, Lines), parse_line(L, _)).

test(main_has_no_quotes) :-
    main_lines(Lines),
    forall(member(L, Lines), \+ sub_string(L, _, _, _, "'")).

test(main_prints_a_valid_solution) :-
    main_lines(Lines),
    maplist(parse_line, Lines, Printed),
    solution(Printed),
    satisfies_all([1,2,3,4,5,6,7,8], Printed),
    !.

:- end_tests(q1).