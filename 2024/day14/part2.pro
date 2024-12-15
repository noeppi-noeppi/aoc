:- initialization(main, main).
:- dynamic(robot_at/2).

main :-
  read_input(Robots),
  find(Robots, Result),
  write(Result), nl.

find(Robots, Result) :- find(0, Robots, Result).
find(N, Robots, Result) :- test(N, Robots), !, Result is N.
find(N, Robots, Result) :- Next is N + 1, !, find(Next, Robots, Result), !.

test(N, Robots) :-
  maplist(move(N), Robots), !,
  has_frame(N).

move(N, Robot) :-
  arg(1, Robot, [X, Y]),
  arg(2, Robot, [DX, DY]),
  width(W), height(H),
  NX is (X + N * DX) mod W,
  NY is (Y + N * DY) mod H,
  Fact =.. [robot_at | [N, [NX, NY]]],
  asserta(Fact), !.

has_frame(N) :-
  width(W), height(H),
  XE is W - 31, YE is H - 33, !,
  has_frame(N, [XE, YE], XE).
has_frame(N, [X, Y], _) :- has_frame_at(N, [X, Y]), !.
has_frame(N, [0, Y], XM) :-
  Y =\= 0, !,
  Prev is Y - 1, !,
  has_frame(N, [XM, Prev], XM), !.
has_frame(N, [X, Y], XM) :-
  X =\= 0, Y =\= 0, !,
  Prev is X - 1, !,
  has_frame(N, [Prev, Y], XM), !.

has_frame_at(N, [XS, YS]) :-
  XE is XS + 30, YE is YS + 32, !,
  has_x_segment(N, [XS, XE], YS), !,
  has_x_segment(N, [XS, XE], YE), !,
  has_y_segment(N, XS, [YS, YE]), !,
  has_y_segment(N, XE, [YS, YE]), !.

has_x_segment(N, [X, X], Y) :- robot_at(N, [X, Y]), !.
has_x_segment(N, [XS, XE], Y) :-
  XS =\= XE, !,
  robot_at(N, [XS, Y]),
  XN is XS + 1, !,
  has_x_segment(N, [XN, XE], Y), !.
  
has_y_segment(N, X, [Y, Y]) :- robot_at(N, [X, Y]), !.
has_y_segment(N, X, [YS, YE]) :-
  YS =\= YE, !,
  robot_at(N, [X, YS]),
  YN is YS + 1, !,
  has_y_segment(N, X, [YN, YE]), !.

width(101).
height(103).

read_input(Robots) :-
  open('aocinput.txt', read, Fd),
  read_string(Fd, _, File),
  close(Fd),
  split_string(File, "\n", "\n", Lines), !,
  maplist(line_robot, Lines, Robots).
  
line_robot(Line, Entry) :-
  split_string(Line, " ", " ", [PositionAssignment, VelocityAssignment]),
  assignment_coords(PositionAssignment, Position),
  assignment_coords(VelocityAssignment, Velocity),
  Entry =.. [robot | [Position, Velocity]].

assignment_coords(Assignment, [X, Y]) :-
  split_string(Assignment, "=", "=", [_, String]),
  string_coords(String, [X, Y]).

string_coords(String, [X, Y]) :-
  split_string(String, ",", ",", [XS, YS]),
  number_string(X, XS),
  number_string(Y, YS).
