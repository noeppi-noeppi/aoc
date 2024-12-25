:- initialization(main, main).
:- use_module(library(clpfd)).
:- dynamic(key/1).
:- dynamic(lock/1).

main :-
  load,
  findall([Key, Lock], (key(Key), lock(Lock), matches(Key, Lock)), Results),
  length(Results, Result),
  write(Result), nl.

matches(Key, Lock) :- maplist(l7, Key, Lock).
l7(A, B) :- R is A + B, R =< 7.

load :-
  open('aocinput.txt', read, Fd),
  read_string(Fd, _, File),
  close(Fd),
  re_split("\n\n", File, Parts), !,
  itr_parts(Parts), !.

itr_parts([Part]) :- assert_part(Part).
itr_parts([Part | ["\n\n" | T]]) :- assert_part(Part), !, itr_parts(T).

assert_part(Part) :-
  split_string(Part, "\n", "\n", Lines),
  maplist(string_codes, Lines, CodesT),
  transpose(CodesT, Codes),
  maplist(reverse, Codes, CodesR),
  (assert_codes(lock, Codes) ; assert_codes(key, CodesR)).

assert_codes(Functor, Codes) :-
  maplist(count_height, Codes, Nums),
  maplist(nz, Nums), !,
  Fact =.. [Functor | [Nums]],
  assertz(Fact).

count_height([], 0).
count_height([46 | _], 0).
count_height([35 | T], N) :- count_height(T, NN), N is NN + 1.

nz(N) :- N =\= 0.
