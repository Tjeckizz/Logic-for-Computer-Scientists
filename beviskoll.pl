% XXXXX Extracting data from inputfile XXXXX
verify(InputFileName) :-
    see(InputFileName),
    read(Prems),
    read(Goal),
    read(Proof),
    seen,
    valid_proof(Prems, Goal, Proof).

% XXXXX Is the proof valid or not? XXXXX

% Valid
valid_proof(Prems, Goal, Proof) :-
    goal_achieved(Goal, Proof),
    proof_determined(Prems, Proof, []),
    write("Yes").

% Invalid
valid_proof(_, Goal, Proof) :-
    \+goal_achieved(Goal, Proof),!,
    write("No"),
    fail.

valid_proof(Prems, _, Proof) :-
    \+proof_determined(Prems, Proof, []),
    write("No"),
    fail.

% XXXXX Determination of the goal XXXXX

% Base case - Is the goal achieved?
goal_achieved(Goal, [[_, Last, _]|[]]) :-
    Goal = Last.

% Determination of the last line recursively
goal_achieved(Goal, [_|T]) :-
    goal_achieved(Goal, T).


% XXXXX Determination of the proof XXXXX

% Base case
proof_determined(_, [], _).

% Box
proof_determined(Prems, [[[LineNo, Expression, 'assumption']|TBOX]|T], CheckedProofs) :-
    box_determined(Prems, TBOX, [[LineNo, Expression, 'assumption']|CheckedProofs]),
    proof_determined(Prems, T, [[[LineNo, Expression, 'assumption']|TBOX]|CheckedProofs]).

% Line
proof_determined(Prems, [H|T], CheckedProofs) :-
    valid_use_of_rule(Prems, H, CheckedProofs),
    proof_determined(Prems, T, [H|CheckedProofs]).

% XXXXX Boxhandling XXXXX

% Base case
box_determined(_, [], _).

% Box
box_determined(Prems, [[[LineNo, Expression, 'assumption']|TBOX]|T], CheckedProofs) :-
    box_determined(Prems, TBOX, [[LineNo, Expression, 'assumption']|CheckedProofs]),
    box_determined(Prems, T, [[[LineNo, Expression, 'assumption']|TBOX]|CheckedProofs]).

% Line
box_determined(Prems, [H|T], CheckedProofs) :-
     valid_use_of_rule(Prems, H, CheckedProofs),
     box_determined(Prems, T, [H|CheckedProofs]).

% Referral to a box
valid_box(LineNo, LineNo2, CheckedProofs, Expression, Expression2) :-
    get_box(LineNo, CheckedProofs, Box),
    member([LineNo, Expression, _], Box),
    member([LineNo2, Expression2, _], Box).

% Find the targetted box (if it exists)
get_box(LineNo, [H|_], H) :-
    member([LineNo, _, _], H).
get_box(LineNo, [_|T], Box) :-
    get_box(LineNo, T, Box).


% XXXXX Confirming the usage of rules XXXXX

% premise
valid_use_of_rule(Prems, [_, Expression, 'premise'], _) :-
    member(Expression, Prems).

% copy(x)
valid_use_of_rule(_,[_, Expression, copy(LineNo)], CheckedProofs) :-
    member([LineNo, Expression, _], CheckedProofs).

% andint(x,y)
valid_use_of_rule(_,[_, and(X, Y), andint(LineNo, LineNo2)], CheckedProofs) :-
    member([LineNo, X, _], CheckedProofs),
    member([LineNo2, Y, _], CheckedProofs).

% andel1(x)
valid_use_of_rule(_,[_, Expression, andel1(LineNo)], CheckedProofs) :-
    member([LineNo, and(Expression, _), _], CheckedProofs).

% andel2(x)
valid_use_of_rule(_,[_, Expression, andel2(LineNo)], CheckedProofs) :-
    member([LineNo, and(_, Expression), _], CheckedProofs).

% orint1(x)
valid_use_of_rule(_,[_, or(X, _), orint1(LineNo)], CheckedProofs) :-
    member([LineNo, X, _], CheckedProofs).

% orint2(x)
valid_use_of_rule(_,[_, or(_, Y), orint2(LineNo)], CheckedProofs) :-
    member([LineNo, Y, _], CheckedProofs).

% orel(x,y,z,u,v)
valid_use_of_rule(_,[_, Expression, orel(LineNo, LineNo2, LineNo3, LineNo4, LineNo5)], CheckedProofs):-
    member([LineNo, or(Expression2, Expression3), _], CheckedProofs),
    valid_box(LineNo2, LineNo3, CheckedProofs, Expression2, Expression),
    valid_box(LineNo4, LineNo5, CheckedProofs, Expression3, Expression).

% impint(x,y)
valid_use_of_rule(_,[_, imp(Expression, Expression2), impint(LineNo, LineNo2)], CheckedProofs) :-
    valid_box(LineNo, LineNo2, CheckedProofs, Expression, Expression2).

% impel(x,y)
valid_use_of_rule(_,[_, Expression, impel(LineNo, LineNo2)], CheckedProofs) :-
    member([LineNo, Expression2, _], CheckedProofs),
    member([LineNo2, imp(Expression2, Expression), _], CheckedProofs).

% negint(x,y)
valid_use_of_rule(_,[_, neg(Expression), negint(LineNo, LineNo2)], CheckedProof):-
    valid_box(LineNo, LineNo2, CheckedProof, Expression, 'cont').

% negel(x,y)
valid_use_of_rule(_,[_, cont, negel(LineNo, LineNo2)], CheckedProofs) :-
    member([LineNo, Expression, _], CheckedProofs),
    member([LineNo2, neg(Expression), _], CheckedProofs).

% contel(x)
valid_use_of_rule(_,[_, _, contel(LineNo)], CheckedProofs) :-
    member([LineNo, 'cont', _], CheckedProofs).

% negnegint(x)
valid_use_of_rule(_,[_, neg(neg(Expression)), negnegint(LineNo)], CheckedProofs) :-
    member([LineNo, Expression, _], CheckedProofs).

% negnegel(x)
valid_use_of_rule(_,[_, Expression, negnegel(LineNo)], CheckedProofs) :-
    member([LineNo, neg(neg(Expression)), _], CheckedProofs).

% mt(x,y)
valid_use_of_rule(_,[_, neg(Expression), mt(LineNo, LineNo2)], CheckedProofs) :-
    member([LineNo, imp(Expression, Expression2),_], CheckedProofs),
    member([LineNo2, neg(Expression2), _], CheckedProofs).

% pbc(x,y)
valid_use_of_rule(_,[_, Expression, pbc(LineNo, LineNo2)], CheckedProofs):-
    valid_box(LineNo, LineNo2, CheckedProofs, neg(Expression), 'cont').

% lem
valid_use_of_rule(_,[_, or(Expression, neg(Expression)), 'lem'], _).















