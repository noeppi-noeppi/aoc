:- initialization(main, main).
:- dynamic(cell/3).
:- dynamic(width/1).
:- dynamic(height/1).
:- dynamic(full/2).

main :-
  read_input(Lines), !,
  parse_grid(Lines, Goals), !,
  maplist(assertz, Goals), !,
  iterate_grid(Coords),
  maplist(region_fill, Coords, Areas, Perimeters), !,
  maplist(mult, AreaCosts, Areas, Perimeters),
  sum_list(AreaCosts, Result), !,
  write(Result), nl.

mult(P, A, B) :- P is A * B.

region_fill([X, Y], 0, 0) :- full(X, Y), !.
region_fill([X, Y], 0, 0) :- \+ cell(X, Y, _), !.
region_fill([X, Y], Area, Perimeter) :-
  cell(X, Y, Type),
  neighbours(X, Y, Neighbours), !,
  include(contains(Type), Neighbours, SameTypeNeighbours),
  length(SameTypeNeighbours, SameTypeNeighbourCount),
  OwnPerimeter is 4 - SameTypeNeighbourCount, !,
  asserta(full(X, Y)), !,
  maplist(region_fill, SameTypeNeighbours, NeighbourAreas, NeighbourPerimeters), !,
  sum_list(NeighbourAreas, NeighbourArea),
  sum_list(NeighbourPerimeters, NeighbourPerimeter),
  Area is 1 + NeighbourArea,
  Perimeter is OwnPerimeter + NeighbourPerimeter, !.

contains(Type, [X, Y]) :- cell(X, Y, Type).

neighbours(X, Y, Neighbours) :-
  Above is Y - 1,
  Below is Y + 1,
  Left is X - 1,
  Right is X + 1,
  Neighbours = [[X, Above], [X, Below], [Left, Y], [Right, Y]].

read_input(Lines) :-
  open('aocinput.txt', read, Fd),
  read_string(Fd, _, File),
  close(Fd),
  split_string(File, "\n", "\n", Lines), !.

enclose(X, [X]).
prepend(H, T, [H | T]).
prepend_each(H, T, L) :- maplist(enclose, T, Enc), maplist(prepend(H), Enc, L).
iterate(N, L) :- Last is N - 1, findall(X, between(0, Last, X), L).
iterate_grid(L) :- width(W), height(H), iterate_grid(W, H, L).
iterate_grid(W, H, L) :- LastX is W - 1, LastY is H - 1, findall([X, Y], (between(0, LastX, X), between(0, LastY, Y)), L).

x_length([Line | _], XLen) :- length(Line, XLen).
x_index(List, XIndexedList) :-
  length(List, XLen),
  iterate(XLen, XIndices),
  maplist(prepend, XIndices, List, XIndexedList), !.

mkcells(List, GoalList) :- maplist(prepend(cell), List, CallList), maplist((=..), GoalList, CallList), !.

parse_grid(Lines, Goals) :-
  length(Lines, YLen),
  iterate(YLen, YIndices), !,
  maplist(string_codes, Lines, Codes),
  x_length(Codes, XLen),
  maplist(prepend_each, YIndices, Codes, YIndexedCodes),
  maplist(x_index, YIndexedCodes, XYIndexedCodes),
  maplist(mkcells, XYIndexedCodes, NestedGoals),
  flatten(NestedGoals, CellGoals), !,
  WidthGoal =.. [width | [XLen]],
  HeightGoal =.. [height | [YLen]], !,
  Goals = [WidthGoal | [HeightGoal | CellGoals]], !.
