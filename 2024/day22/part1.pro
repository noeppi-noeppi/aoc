:- initialization(main, main).

main :-
  read_input(Seeds),
  maplist(next(2000), Seeds, Numbers),
  sum_list(Numbers, Result),
  write(Result), nl.

next(0, Seed, Seed).
next(N, Seed, Num) :-
  Prev is N - 1, next(Prev, Seed, Rnd), !,
  Rnd1 is (Rnd xor (Rnd << 6)) /\ 0xFFFFFF,
  Rnd2 is (Rnd1 xor (Rnd1 >> 5)) /\ 0xFFFFFF,
  Num is (Rnd2 xor (Rnd2 << 11)) /\ 0xFFFFFF, !.

read_input(Seeds) :-
  open('aocinput.txt', read, Fd),
  read_string(Fd, _, File),
  close(Fd),
  split_string(File, "\n", "\n", Lines), !,
  maplist(number_string, Seeds, Lines).
