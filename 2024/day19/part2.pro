:- initialization(main, main).
:- dynamic(towel/1).
:- dynamic(count_solutions/2).

main :-
  read_input(Lines),
  maplist(count_solutions, Lines, Counts),
  sum_list(Counts, Result),
  write(Result), nl.

count_solutions([], 1).
count_solutions(Pattern, N) :-
  findall(Rest, (towel(Towel), prefix(Towel, Pattern, Rest)), Suffixes),
  maplist(count_solutions_once, Suffixes, Counts),
  sum_list(Counts, N),
  asserta(count_solutions(Pattern, N)).

count_solutions_once(Pattern, N) :- once(count_solutions(Pattern, N)).

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
