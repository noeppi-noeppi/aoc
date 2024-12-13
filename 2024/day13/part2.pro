:- initialization(main, main).
:- use_module(library(clpfd)).
:- use_module(library(simplex)).

main :-
  read_input(EntryStrings),
  maplist(parse_entry, EntryStrings, Entries),
  maplist(coordinates, Entries, Solutions),
  maplist(cost, Solutions, Costs),
  sum_list(Costs, Result), !,
  write(Result), nl.

coordinates(Entry, [A, B]) :-
  arg(1, Entry, VA),
  arg(2, Entry, VB),
  arg(3, Entry, VP),
  coordinates(VA, VB, VP, [A, B]), !.
coordinates(_, [0, 0]).
coordinates([AX, AY], [BX, BY], [PX, PY], [A, B]) :-
  gen_state(S0),
  constraint([AX * a, BX * b] = PX, S0, S1),
  constraint([AY * a, BY * b] = PY, S1, S2),
  minimize([3 * a, b], S2, S),
  variable_value(S, a, A),
  variable_value(S, b, B), !.

cost([A, B], Cost) :- whole(A), whole(B), !, A >= 0, B >= 0, !, Cost is 3 * A + B.
cost([_, _], 0).

whole(Number) :- Number =:= floor(Number).

parse_entry(EntryText, Entry) :-
  split_string(EntryText, "\n", "\n", [LineA, LineB, LineP]), !,
  split_string(LineA, ":", ":", [_, LineA1]),
  split_string(LineB, ":", ":", [_, LineB1]),
  split_string(LineP, ":", ":", [_, LineP1]), !,
  split_string(LineA1, ",", ",", [LineAX, LineAY]),
  split_string(LineB1, ",", ",", [LineBX, LineBY]),
  split_string(LineP1, ",", ",", [LinePX, LinePY]), !,
  tail_int(LineAX, "+", AX),
  tail_int(LineAY, "+", AY),
  tail_int(LineBX, "+", BX),
  tail_int(LineBY, "+", BY),
  tail_int(LinePX, "=", PX),
  tail_int(LinePY, "=", PY), !,
  PXL is 10000000000000 + PX,
  PYL is 10000000000000 + PY,
  Entry =.. [entry | [[AX, AY], [BX, BY], [PXL, PYL]]].

tail_int(String, Split, Int) :-
  split_string(String, Split, Split, [_, NumberString]),
  number_string(Int, NumberString).

read_input(Entries) :-
  open('aocinput.txt', read, Fd),
  read_string(Fd, _, File),
  close(Fd),
  re_split("\n\n", File, EntriesWithSeparators), !,
  exclude(paragraph_separator, EntriesWithSeparators, Entries), !.

paragraph_separator("\n\n").
