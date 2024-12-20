:- initialization(main, main).
:- dynamic(cell/3).
:- dynamic(width/1).
:- dynamic(height/1).
:- dynamic(distance/2).

main :-
  load,
  iterate_path(Path),
  maplist(find_cheats, Path, NestedCheats),
  flatten(NestedCheats, Cheats),
  length(Cheats, Result),
  write(Result), nl.

path([X, Y]) :- distance([X, Y], _).
iterate_path(Path) :- findall(X, path(X), Path).

not_path([X, Y]) :- \+ path([X, Y]).
not_back_to(From, [X, Y]) :- From \= [X, Y], not_path([X, Y]).

find_cheats(From, Cheats) :-
  offsets(From, Offsets),
  exclude(path, Offsets, Walls),
  maplist(find_cheats(From), NestedCheats, Walls),
  flatten(NestedCheats, Cheats).
find_cheats(From, Cheats, SkipInto) :-
  offsets(SkipInto, Offsets),
  exclude(not_back_to(From), Offsets, SkipTargets),
  maplist(cheat_value(From), SkipTargets, CheatValues),
  exclude(irrelevant, CheatValues, Cheats).

cheat_value(From, To, Value) :-
  distance(From, FD), distance(To, TD),
  Value is TD - FD - 2.

irrelevant(X) :- X < 100.

load :-
  read_input(Lines),
  parse_grid(Lines, Goals, Start, End),
  maplist(asserta, Goals),
  assertz(distance(End, 0)),
  travel_back(Start, End, 0).

travel_back(Previous, From, _Distance) :- neighbours(From, [Previous]), !.
travel_back(_Previous, From, Distance) :- neighbours(From, [Next]), !, NextDist is Distance + 1, assertz(distance(Next, NextDist)), !, travel_back(From, Next, NextDist).
travel_back(Previous, From, Distance) :- neighbours(From, [Next, Previous]), !, NextDist is Distance + 1, assertz(distance(Next, NextDist)), !, travel_back(From, Next, NextDist).
travel_back(Previous, From, Distance) :- neighbours(From, [Previous, Next]), !, NextDist is Distance + 1, assertz(distance(Next, NextDist)), !, travel_back(From, Next, NextDist).

offset([OX, OY], east, [NX, NY]) :- NX is OX + 1, NY is OY.
offset([OX, OY], north, [NX, NY]) :- NX is OX, NY is OY - 1.
offset([OX, OY], west, [NX, NY]) :- NX is OX - 1, NY is OY.
offset([OX, OY], south, [NX, NY]) :- NX is OX, NY is OY + 1.

offsets([X, Y], [East, North, West, South]) :-
  offset([X, Y], east, East),
  offset([X, Y], north, North),
  offset([X, Y], west, West),
  offset([X, Y], south, South).

neighbours([X, Y], Neighbours) :- offsets([X, Y], Offsets), exclude(obstructed, Offsets, Neighbours).
neighbours([X, Y], Neighbours) :- offsets([X, Y], Offsets), exclude(obstructed, Offsets, Neighbours).
obstructed([X, Y]) :- width(W), height(H), (X < 0 ; X >= W ; Y < 0 ; Y >= H ; cell(X, Y, wall)).

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
