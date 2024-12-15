:- initialization(main, main).

main :-
  read_input(Robots),
  maplist(move(100), Robots),
  count_in_quadrant(0, Robots, Q0),
  count_in_quadrant(1, Robots, Q1),
  count_in_quadrant(2, Robots, Q2),
  count_in_quadrant(3, Robots, Q3),
  Result is Q0 * Q1 * Q2 * Q3,
  write(Result), nl.

move(N, Robot) :-
  arg(1, Robot, [X, Y]),
  arg(2, Robot, [DX, DY]),
  width(W), height(H),
  NX is (X + N * DX) mod W,
  NY is (Y + N * DY) mod H,
  setarg(1, Robot, [NX, NY]).

count_in_quadrant(Q, Robots, Amount) :-
  exclude(outside_quadrant(Q), Robots, RelevantRobots),
  length(RelevantRobots, Amount).

outside_quadrant(Q, Robot) :- arg(1, Robot, [X, Y]), \+ quadrant([X, Y], Q).

quadrant([X, Y], Q) :-
  width(W), height(H),
  XT is W // 2, YT is H // 2,
  quadrant(XT, YT, [X, Y], Q).
quadrant(XT, YT, [X, Y], Q) :- X < XT, Y < YT, Q is 2.
quadrant(XT, YT, [X, Y], Q) :- X < XT, Y > YT, Q is 1.
quadrant(XT, YT, [X, Y], Q) :- X > XT, Y < YT, Q is 3.
quadrant(XT, YT, [X, Y], Q) :- X > XT, Y > YT, Q is 0.

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
