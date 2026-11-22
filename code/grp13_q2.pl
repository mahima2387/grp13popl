% split(+List, -Left, -Right)
% Left and Right are both non-empty and Left ++ Right = List.
% Reading: the first element starts Left. Either Left stops there
% (provided something is left over for Right), or Left keeps growing
% by splitting the rest.
split([X|Rest], [X], Rest) :-
    Rest = [_|_].
split([X|Rest], [X|Left], Right) :-
    split(Rest, Left, Right).

% expr(+Numbers, -Tree, -Value)
% Tree is an expression tree over Numbers, in order, and Value is its value.
% A tree is either a number or bin(Op, Left, Right).
% Reading: a single number is its own tree. Otherwise split the list into
% two non-empty parts, build a tree for each, and join them with an operator.
expr([N], N, N).
expr(Numbers, bin(Op, L, R), Value) :-
    split(Numbers, Left, Right),
    expr(Left, L, LV),
    expr(Right, R, RV),
    apply_op(Op, LV, RV, Value).

% apply_op(?Op, +A, +B, -V)
% Division succeeds only when the divisor is non-zero and the result is exact.
apply_op(+, A, B, V) :- V is A + B.
apply_op(-, A, B, V) :- V is A - B.
apply_op(*, A, B, V) :- V is A * B.
apply_op(/, A, B, V) :-
    B =\= 0,
    A mod B =:= 0,
    V is A // B.

% prec(+Op, -P): binding strength. * and / bind tighter than + and -.
prec(+, 1).
prec(-, 1).
prec(*, 2).
prec(/, 2).

% tree_string(+Tree, -String)
% String is the canonical no-space SWI string for Tree.
% Reading: a number prints as decimal digits. Otherwise print the left
% operand, the operator, then the right operand, adding parentheses by
% the canonical rule.
tree_string(N, S) :-
    integer(N),
    format(string(S), "~d", [N]).
tree_string(bin(Op, L, R), S) :-
    prec(Op, P),
    left_operand(L, P, LS),
    right_operand(R, P, RS),
    format(string(S), "~w~w~w", [LS, Op, RS]).

% Left operand: parenthesised only if its top operator has LOWER precedence.
left_operand(T, P, S) :-
    tree_string(T, TS),
    (   T = bin(Op, _, _), prec(Op, Q), Q < P
    ->  format(string(S), "(~w)", [TS])
    ;   S = TS
    ).

% Right operand: parenthesised if its top operator has the SAME or lower precedence.
right_operand(T, P, S) :-
    tree_string(T, TS),
    (   T = bin(Op, _, _), prec(Op, Q), Q =< P
    ->  format(string(S), "(~w)", [TS])
    ;   S = TS
    ).