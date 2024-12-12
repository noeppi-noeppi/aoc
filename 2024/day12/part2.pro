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
  maplist(region_fill, Coords, Areas, Fences), !,
  maplist(unify_all, Fences, UnifiedFences),
  maplist(length, UnifiedFences, Perimeters),
  maplist(mult, AreaCosts, Areas, Perimeters),
  sum_list(AreaCosts, Result), !,
  write(Result), nl.

mult(P, A, B) :- P is A * B.

unify_all(Fences, NewFences) :- unify_all(Fences, Fences, NewFences).
unify_all([], _, []).
unify_all([Fence | Rest], AllFences, NewFences) :- unify_with_first(Fence, Rest, AllFences, FencesUnifiedOnce), !, unify_all(FencesUnifiedOnce, AllFences, NewFences).
unify_all([Fence | Rest], AllFences, [Fence | NewRest]) :- !, unify_all(Rest, AllFences, NewRest), !.

unify_with_first(Fence, [FirstOther | RestOther], AllFences, [NewFence | RestOther]) :- unify(Fence, FirstOther, AllFences, NewFence), !.
unify_with_first(Fence, [FirstOther | RestOther], AllFences, [FirstOther | NewRest]) :- !, unify_with_first(Fence, RestOther, AllFences, NewRest), !.

unify(FenceA, FenceB, AllFences, Fence) :- unify1(FenceA, FenceB, AllFences, Fence), !.
unify(FenceA, FenceB, AllFences, Fence) :- unify1(FenceB, FenceA, AllFences, Fence), !.

unify1(FenceA, FenceB, AllFences, Fence) :-
  arg(1, FenceA, Start),
  arg(2, FenceA, [FJX1, FJY1]),
  arg(1, FenceB, [FJX2, FJY2]),
  arg(2, FenceB, End),
  FJX1 =:= FJX2, FJY1 =:= FJY2, !,
  unify1(Start, [FJX1, FJY1], End, AllFences, Fence), !.
unify1(FenceA, FenceB, AllFences, Fence) :-
  arg(1, FenceA, Start),
  arg(2, FenceA, [FJX1, FJY1]),
  arg(1, FenceB, End),
  arg(2, FenceB, [FJX2, FJY2]),
  FJX1 =:= FJX2, FJY1 =:= FJY2, !,
  unify1(Start, [FJX1, FJY1], End, AllFences, Fence), !.
  
unify1([FSX, FSY], [FJX, FJY], [FEX, FEY], AllFences, Fence) :-
  FSX =:= FJX, FJX =:= FEX, ((FSY < FJY, FEY > FJY) ; (FSY > FJY, FEY < FJY)), !,
  Left is FJX - 1,
  Right is FJX + 1,
  SubFenceLeft =.. [fence | [[FJX, FJY], [Left, FJY]]],
  SubFenceRight =.. [fence | [[FJX, FJY], [Right, FJY]]], !,
  has_no_subfence(AllFences, SubFenceLeft), !,
  has_no_subfence(AllFences, SubFenceRight), !,
  Fence =.. [fence | [[FSX, FSY], [FEX, FEY]]], !.
unify1([FSX, FSY], [FJX, FJY], [FEX, FEY], AllFences, Fence) :-
  FSY =:= FJY, FJY =:= FEY, ((FSX < FJX, FEX > FJX) ; (FSX > FJX, FEX < FJX)), !,
  Above is FJY - 1,
  Below is FJY + 1,
  SubFenceAbove =.. [fence | [[FJX, FJY], [FJX, Above]]],
  SubFenceBelow =.. [fence | [[FJX, FJY], [FJX, Below]]], !,
  has_no_subfence(AllFences, SubFenceAbove), !,
  has_no_subfence(AllFences, SubFenceBelow), !,
  Fence =.. [fence | [[FSX, FSY], [FEX, FEY]]], !.

has_no_subfence([], _).
has_no_subfence([Fence | Rest], SubFence) :- \+ subfence(Fence, SubFence), !, has_no_subfence(Rest, SubFence), !.

subfence(Fence, SubFence) :-
  arg(1, Fence, [FSX, FSY]),
  arg(2, Fence, [FEX, FEY]),
  arg(1, SubFence, [SFSX, SFSY]),
  arg(2, SubFence, [SFEX, SFEY]), !,
  (
      (FSX =:= FEX, SFSX =:= SFEX, FSX =:= SFSX, (
            (FSY =< SFSY, FSY =< SFEY, FEY >= SFSY, FEY >= SFEY)
          ; (FEY =< SFSY, FEY =< SFEY, FSY >= SFSY, FSY >= SFEY)
      ))
    ; (FSY =:= FEY, SFSY =:= SFEY, FSY =:= SFSY, (
            (FSX =< SFSX, FSX =< SFEX, FEX >= SFSX, FEX >= SFEX)
          ; (FEX =< SFSX, FEX =< SFEX, FSX >= SFSX, FSX >= SFEX)
      ))
  ), !.

region_fill([X, Y], 0, []) :- full(X, Y), !.
region_fill([X, Y], 0, []) :- \+ cell(X, Y, _), !.
region_fill([X, Y], Area, Fences) :-
  cell(X, Y, Type),
  neighbours(X, Y, Neighbours), !,
  include(contains(Type), Neighbours, SameTypeNeighbours),
  own_fences(X, Y, OwnFences), !,
  asserta(full(X, Y)), !,
  maplist(region_fill, SameTypeNeighbours, NeighbourAreas, NeighbourFences), !,
  sum_list(NeighbourAreas, NeighbourArea),
  flatten([OwnFences, NeighbourFences], Fences),
  Area is 1 + NeighbourArea, !.

own_fences(X, Y, []) :- \+ cell(X, Y, _), !.
own_fences(X, Y, Fences) :-
  cell(X, Y, Type), !,
  Above is Y - 1,
  Below is Y + 1,
  Left is X - 1,
  Right is X + 1,
  fence_opt(Type, X, Above, [X, Y], [Right, Y], FencesT), !,
  fence_opt(Type, X, Below, [X, Below], [Right, Below], FencesB), !,
  fence_opt(Type, Left, Y, [X, Y], [X, Below], FencesL), !,
  fence_opt(Type, Right, Y, [Right, Y], [Right, Below], FencesR), !,
  flatten([FencesT, FencesB, FencesL, FencesR], Fences), !.
  
fence_opt(OwnType, OX, OY, [_, _], [_, _], []) :- contains(OwnType, [OX, OY]), !.
fence_opt(OwnType, OX, OY, [X1, Y1], [X2, Y2], Fences) :-
  \+ contains(OwnType, [OX, OY]), !,
  fence([X1, Y1], [X2, Y2], Fence),
  Fences = [Fence], !.
fence([X1, Y1], [X2, Y2], Fence) :- Fence =.. [fence | [[X1, Y1], [X2, Y2]]].

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
