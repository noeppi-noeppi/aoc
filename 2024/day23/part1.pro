:- initialization(main, main).
:- dynamic(edge/2).

main :-
  load,
  setof([A, B, C], lan_party(A, B, C), L),
  length(L, Result),
  write(Result), nl.

lan_party(A, B, C) :- clique(A, B, C), (is_t(A) ; is_t(B) ; is_t(C)).

is_t(A) :- string_codes(A, [116, _]).

clique(A, B, C) :- edge(A, B), edge(A, C), edge(B, C).

load :-
  open('aocinput.txt', read, Fd),
  read_string(Fd, _, File),
  close(Fd),
  split_string(File, "\n", "\n", Lines), !,
  maplist(assert_edge, Lines).

assert_edge(Line) :-
  split_string(Line, "-", "-", [From, To]),
  (lt(From, To) -> assertz(edge(From, To)) ; assertz(edge(To, From))).

lt(A, B) :- string_codes(A, [A1, A2]), string_codes(B, [B1, B2]), (A1 < B1 ; A1 =:= B1, A2 =< B2).
