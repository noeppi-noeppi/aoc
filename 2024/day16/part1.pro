:- initialization(main, main).
:- dynamic(cell/3).
:- dynamic(width/1).
:- dynamic(height/1).
:- dynamic(end_flatc/1).

main :-
  load(Start, End), !,
  new_pq(PQ),
  flatc(StartFlatC, Start, east),
  pq_put(PQ, StartFlatC, 0),
  new_state_space(Space),
  decrease(Space, Start, east, 0, _),
  solve(Space, PQ),
  value(Space, End, east, VE),
  value(Space, End, north, VN),
  value(Space, End, west, VW),
  value(Space, End, south, VS),
  min_list([VE, VN, VW, VS], Result),
  write(Result), nl.

load(Start, End) :-
  read_input(Lines),
  parse_grid(Lines, Goals, Start, End),
  maplist(asserta, Goals),
  flatc(FlatCEE, End, east),
  flatc(FlatCEN, End, north),
  flatc(FlatCEW, End, west),
  flatc(FlatCES, End, south),
  assertz(end_flatc(FlatCEE)),
  assertz(end_flatc(FlatCEN)),
  assertz(end_flatc(FlatCEW)),
  assertz(end_flatc(FlatCES)).

solve(_Space, PQ) :- \+ pq_next(PQ, _), !.
solve(Space, PQ) :-
  pq_next(PQ, Next),
  flatc(Next, [NextX, NextY], _),
  cell(NextX, NextY, space), !,
  state_neighbours(Next, N),
  solve_itr(Space, PQ, Next, N), !,
  (end_flatc(Next) -> ! ; solve(Space, PQ)), !.
solve(Space, PQ) :-
  pq_next(PQ, Next),
  flatc(Next, [NextX, NextY], _),
  cell(NextX, NextY, wall), !,
  solve(Space, PQ), !.
  
solve_itr(_Space, _PQ, _FromFlatC, []).
solve_itr(Space, PQ, FromFlatC, [[FlatC, Penalty] | T]) :-
  flatc(FromFlatC, [OX, OY], ODir),
  value(Space, [OX, OY], ODir, OValue),
  flatc(FlatC, [X, Y], Dir),
  NV is OValue + Penalty,
  decrease(Space, [X, Y], Dir, NV, CMP),
  (CMP =:= 1 -> pq_put(PQ, FlatC, NV) ; repeat),
  solve_itr(Space, PQ, FromFlatC, T).

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

iterate_flatc(L) :- state_space_len(Len), Last is Len - 1, findall(FlatC, (between(0, Last, FlatC)), L).

new_state_space(Space) :-
  state_space_len(Len),
  length(Unknowns, Len),
  maplist(always(1000000000000), Unknowns, Initial),
  Space =.. [space | Initial].

value(Space, [X, Y], Dir, Value) :-
  flatc(FlatC, [X, Y], Dir),
  arg(FlatC, Space, Value).
decrease(Space, [X, Y], Dir, Value, Decreased) :-
  flatc(FlatC, [X, Y], Dir),
  arg(FlatC, Space, OldValue),
  (Value < OldValue -> setarg(FlatC, Space, Value), Decreased is 1 ; Decreased is 0).

state_neighbours(FlatC, [[NFlatC, 1] | RN]) :-
  flatc(FlatC, [X, Y], Dir),
  cell(X, Y, space), !,
  offset([X, Y], Dir, [NX, NY]),
  flatc(NFlatC, [NX, NY], Dir),
  rot_neighbours(FlatC, RN).
state_neighbours(FlatC, N) :-
  flatc(FlatC, [X, Y], _),
  cell(X, Y, wall), !,
  rot_neighbours(FlatC, N).

rot_neighbours(FlatC, [[FlatCP, 1000], [FlatCM, 1000]]) :- 
  flatc(FlatC, [X, Y], Dir),
  flatd(D0, Dir),
  DP is (D0 + 1) mod 4,
  DM is (D0 + 3) mod 4,
  flatd(DP, DirP),
  flatd(DM, DirM),
  flatc(FlatCP, [X, Y], DirP),
  flatc(FlatCM, [X, Y], DirM).

state_space_len(Len) :- width(W), height(H), LastX is W - 1, LastY is H - 1, flatc(Len, [LastX, LastY], south).
flatc(FlatC, [X, Y], Dir) :-
  width(W),
  height(H),
  (var(FlatC) -> 
    flatd(DirIdx, Dir), FlatC is DirIdx * W * H + Y * W + X + 1
  ; X is (FlatC - 1) mod W, Y is ((FlatC - 1) // W) mod H, DirIdx is (FlatC - 1) // (W * H), flatd(DirIdx, Dir)).
flatd(0, east).
flatd(1, north).
flatd(2, west).
flatd(3, south).

offset([OX, OY], east, [NX, NY]) :- NX is OX + 1, NY is OY.
offset([OX, OY], north, [NX, NY]) :- NX is OX, NY is OY - 1.
offset([OX, OY], west, [NX, NY]) :- NX is OX - 1, NY is OY.
offset([OX, OY], south, [NX, NY]) :- NX is OX, NY is OY + 1.

read_input(Lines) :-
  open('aocinput.txt', read, Fd),
  read_string(Fd, _, File),
  close(Fd),
  split_string(File, "\n", "\n", Lines), !.

enclose(X, [X]).
prepend(H, T, [H | T]).
prepend_each(H, T, L) :- maplist(enclose, T, Enc), maplist(prepend(H), Enc, L).
iterate(N, L) :- Last is N - 1, findall(X, between(0, Last, X), L).

x_length([Line | _], XLen) :- length(Line, XLen).
x_index(List, XIndexedList) :-
  length(List, XLen),
  iterate(XLen, XIndices),
  maplist(prepend, XIndices, List, XIndexedList), !.

code_entry(35, wall).  % #
code_entry(46, space). % .
code_entry(83, space). % S
code_entry(69, space). % E
string_entries(String, Entries) :- string_codes(String, Codes), maplist(code_entry, Codes, Entries).
mkcells(List, GoalList) :- maplist(prepend(cell), List, CallList), maplist((=..), GoalList, CallList), !.

find_in_lines(SubStr, [L | _], [RX, 0]) :- sub_string(L, RX, _, _, SubStr), !.
find_in_lines(SubStr, [_ | LS], [RX, RY]) :- find_in_lines(SubStr, LS, [RX, PrevRY]), RY is PrevRY + 1.

parse_grid(Lines, Goals, Start, End) :-
  length(Lines, YLen),
  iterate(YLen, YIndices), !,
  find_in_lines("S", Lines, Start),
  find_in_lines("E", Lines, End),
  maplist(string_entries, Lines, Codes),
  x_length(Codes, XLen),
  maplist(prepend_each, YIndices, Codes, YIndexedCodes),
  maplist(x_index, YIndexedCodes, XYIndexedCodes),
  maplist(mkcells, XYIndexedCodes, NestedGoals),
  flatten(NestedGoals, CellGoals), !,
  WidthGoal =.. [width | [XLen]],
  HeightGoal =.. [height | [YLen]], !,
  Goals = [WidthGoal | [HeightGoal | CellGoals]], !.

always(X, _, X).
