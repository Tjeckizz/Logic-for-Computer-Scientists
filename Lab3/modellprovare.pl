% For SICStus, uncomment line below: (needed for member/2)
%:- use_module(library(lists)).
:- discontiguous check/5.

% Load model, initial state and formula from file.
verify(Input) :-
    see(Input),
    read(T),
    read(L),
    read(S),
    read(F),
    seen,
    check(T, L, S, [], F).

% check(T, L, S, U, F)
% T - The transitions in form of adjacency lists
% L - The labeling
% S - Current state
% U - Currently recorded states
% F - CTL Formula to check.
%
% Should evaluate to true iff the sequent below is valid.
%
% (T,L), S |- F
% U
% To execute: consult('your_file.pl'). verify('input.txt').

% XXXXX Literals XXXXX
check(_, L, S, [], X) :-
    member([S, Labels], L),
    member(X, Labels).

% XXXXX Neg XXXXX
check(T, L, S, [], neg(X)) :-
     \+check(T, L, S, [], X).

% XXXXX And XXXXX
check(T, L, S, [], and(F,G)) :-
    check(T, L, S, [], F),
    check(T, L, S, [], G).

% XXXXX Or XXXXX
check(T, L, S, [], or(F,G)) :-
    check(T, L, S, [], F) ; check(T, L, S, [], G).

% XXXXX AX XXXXX
check(T, L, S, [], ax(X)) :-
     member([S, Transitions], T),
     checkAXtransitions(T, L, Transitions, [], X).

checkAXtransitions(T, L, [LastState|[]], [], X) :-
    check(T, L, LastState, [], X).

checkAXtransitions(T, L, [State|MoreStates], [], X) :-
     check(T, L, State, [], X),
     checkAXtransitions(T, L, MoreStates, [], X).

% XXXXX EX XXXXX
check(T, L, S, [], ex(X)) :-
     member([S, Transitions], T),
     checkEXtransitions(T, L, Transitions, [], X).

checkEXtransitions(T, L, [LastState|[]], [], X) :-
    check(T, L, LastState, [], X).

checkEXtransitions(T, L, [State|MoreStates], [], X) :-
    check(T, L, State, [], X) ; checkEXtransitions(T, L, MoreStates, [], X).

% XXXXX AG XXXXX

% AG1
check(_, _, S, U, ag(_)) :-
    member(S,U).

% AG2
check(T, L, S, U, ag(G)) :-
    \+member(S, U),
    check(T, L, S, [], G),
    member([S, Transitions], T),
    checkAGtransitions(T, L, Transitions, [S|U], G).

checkAGtransitions(T, L, [LastState|[]], U, G) :-
    check(T, L, LastState, U,  ag(G)).

checkAGtransitions(T, L, [State|MoreStates], U, G) :-
    check(T, L, State, U, ag(G)),
    checkAGtransitions(T, L, MoreStates, U,  G).

% XXXXX EG XXXXX

% EG1
check(_, _, S, U, eg(_)) :-
    member(S,U).

% EG2
check(T, L, S, U, eg(G)) :-
    \+member(S, U),
    check(T, L, S, [], G),
    member([S, Transitions], T),
    checkEGtransitions(T, L, Transitions, [S|U], G).

checkEGtransitions(T, L, [LastState|[]], U, G) :-
    check(T, L, LastState, U, eg(G)).

checkEGtransitions(T, L, [State|MoreStates], U, G) :-
    check(T, L, State, U, eg(G)) ; checkEGtransitions(T, L, MoreStates, U, G).

% XXXXX AF XXXXX

% AF1
check(T, L, S, U, af(F)) :-
    \+member(S, U),
    check(T, L, S, [], F).

% AF2
check(T, L, S, U, af(F)) :-
    \+member(S, U),
    member([S, Transitions], T),
    checkAFtransitions(T, L, Transitions, [S|U], F).

checkAFtransitions(T, L, [LastState|[]], U, F) :-
    check(T, L, LastState, U,  af(F)).

checkAFtransitions(T, L, [State|MoreStates], U, F) :-
    check(T, L, State, U, af(F)),
    checkAFtransitions(T, L, MoreStates, U,  F).

% XXXXX EF XXXXX

% EF1
check(T, L, S, U, ef(F)) :-
    \+ member(S, U),
    check(T, L, S, [], F).

% EF2
check(T, L, S, U, ef(F)) :-
    \+member(S, U),
    member([S, Transitions], T),
    checkEFtransitions(T, L, Transitions, [S|U], F).

checkEFtransitions(T, L, [LastState|[]], U, F) :-
    check(T, L, LastState, U, ef(F)).

checkEFtransitions(T, L, [State|MoreStates], U, F) :-
   checkEFtransitions(T, L, MoreStates, U, F) ; check(T, L, State, U, ef(F)).


