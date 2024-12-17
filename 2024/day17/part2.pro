:- initialization(main, main).

main :-
  parse_input(Computer, ReducedComputer),
  find_quines(Computer, ReducedComputer, Quines),
  min_list(Quines, Result),
  write(Result), nl.

find_quines(Computer, ReducedComputer, Quines) :- find_quines(Computer, ReducedComputer, Quines, 0).
find_quines(Computer, ReducedComputer, Quines, Address) :-
  maxmem(Computer, Len), Address < Len, !,
  NextAddress is Address + 1,
  find_quines(Computer, ReducedComputer, PrevQuines, NextAddress),
  reg(Computer, Address, Mem),
  maplist(find_outp_args(ReducedComputer, Mem), PrevQuines, NestedNewQuines),
  ord_union(NestedNewQuines, Quines).
find_quines(_Computer, _ReducedComputer, [0], _).

find_outp_args(ReducedComputer, Outp, PrevQuine, Quines) :- find_outp_args(ReducedComputer, Outp, 0, PrevQuine, Quines).
find_outp_args(_ReducedComputer, _Outp, 8, _PrevQuine, []).
find_outp_args(ReducedComputer, Outp, N, PrevQuine, Quines) :-
  Quine is PrevQuine * 8 + N,
  run_arg(ReducedComputer, Copy, Quine),
  onlyout(Copy, Outp), !,
  Next is N + 1,
  find_outp_args(ReducedComputer, Outp, Next, PrevQuine, OtherQuines),
  ord_add_element(OtherQuines, Quine, Quines).
find_outp_args(ReducedComputer, Outp, N, PrevQuine, Quines) :- Next is N + 1, find_outp_args(ReducedComputer, Outp, Next, PrevQuine, Quines).

run_arg(Computer, Copy, Arg) :- duplicate_term(Computer, Copy), setreg(Copy, a, Arg), run(Copy).
run(Computer) :- step(Computer), !, run(Computer).
run(Computer) :- \+ step(Computer).

step(Computer) :-
  insn(Computer, OPCode),
  do(Computer, OPCode),
  next(Computer).

do(Computer, 0) :- do_dv(Computer, a). % adv
do(Computer, 1) :- % bxl
  reg(Computer, b, Arg1),
  literal(Computer, Arg2),
  Result is Arg1 xor Arg2,
  setreg(Computer, b, Result).
do(Computer, 2) :- % bst
  combo(Computer, Arg),
  mod8(Arg, Result),
  setreg(Computer, b, Result).
do(Computer, 3) :- % jnz
  reg(Computer, a, Arg),
  literal(Computer, Target),
  (Arg =:= 0 -> ! ; jump(Computer, Target)).
do(Computer, 4) :- % bxc
  reg(Computer, b, Arg1),
  reg(Computer, c, Arg2),
  Result is Arg1 xor Arg2,
  setreg(Computer, b, Result).
do(Computer, 5) :- % out
  combo(Computer, Arg),
  mod8(Arg, Arg8),
  pushout(Computer, Arg8).
do(Computer, 6) :- do_dv(Computer, b). % bdv
do(Computer, 7) :- do_dv(Computer, c). % cdv

do_dv(Computer, Target) :-
  reg(Computer, a, Num),
  combo(Computer, Exp),
  Denom is 2 ^ Exp,
  Result is Num // Denom,
  setreg(Computer, Target, Result).

next(Computer) :- reg(Computer, pc, PC), Next is PC + 2, setreg(Computer, pc, Next).
jump(Computer, Address) :- Prev is Address - 2, setreg(Computer, pc, Prev).

insn(Computer, OPCode) :- reg(Computer, pc, PC), reg(Computer, PC, OPCode).
literal(Computer, Arg) :- reg(Computer, pc, PC), Next is PC + 1, reg(Computer, Next, Arg).
combo(Computer, Arg) :- reg(Computer, pc, PC), Next is PC + 1, reg(Computer, Next, Combo), combo(Computer, Combo, Arg).
combo(_Computer, 0, 0).
combo(_Computer, 1, 1).
combo(_Computer, 2, 2).
combo(_Computer, 3, 3).
combo(Computer, 4, A) :- reg(Computer, a, A).
combo(Computer, 5, B) :- reg(Computer, b, B).
combo(Computer, 6, C) :- reg(Computer, c, C).

reg(Computer, pc, Value) :- arg(2, Computer, Value), !.
reg(Computer, a, Value) :- arg(3, Computer, Value), !.
reg(Computer, b, Value) :- arg(4, Computer, Value), !.
reg(Computer, c, Value) :- arg(5, Computer, Value), !.
reg(Computer, MemIdx, Value) :- Idx is MemIdx + 6, arg(Idx, Computer, Value).

setreg(Computer, pc, Value) :- setarg(2, Computer, Value), !.
setreg(Computer, a, Value) :- setarg(3, Computer, Value), !.
setreg(Computer, b, Value) :- setarg(4, Computer, Value), !.
setreg(Computer, c, Value) :- setarg(5, Computer, Value), !.
setreg(Computer, MemIdx, Value) :- Idx is MemIdx + 6, mod8(Value, Value8), setarg(Idx, Computer, Value8).

maxmem(Computer, MaxMem) :- functor(Computer, _, Arity), MaxMem is Arity - 5.

mod8(Value, Value8) :- Value8 is ((Value mod 8) + 8) mod 8.

pushout(Computer, Number) :-
  arg(1, Computer, OutputBuffer),
  setarg(1, Computer, [Number | OutputBuffer]).
onlyout(Computer, Number) :- arg(1, Computer, [Number]).

parse_input(Computer, ReducedComputer) :-
  open('aocinput.txt', read, Fd),
  read_string(Fd, _, File),
  close(Fd),
  split_string(File, "\n", "\n", [LineA, LineB, LineC, LineP]), !,
  line_numbers(LineA, [RegA]),
  line_numbers(LineB, [RegB]),
  line_numbers(LineC, [RegC]),
  line_numbers(LineP, Code),
  Computer =.. [computer | [[] | [0 | [ RegA | [RegB | [RegC | Code]]]]]],
  length(Code, CodeLen),
  ReducedCodeLen is CodeLen - 4,
  take(ReducedCodeLen, Code, ReducedCode),
  ReducedComputer =.. [computer | [[] | [0 | [ RegA | [RegB | [RegC | ReducedCode]]]]]].

line_numbers(Line, Numbers) :-
  split_string(Line, ":", " ", [_, NumbersPart]),
  split_string(NumbersPart, ",", " ", NumberStrings),
  maplist(number_string, Numbers, NumberStrings).
  
take(0, _, []).
take(_, [], []).
take(N, [First | Rest], [First | NewRest]) :- Prev is N - 1, take(Prev, Rest, NewRest).
