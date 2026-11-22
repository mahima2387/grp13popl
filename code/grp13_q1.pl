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