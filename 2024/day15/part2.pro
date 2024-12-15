:- initialization(main, main).
:- use_module(library(clpfd)).

main :-
  parse_input(Boxes, Moves, Robot),
  move_sequence(Boxes, Moves, Robot),
  gps_sum(Boxes, Result),
  write(Result), nl.

move_sequence(_Boxes, [], _Robot).
move_sequence(Boxes, [Dir | Moves], Robot) :-
  try_move(Boxes, Robot, Dir, NewRobot), !,
  move_sequence(Boxes, Moves, NewRobot), !.

try_move(Boxes, Robot, Dir, NewRobot) :-
  move(Boxes, Robot, Dir), !, offset(Robot, Dir, NewRobot).
try_move(_Boxes, Robot, _Dir, Robot).

offset([OX, OY], up, [NX, NY]) :- NX #= OX, NY #= OY - 1.
offset([OX, OY], down, [NX, NY]) :- NX #= OX, NY #= OY + 1.
offset([OX, OY], left, [NX, NY]) :- NX #= OX - 1, NY #= OY.
offset([OX, OY], right, [NX, NY]) :- NX #= OX + 1, NY #= OY.

move(Boxes, Source, Dir) :-
  (Dir = up ; Dir = down),
  cell(Boxes, Source, left), !,
  push(Boxes, Source, Dir),
  offset(Source, right, Source2),
  push(Boxes, Source2, Dir).
move(Boxes, Source, Dir) :-
  (Dir = up ; Dir = down),
  cell(Boxes, Source, right), !,
  push(Boxes, Source, Dir),
  offset(Source, left, Source2),
  push(Boxes, Source2, Dir).
move(Boxes, Source, Dir) :- push(Boxes, Source, Dir).

push(Boxes, Source, Dir) :- offset(Source, Dir, Target), push(Boxes, Source, Dir, Target).
push(Boxes, Source, _Dir, Target) :-
  cell(Boxes, Target, space), !, 
  cell(Boxes, Source, Cell),
  setcell(Boxes, Source, space),
  setcell(Boxes, Target, Cell).
push(Boxes, Source, Dir, Target) :-
  (cell(Boxes, Target, left) ; cell(Boxes, Target, right)), !,
  move(Boxes, Target, Dir), !,
  cell(Boxes, Source, Cell),
  setcell(Boxes, Source, space),
  setcell(Boxes, Target, Cell).

gps_sum(Boxes, Sum) :- Boxes =.. [boxes | List], gps_sum_list(0, List, Sum).
gps_sum_list(_GPS, [], 0).
gps_sum_list(GPS, [left | Boxes], Sum) :- NextGPS is GPS + 1, gps_sum_list(NextGPS, Boxes, ContSum), Sum is ContSum + GPS.
gps_sum_list(GPS, [First | Boxes], Sum) :- First \= left, !, NextGPS is GPS + 1, gps_sum_list(NextGPS, Boxes, Sum).

gps_coords(GPS, [X, Y]) :- (var(GPS) -> GPS is X + 100 * Y ; X is GPS mod 100, Y is GPS // 100).
cell(Boxes, [X, Y], Box) :- gps_coords(GPS, [X, Y]), Idx is GPS + 1, arg(Idx, Boxes, Box).
setcell(Boxes, [X, Y], Box) :- gps_coords(GPS, [X, Y]), Idx is GPS + 1, setarg(Idx, Boxes, Box).

parse_input(Boxes, Moves, Robot) :-
  open('aocinput.txt', read, Fd),
  read_string(Fd, _, File),
  close(Fd),
  re_split("\n\n", File, [GridText, "\n\n", MovesText]), !,
  split_string(GridText, "\n", "\n", BoxesLines), !,
  make_boxes_list(BoxesLines, BoxesList), !,
  Boxes =.. [boxes | BoxesList], !,
  robot_location(BoxesLines, Robot), !,
  string_codes(MovesText, MoveCodes),
  map_move_codes(MoveCodes, Moves), !.

make_boxes_list([], []).
make_boxes_list([L | LS], B) :- make_boxes_line(L, BS), !, make_boxes_list(LS, BSS), !, append(BS, BSS, B) , !.

make_boxes_line(Line, Boxes) :-
  string_codes(Line, Codes),
  length(Codes, Len),
  Remaining is 100 - 2 * Len,
  length(Unknowns, Remaining),
  maplist(void, Unknowns, Nothings),
  maplist(box_codes, FirstBoxesNested, Codes),
  flatten(FirstBoxesNested, FirstBoxes),
  append(FirstBoxes, Nothings, Boxes), !.

box_codes([wall, wall], 35).   % #
box_codes([space, space], 46). % .
box_codes([left, right], 79).  % O
box_codes([space, space], 64). % @

robot_location([L | _], [RX, 0]) :- sub_string(L, StrIdx, _, _, "@"), !, RX is StrIdx * 2.
robot_location([_ | LS], [RX, RY]) :- robot_location(LS, [RX, PrevRY]), RY is PrevRY + 1.

map_move_codes([], []).
map_move_codes([94 | CS], [M | MS]) :- M = up, !, map_move_codes(CS, MS), !.    % ^
map_move_codes([118 | CS], [M | MS]) :- M = down, !, map_move_codes(CS, MS), !. % v
map_move_codes([60 | CS], [M | MS]) :- M = left, !, map_move_codes(CS, MS), !.  % <
map_move_codes([62 | CS], [M | MS]) :- M = right, !, map_move_codes(CS, MS), !. % >
map_move_codes([_ | CS], MS) :- map_move_codes(CS, MS), !.

void(_, nothing).
