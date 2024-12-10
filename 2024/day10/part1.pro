:- initialization(main, main).
:- dynamic(cell/3).
:- dynamic(width/1).
:- dynamic(height/1).

main :-
  read_input(Lines), !,
  parse_grid(Lines, Goals), !,
  maplist(assertz, Goals), !,
  solve(Result), !,
  write(Result), nl.

solve(Result) :-
  width(Width),
  height(Height),
  iterate_grid(Width, Height, Coords), !,
  maplist(score, Coords, Scores), !,
  sum_list(Scores, Result).

score([X, Y], 0) :- cell(X, Y, C), C =\= 0, !.
score([X, Y], Score) :-
  cell(X, Y, C),
  C =:= 0, !,
  reach(X, Y, 0, Reaches), !,
  length(Reaches, Score).

reach(X, Y, Height, []) :- \+ cell(X, Y, Height), !.
reach(X, Y, 9, [[X, Y]]) :- cell(X, Y, 9), !.
reach(X, Y, Height, Reaches) :-
  cell(X, Y, Height),
  Height =\= 9, !,
  NextHeight is Height + 1,
  Left is X - 1,
  Right is X + 1,
  Above is Y - 1,
  Below is Y + 1,
  reach(Left, Y, NextHeight, RLeft), !,
  reach(Right, Y, NextHeight, RRight), !,
  reach(X, Above, NextHeight, RTop), !,
  reach(X, Below, NextHeight, RBot), !,
  ord_union(RLeft, RRight, RHor), !,
  ord_union(RTop, RBot, RVert), !,
  ord_union(RHor, RVert, Reaches), !.

read_input(Lines) :-
  open('aocinput.txt', read, Fd),
  read_string(Fd, _, File),
  close(Fd),
  split_string(File, "\n", "\n", Lines), !.

enclose(X, [X]).
prepend(H, T, [H | T]).
prepend_each(H, T, L) :- maplist(enclose, T, Enc), maplist(prepend(H), Enc, L).
iterate(N, L) :- Last is N - 1, findall(X, between(0, Last, X), L).
iterate_grid(W, H, L) :- LastX is W - 1, LastY is H - 1, findall([X, Y], (between(0, LastX, X), between(0, LastY, Y)), L).
string_nums(Str, Nums) :- string_codes(Str, Codes), maplist(plus(-48), Codes, Nums).

x_length([Line | _], XLen) :- length(Line, XLen).
x_index(List, XIndexedList) :-
  length(List, XLen),
  iterate(XLen, XIndices),
  maplist(prepend, XIndices, List, XIndexedList), !.

mkcells(List, GoalList) :- maplist(prepend(cell), List, CallList), maplist((=..), GoalList, CallList), !.

parse_grid(Lines, Goals) :-
  length(Lines, YLen),
  iterate(YLen, YIndices), !,
  maplist(string_nums, Lines, Nums),
  x_length(Nums, XLen),
  maplist(prepend_each, YIndices, Nums, YIndexedNums),
  maplist(x_index, YIndexedNums, XYIndexedNums),
  maplist(mkcells, XYIndexedNums, NestedGoals),
  flatten(NestedGoals, CellGoals), !,
  WidthGoal =.. [width | [XLen]],
  HeightGoal =.. [height | [YLen]], !,
  Goals = [WidthGoal | [HeightGoal | CellGoals]], !.
