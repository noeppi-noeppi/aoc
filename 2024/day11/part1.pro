:- initialization(main, main).

main :-
  read_input(Start), !,
  blink_n(25, Start, End), !,
  length(End, Result), !,
  write(Result), nl.

blink_n(0, Stones, Stones).
blink_n(N, Stones, NewStones) :-
  N =\= 0, !,
  Prev is N - 1,
  blink(Stones, NextStones), !,
  blink_n(Prev, NextStones, NewStones).

blink(Stones, NewStones) :- maplist(evolve, Stones, NestedStones), flatten(NestedStones, NewStones), !.

evolve(0, 1).
evolve(Stone, Evolution) :-
  Stone =\= 0,
  num_length(Stone, NL),
  NL mod 2 =:= 0, !,
  HalfLength is NL / 2,
  Div is 10 ^ HalfLength,
  First is Stone // Div,
  Second is Stone mod Div,
  Evolution = [First, Second], !.
evolve(Stone, Evolution) :-
  Stone =\= 0,
  num_length(Stone, NL),
  NL mod 2 =\= 0, !,
  Evolution is 2024 * Stone, !.

num_length(Number, Length) :- Length is ceil(log10(Number + 1)).

read_input(Numbers) :-
  open('aocinput.txt', read, Fd),
  read_line_to_string(Fd, Line),
  close(Fd),
  split_string(Line, " ", " ", Entries), !,
  maplist(number_string, Numbers, Entries), !.
