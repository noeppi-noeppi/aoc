:- initialization(main, main).
:- dynamic(creates/3).

main :-
  read_input(Start), !,
  maplist(creates(75), Start, End), !,
  sum_list(End, Result), !,
  write(Result), nl.

creates_once(N, Stone, New) :- once(creates(N, Stone, New)).

creates(0, _, 1).
creates(N, Stone, New) :-
  N =\= 0, !,
  Prev is N - 1,
  blink([Stone], NewStones), !,
  maplist(creates_once(Prev), NewStones, CreatesNums), !,
  sum_list(CreatesNums, New), !,
  Fact =.. [creates | [N, Stone, New]],
  asserta(Fact), !.

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
