:- initialization(main, main).
:- dynamic(towel/1).

main :-
  read_input(Lines),
  exclude(can_solve, Lines, Unsolvable),
  length(Lines, Len),
  length(Unsolvable, UnsolvableLen),
  Result is Len - UnsolvableLen,
  write(Result), nl.

can_solve([]).
can_solve(Pattern) :-
  towel(Towel),
  prefix(Towel, Pattern, Rest),
  can_solve(Rest).

prefix([], L, L).
prefix([H | TP], [H | TL], Rest) :- prefix(TP, TL, Rest).

read_input(Patterns) :-
  open('aocinput.txt', read, Fd),
  read_string(Fd, _, File),
  close(Fd),
  split_string(File, "\n", "\n", [First | PatternLines]), !,
  split_string(First, ",", " ", Towels), !,
  maplist(towel_fact, Towels, TowelFacts), !,
  maplist(assertz, TowelFacts),
  maplist(string_codes, PatternLines, Patterns).

towel_fact(Towel, Fact) :-
  string_codes(Towel, Codes),
  Fact =.. [towel | [Codes]].
