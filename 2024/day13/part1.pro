:- initialization(main, main).
:- use_module(library(clpfd)).

main :-
  read_input(EntryStrings),
  maplist(parse_entry, EntryStrings, Entries),
  maplist(min_solution, Entries, Costs),
  sum_list(Costs, Result), !,
  write(Result), nl.

min_solution(Entry, Cost) :-
  findall(X, between(0, 100, X), Range),
  exclude(no_solution(Entry), Range, PossibleA),
  maplist(is_solution(Entry), PossibleA, PossibleB),
  maplist(cost, PossibleA, PossibleB, Costs),
  min_list(Costs, Cost), !.
min_solution(_, 0).

cost(PressA, PressB, Cost) :- Cost is 3 * PressA + PressB.

no_solution(Entry, PressA) :- \+ (is_solution(Entry, PressA, PressB), PressB =< 100).

is_solution(Entry, PressA, PressB) :-
  arg(1, Entry, [AX, AY]),
  arg(2, Entry, [BX, BY]),
  arg(3, Entry, [PX, PY]),
  PressA * AX + PressB * BX #= PX,
  PressA * AY + PressB * BY #= PY.

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
  Entry =.. [entry | [[AX, AY], [BX, BY], [PX, PY]]].

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
