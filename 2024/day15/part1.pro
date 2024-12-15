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

move(Boxes, Robot, up) :- move(Boxes, Robot, 0, -1).
move(Boxes, Robot, down) :- move(Boxes, Robot, 0, 1).
move(Boxes, Robot, left) :- move(Boxes, Robot, -1, 0).
move(Boxes, Robot, right) :- move(Boxes, Robot, 1, 0).
move(Boxes, [RX, RY], DX, DY) :-
  SX is RX + DX, SY is RY + DY,
  cell(Boxes, [SX, SY], space).
move(Boxes, [RX, RY], DX, DY) :-
  SX is RX + DX, SY is RY + DY,
  cell(Boxes, [SX, SY], box),
  push(Boxes, SX, SY, DX, DY), !,
  setcell(Boxes, [SX, SY], space), !.

push(Boxes, SX, SY, DX, DY) :- TX is SX + DX, TY is SY + DY, push(Boxes, SX, SY, DX, DY, TX, TY).
push(Boxes, _SX, _SY, _DX, _DY, TX, TY) :- cell(Boxes, [TX, TY], space), !, setcell(Boxes, [TX, TY], box).
push(Boxes, _SX, _SY, DX, DY, TX, TY) :-
  cell(Boxes, [TX, TY], box), !,
  push(Boxes, TX, TY, DX, DY), !,
  setcell(Boxes, [TX, TY], box).

gps_sum(Boxes, Sum) :- Boxes =.. [boxes | List], gps_sum_list(0, List, Sum).
gps_sum_list(_GPS, [], 0).
gps_sum_list(GPS, [box | Boxes], Sum) :- NextGPS is GPS + 1, gps_sum_list(NextGPS, Boxes, ContSum), Sum is ContSum + GPS.
gps_sum_list(GPS, [First | Boxes], Sum) :- First \= box, !, NextGPS is GPS + 1, gps_sum_list(NextGPS, Boxes, Sum).

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
  Remaining is 100 - Len,
  length(Unknowns, Remaining),
  maplist(void, Unknowns, Nothings),
  maplist(box_code, FirstBoxes, Codes),
  append(FirstBoxes, Nothings, Boxes), !.

box_code(wall, 35).  % #
box_code(space, 46). % .
box_code(box, 79).   % O
box_code(space, 64). % @

robot_location([L | _], [RX, 0]) :- sub_string(L, RX, _, _, "@"), !.
robot_location([_ | LS], [RX, RY]) :- robot_location(LS, [RX, PrevRY]), RY is PrevRY + 1.

map_move_codes([], []).
map_move_codes([94 | CS], [M | MS]) :- M = up, !, map_move_codes(CS, MS), !.    % ^
map_move_codes([118 | CS], [M | MS]) :- M = down, !, map_move_codes(CS, MS), !. % v
map_move_codes([60 | CS], [M | MS]) :- M = left, !, map_move_codes(CS, MS), !.  % <
map_move_codes([62 | CS], [M | MS]) :- M = right, !, map_move_codes(CS, MS), !. % >
map_move_codes([_ | CS], MS) :- map_move_codes(CS, MS), !.

void(_, nothing).
