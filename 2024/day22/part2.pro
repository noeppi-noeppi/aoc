:- initialization(main, main).
:- dynamic(input_length/1).
:- dynamic(sequence/4).
:- dynamic(sequence/6).

main :-
  load, !,
  all_sequences(Seqs),
  maplist(profit, Seqs, Profits),
  max_list(Profits, Result),
  write(Result), nl.

load :-
  read_input(Seeds),
  length(Seeds, SeedsLen),
  asserta(input_length(SeedsLen)), !,
  numlist(1, SeedsLen, Indexes),
  maplist(assert_prices, Indexes, Seeds).

all_sequences(Seqs) :- findall(seq(A, B, C, D), sequence(A, B, C, D), Seqs).

profit(Seq, Profit) :- input_length(SeedsLen), !, profit(SeedsLen, Seq, Profit), !.
profit(0, _, 0).
profit(SeedsLen, Seq, Profit) :-
  Prev is SeedsLen - 1,
  Seq = seq(A, B, C, D),
  price(SeedsLen, A, B, C, D, Price), !,
  profit(Prev, Seq, PrevProfit), !,
  Profit is PrevProfit + Price, !.

price(Idx, A, B, C, D, Price) :- once(sequence(Idx, Price, A, B, C, D)), !.
price(Idx, A, B, C, D, 0) :- \+ sequence(Idx, _, A, B, C, D).

assert_prices(Idx, Seed) :-
  next(Seed, Last1),
  next(Last1, Last2),
  next(Last2, Last3), !,
  assert_prices(Idx, 1997, Seed, Last1, Last2, Last3).
assert_prices(_Idx, 0, _Last0, _Last1, _Last2, _Last3).
assert_prices(Idx, ItrLeft, Last0, Last1, Last2, Last3) :-
  next(Last3, Next),
  Diff1 is (Last1 mod 10) - (Last0 mod 10),
  Diff2 is (Last2 mod 10) - (Last1 mod 10),
  Diff3 is (Last3 mod 10) - (Last2 mod 10),
  Diff4 is (Next mod 10) - (Last3 mod 10),
  Price is Next mod 10,
  (sequence(Diff1, Diff2, Diff3, Diff4) -> ! ; assertz(sequence(Diff1, Diff2, Diff3, Diff4))), !,
  assertz(sequence(Idx, Price, Diff1, Diff2, Diff3, Diff4)), !,
  ItrLeftPrev is ItrLeft - 1,
  assert_prices(Idx, ItrLeftPrev, Last1, Last2, Last3, Next), !.

next(Rnd, Num) :-
  Rnd1 is (Rnd xor (Rnd << 6)) /\ 0xFFFFFF,
  Rnd2 is (Rnd1 xor (Rnd1 >> 5)) /\ 0xFFFFFF,
  Num is (Rnd2 xor (Rnd2 << 11)) /\ 0xFFFFFF, !.

read_input(Seeds) :-
  open('testinput.txt', read, Fd),
  read_string(Fd, _, File),
  close(Fd),
  split_string(File, "\n", "\n", Lines), !,
  maplist(number_string, Seeds, Lines).
