:- initialization(main, main).
:- dynamic(nodes/1).
:- dynamic(edge/2).

main :-
  load,
  largest_clique(L),
  print_list(L), nl.

print_list([]).
print_list([S]) :- write(S).
print_list([H | T]) :- write(H), write(","), print_list(T).

largest_clique(L) :- largest_clique([], 0, L, _).
largest_clique(C, NC, L, NL) :- nodes(Nodes), enlarge_with(C, NC, L, NL, Nodes), !.

enlarge_with(C, NC, L, NL, []) :- L = C, NL is NC, !.
enlarge_with(C, NC, L, NL, [Next | Rest]) :-
  (\+  ord_memberchk(Next, C)), connect_all(Next, C), !,
  ord_add_element(C, Next, NextC),
  NextNC is NC + 1,
  largest_clique(NextC, NextNC, ThisL, ThisNL), !,
  enlarge_with(C, NC, RestL, RestNL, Rest), !,
  (ThisNL >= RestNL -> L = ThisL, NL is ThisNL ; L = RestL, NL is RestNL), !.
enlarge_with(C, NC, L, NL, [_ | Rest]) :- !, enlarge_with(C, NC, L, NL, Rest).

connect_all(_, []) :- !.
connect_all(N, [H | T]) :- edge(N, H), !, connect_all(N, T), !.

load :-
  open('aocinput.txt', read, Fd),
  read_string(Fd, _, File),
  close(Fd),
  split_string(File, "\n", "\n", Lines), !,
  maplist(assert_edge, Lines),
  findall(N, (edge(N, _) ; edge(_, N)), NodesList),
  list_to_ord_set(NodesList, Nodes),
  assertz(nodes(Nodes)), !.

assert_edge(Line) :-
  split_string(Line, "-", "-", [From, To]),
  (lt(From, To) -> assertz(edge(From, To)) ; assertz(edge(To, From))).

lt(A, B) :- string_codes(A, [A1, A2]), string_codes(B, [B1, B2]), (A1 < B1 ; A1 =:= B1, A2 =< B2).
