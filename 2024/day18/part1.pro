:- initialization(main, main).
:- dynamic(obstacle/1).

target([70, 70]).
target_flatc(FlatC) :- target(Target), flatc(FlatC, Target).

main :-
  parse_input,
  new_pq(PQ),
  new_as_entries(AsEntries, PQ),
  solve(AsEntries, PQ),
  target_flatc(FlatC),
  arg(FlatC, AsEntries, Entry),
  as_g(Entry, Result),
  write(Result), nl.

solve(AsEntries, PQ) :- pq_next(PQ, Next), !, solve(AsEntries, PQ, Next).
solve(_AsEntries, _PQ, Next) :- target_flatc(Next), !.
solve(AsEntries, PQ, Next) :-
  arg(Next, AsEntries, Entry),
  as_g(Entry, G),
  NextG is G + 1,
  neighbours(Next, NextNeighbours),
  maplist(as_reduce(AsEntries, NextG, PQ), NextNeighbours), !,
  solve(AsEntries, PQ).

new_as_entries(AsEntries, PQ) :-
  target(Target), flatc(LastFlatC, Target),
  iterate(LastFlatC, FlatCList),
  maplist(flatc, FlatCList, Coords),
  maplist(new_as_entry, Coords, AsEntryList),
  AsEntries =.. [as_entries | AsEntryList],
  flatc(FlatC0, [0, 0]),
  as_reduce(AsEntries, 0, PQ, FlatC0).
new_as_entry([X, Y], Entry) :-
  target(Target),
  manhattan([X, Y], Target, H),
  Entry =.. [as_entry | [1000000000, H]], !.
as_f(Entry, F) :- as_g(Entry, G), as_h(Entry, H), F is G + H.
as_g(Entry, G) :- arg(1, Entry, G).
as_h(Entry, H) :- arg(2, Entry, H).

as_reduce(AsEntries, G, PQ, FlatC) :-
  arg(FlatC, AsEntries, Entry), as_g(Entry, OldG),
  (OldG =< G -> ! ; setarg(1, Entry, G), as_f(Entry, F), pq_put(PQ, FlatC, F)).

flatc(FlatC, [X, Y]) :- 
  target([LastX, _]),
  W is LastX + 1,
  (var(FlatC) -> FlatC is Y * W + X + 1 ; X is (FlatC - 1) mod W, Y is (FlatC - 1) // W).
manhattan([X1, Y1], [X2, Y2], Dist) :- Dist is abs(X2 - X1) + abs(Y2 - Y1).
neighbours([X, Y], N) :- !,
  Left is X - 1, Right is X + 1,
  Above is Y - 1, Below is Y + 1,
  exclude(out_of_grid, [[Left, Y], [Right, Y], [X, Above], [X, Below]], InGrid),
  exclude(obstacle, InGrid, N).
neighbours(FlatC, N) :- flatc(FlatC, [X, Y]), neighbours([X, Y], CoordsN), maplist(flatc, N, CoordsN).
out_of_grid([X, Y]) :- target([MaxX, MaxY]), (X < 0 ; X > MaxX ; Y < 0 ; Y > MaxY).
iterate(Last, L) :- findall(X, between(0, Last, X), L).

new_pq(PQ) :- ord_empty(Visited), PQ =.. [pq | [[], Visited]].
pq_put(PQ, Value, _Prio) :-
  arg(2, PQ, Visited),
  ord_memberchk(Value, Visited), !.
pq_put(PQ, Value, Prio) :-
  pq_entry(Entry, Prio, Value),
  arg(1, PQ, T),
  ord_add_element(T, Entry, NewEntries),
  setarg(1, PQ, NewEntries).
pq_next(PQ, Min) :-
  arg(1, PQ, [MinEntry | T]),
  arg(2, PQ, Visited),
  pq_entry(MinEntry, _, MinValue),
  setarg(1, PQ, T),
  (ord_memberchk(MinValue, Visited) ->
    pq_next(PQ, Min)
  ; Min is MinValue, ord_union(Visited, [MinValue], NewVisited), setarg(2, PQ, NewVisited)).

pq_entry(Entry, Prio, Value) :- Entry =.. [pq_entry | [Prio, Value]].

parse_input :-
  open('aocinput.txt', read, Fd),
  read_string(Fd, _, File),
  close(Fd),
  split_string(File, "\n", "\n", AllLines), !,
  take(1024, AllLines, Lines),
  maplist(line_fact, Lines, Facts),
  maplist(assertz, Facts).

line_fact(Line, Fact) :-
  split_string(Line, ",", " ", NumberStrings),
  maplist(number_string, [X, Y], NumberStrings),
  Fact =.. [obstacle | [[X, Y]]].

take(0, _, []).
take(_, [], []).
take(N, [First | Rest], [First | NewRest]) :- Prev is N - 1, take(Prev, Rest, NewRest).
