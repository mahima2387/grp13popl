:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(yall)).
:- use_module(library(aggregate)).

%! departments(-Depts) is det.
%
%  Declarative reading: Depts is the list of the four departments.
departments([research, development, design, testing]).

%! languages(-Langs) is det.
%
%  Declarative reading: Langs is the list of the four favorite languages.
languages([python, java, 'c++', javascript]).

%! projects(-Projects) is det.
%
%  Declarative reading: Projects is the list of the four project preferences.
projects(['AI', web, embedded, data]).

%! solution(-Solution) is nondet.
%
%  Declarative reading: Solution is a complete assignment
%  [p('Alex',D1,L1,P1), p('Ben',D2,L2,P2), p('Carla',D3,L3,P3),
%  p('Dana',D4,L4,P4)] in which each friend's department, language and
%  project come from the domains above and no two friends share a value
%  of the same attribute (each domain is used as a permutation).
%  Enumerates all 24 * 24 * 24 = 13824 assignments on backtracking.
solution([p('Alex',  D1, L1, P1),
          p('Ben',   D2, L2, P2),
          p('Carla', D3, L3, P3),
          p('Dana',  D4, L4, P4)]) :-
    departments(Depts),
    permutation(Depts, [D1, D2, D3, D4]),
    languages(Langs),
    permutation(Langs, [L1, L2, L3, L4]),
    projects(Projects),
    permutation(Projects, [P1, P2, P3, P4]).

%! clue(+N, +Solution) is semidet.
%
%  Declarative reading: clue number N (1 to 8) holds in the fully
%  filled-in Solution. Each clause looks up the friend(s) it talks about
%  with memberchk/2 (every value occurs exactly once, so the first match
%  is the only match) and then checks the remaining conditions.

% CLUE 1: The friend who prefers the AI project does not work in research
% and is not Dana.
clue(1, S) :-
    memberchk(p(Name, Dept, _, 'AI'), S),
    Dept \== research,
    Name \== 'Dana'.
% CLUE 2: Alex does not work in development and does not prefer C++.
clue(2, S) :-
    memberchk(p('Alex', Dept, Lang, _), S),
    Dept \== development,
    Lang \== 'c++'.
% CLUE 3: The friend working in the testing department likes Python.
clue(3, S) :-
    memberchk(p(_, testing, Lang, _), S),
    Lang == python.
% CLUE 4: Ben prefers web projects and does not work in testing.
clue(4, S) :-
    memberchk(p('Ben', Dept, _, Project), S),
    Project == web,
    Dept \== testing.
% CLUE 5: The friend whose favorite language is Java works in the design
% department.
clue(5, S) :-
    memberchk(p(_, Dept, java, _), S),
    Dept == design.
% CLUE 6: Carla's project preference is not embedded, and her department
% is not development.
clue(6, S) :-
    memberchk(p('Carla', Dept, _, Project), S),
    Project \== embedded,
    Dept \== development.
% CLUE 7: Dana's favorite language is not Java, and she works in research
% or testing.
clue(7, S) :-
    memberchk(p('Dana', Dept, Lang, _), S),
    Lang \== java,
    memberchk(Dept, [research, testing]).
% CLUE 8: The friend who prefers data projects works in research and does
% not use JavaScript.
clue(8, S) :-
    memberchk(p(_, Dept, Lang, data), S),
    Dept == research,
    Lang \== javascript.

%! main is det.
%
%  Declarative reading: prints the first assignment (in solution/1 order)
%  that satisfies clues 1 to 8, one friend per line, in the order Alex,
%  Ben, Carla, Dana. Fails silently if no assignment satisfies the clues.
main :-
    once(( solution(S),
           forall(between(1, 8, N), clue(N, S)) )),
    maplist(print_friend, S).

%! print_friend(+Friend) is det.
%
%  Declarative reading: prints Friend = p(Name, Dept, Lang, Project) as
%  the line "Name = [Dept, Lang, Project]". Uses ~w so quoted atoms such
%  as 'Alex', 'c++' and 'AI' print without quotes.
print_friend(p(Name, Dept, Lang, Project)) :-
    format("~w = [~w, ~w, ~w]~n", [Name, Dept, Lang, Project]).