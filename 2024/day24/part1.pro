:- initialization(main, main).
:- dynamic(wires/2).
:- dynamic(state/2).
:- dynamic(g_and/3).
:- dynamic(g_or/3).
:- dynamic(g_xor/3).

main :-
  load,
  wires(AllWires),
  exclude(irrelevant, AllWires, Wires),
  list_to_ord_set(Wires, SortedWires),
  assemble(SortedWires, Result),
  write(Result), nl.

assemble([], 0).
assemble([H | T], Result) :- state(H, on), !, assemble(T, PrevResult), Result is 2 * PrevResult + 1.
assemble([H | T], Result) :- state(H, off), !, assemble(T, PrevResult), Result is 2 * PrevResult.

irrelevant(Wire) :- \+ string_codes(Wire, [122 | _]).

state1(Wire, State) :- once(state(Wire, State)).

state(Wire, on) :- g_and(A, B, Wire), state1(A, on), state1(B, on), !, asserta(state(Wire, on)), !.
state(Wire, on) :- g_or(A, B, Wire), (state1(A, on) ; state1(B, on)), !, asserta(state(Wire, on)), !.
state(Wire, on) :- g_xor(A, B, Wire), state1(A, on), state1(B, off), !, asserta(state(Wire, on)), !.
state(Wire, on) :- g_xor(A, B, Wire), state1(A, off), state1(B, on), !, asserta(state(Wire, on)), !.
state(Wire, off) :- g_and(A, B, Wire), (state1(A, off) ; state1(B, off)), !, asserta(state(Wire, off)), !.
state(Wire, off) :- g_or(A, B, Wire), state1(A, off), state1(B, off), !, asserta(state(Wire, off)), !.
state(Wire, off) :- g_xor(A, B, Wire), state1(A, on), state1(B, on), !, asserta(state(Wire, off)), !.
state(Wire, off) :- g_xor(A, B, Wire), state1(A, off), state1(B, off), !, asserta(state(Wire, off)), !.

load :-
  open('aocinput.txt', read, Fd),
  read_string(Fd, _, File),
  close(Fd),
  split_string(File, "\n", "\n", Lines), !,
  maplist(assert_line, Lines), !,
  findall(Wire, known_wire(Wire), WiresList),
  list_to_ord_set(WiresList, Wires),
  assertz(wires(Wires)), !.

assert_line(Line) :- assert_state(Line) ; assert_rel(Line).

assert_state(Line) :-
  split_string(Line, ":", " ", [Wire, "1"]), !,
  asserta(state(Wire, on)), !.
assert_state(Line) :-
  split_string(Line, ":", " ", [Wire, "0"]), !,
  asserta(state(Wire, off)), !.

assert_rel(Line) :-
  split_string(Line, " ", " ", [WireA, "AND", WireB, "->", Wire]), !,
  assertz(g_and(WireA, WireB, Wire)), !.
assert_rel(Line) :-
  split_string(Line, " ", " ", [WireA, "OR", WireB, "->", Wire]), !,
  assertz(g_or(WireA, WireB, Wire)), !.
assert_rel(Line) :-
  split_string(Line, " ", " ", [WireA, "XOR", WireB, "->", Wire]), !,
  assertz(g_xor(WireA, WireB, Wire)), !.

known_wire(Wire) :- state(Wire, _)
  ; g_and(Wire, _, _) ; g_and(_, Wire, _) ; g_and(_, _, Wire)
  ; g_or(Wire, _, _)  ; g_or(_, Wire, _)  ; g_or(_, _, Wire)
  ; g_xor(Wire, _, _) ; g_xor(_, Wire, _) ; g_xor(_, _, Wire).
