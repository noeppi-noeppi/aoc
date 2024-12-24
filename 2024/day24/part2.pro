:- initialization(main, main).
:- dynamic(known_wire/1).
:- dynamic(wires/2).
:- dynamic(g_and/3).
:- dynamic(g_or/3).
:- dynamic(g_xor/3).
:- dynamic(swap/1).

main :-
  load,
  wires(AllWires),
  exclude(not_x, AllWires, XWires),
  list_to_ord_set(XWires, SortedXWires),
  exclude(not_y, AllWires, YWires),
  list_to_ord_set(YWires, SortedYWires),
  exclude(not_z, AllWires, ZWires),
  list_to_ord_set(ZWires, SortedZWires),
  find_adders(SortedXWires, SortedYWires, SortedZWires, _),
  findall(X, swap(X), RelevantWires),
  sort(RelevantWires, Result),
  write_list(Result), nl.

write_list([]).
write_list([S]) :- write(S).
write_list([H | T])  :- write(H), write(","), write_list(T).

find_adders([A | WX], [B | WY], [R | WZ], [SEC | Carries]) :- half_adder(A, B, R, SEC), !, find_full_adders(WX, WY, WZ, SEC, Carries).
find_full_adders([A], [B], [R, RC], INC, []) :- !, full_adder(A, B, INC, R, RC).
find_full_adders([A | WX], [B | WY], [R | WZ], INC, [SEC | Carries]) :- full_adder(A, B, INC, R, SEC), !, find_full_adders(WX, WY, WZ, SEC, Carries).
find_full_adders([A | WX], [B | WY], [R | WZ], INC, [unknown | Carries]) :-
  (\+ full_adder(A, B, INC, R, _)), !,
  find_full_adders(WX, WY, WZ, SEC, Carries), !,
  repair_adder(A, B, INC, R, SEC, [SwapA, SwapB]), !,
  assertz(swap(SwapA)), assertz(swap(SwapB)), !.

half_adder(A, B, R, SEC) :- c_xor(A, B, R), c_and(A, B, SEC), !.
full_adder(A, B, INC, R, SEC) :- half_adder(A, B, ANC, SNC), half_adder(INC, ANC, R, SCC), c_or(SNC, SCC, SEC), !.

repair_adder(A, B, INC, R, SEC, [ANC, SNC]) :- c_xor(A, B, SNC), c_and(A, B, ANC), c_xor(INC, ANC, R  ), c_and(INC, ANC, SCC), c_or(SNC, SCC, SEC), !.
repair_adder(A, B, INC, R, SEC, [ANC, R  ]) :- c_xor(A, B, R  ), c_and(A, B, SNC), c_xor(INC, ANC, ANC), c_and(INC, ANC, SCC), c_or(SNC, SCC, SEC), !.
repair_adder(A, B, INC, R, SEC, [ANC, SCC]) :- c_xor(A, B, SCC), c_and(A, B, SNC), c_xor(INC, ANC, R  ), c_and(INC, ANC, ANC), c_or(SNC, SCC, SEC), !.
repair_adder(A, B, INC, R, SEC, [ANC, SEC]) :- c_xor(A, B, SEC), c_and(A, B, SNC), c_xor(INC, ANC, R  ), c_and(INC, ANC, SCC), c_or(SNC, SCC, ANC), !.
repair_adder(A, B, INC, R, SEC, [SNC, R  ]) :- c_xor(A, B, ANC), c_and(A, B, R  ), c_xor(INC, ANC, SNC), c_and(INC, ANC, SCC), c_or(SNC, SCC, SEC), !.
repair_adder(A, B, INC, R, SEC, [SNC, SCC]) :- c_xor(A, B, ANC), c_and(A, B, SCC), c_xor(INC, ANC, R  ), c_and(INC, ANC, SCC), c_or(SNC, SCC, SEC), !.
repair_adder(A, B, INC, R, SEC, [SNC, SEC]) :- c_xor(A, B, ANC), c_and(A, B, SEC), c_xor(INC, ANC, R  ), c_and(INC, ANC, SCC), c_or(SNC, SCC, SNC), !.
repair_adder(A, B, INC, R, SEC, [R  , SCC]) :- c_xor(A, B, ANC), c_and(A, B, SNC), c_xor(INC, ANC, SCC), c_and(INC, ANC, R  ), c_or(SNC, SCC, SEC), !.
repair_adder(A, B, INC, R, SEC, [R  , SEC]) :- c_xor(A, B, ANC), c_and(A, B, SNC), c_xor(INC, ANC, SEC), c_and(INC, ANC, SCC), c_or(SNC, SCC, R  ), !.
repair_adder(A, B, INC, R, SEC, [SCC, SEC]) :- c_xor(A, B, ANC), c_and(A, B, SNC), c_xor(INC, ANC, R  ), c_and(INC, ANC, SEC), c_or(SNC, SCC, SCC), !.

assemble([], 0).
assemble([H | T], Result) :- state(H, on), !, assemble(T, PrevResult), Result is 2 * PrevResult + 1.
assemble([H | T], Result) :- state(H, off), !, assemble(T, PrevResult), Result is 2 * PrevResult.

not_x(Wire) :- \+ string_codes(Wire, [120 | _]).
not_y(Wire) :- \+ string_codes(Wire, [121 | _]).
not_z(Wire) :- \+ string_codes(Wire, [122 | _]).

c_and(A, B, R) :- g_and(A, B, R) ; g_and(B, A, R).
c_or(A, B, R)  :- g_or(A, B, R)  ; g_or(B, A, R) .
c_xor(A, B, R) :- g_xor(A, B, R) ; g_xor(B, A, R).

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

assert_state(Line) :- split_string(Line, ":", " ", [Wire, "1"]), asserta(known_wire(Wire)).
assert_state(Line) :- split_string(Line, ":", " ", [Wire, "0"]), asserta(known_wire(Wire)).

assert_rel(Line) :-
  split_string(Line, " ", " ", [WireA, "AND", WireB, "->", Wire]), !,
  assertz(g_and(WireA, WireB, Wire)), !.
assert_rel(Line) :-
  split_string(Line, " ", " ", [WireA, "OR", WireB, "->", Wire]), !,
  assertz(g_or(WireA, WireB, Wire)), !.
assert_rel(Line) :-
  split_string(Line, " ", " ", [WireA, "XOR", WireB, "->", Wire]), !,
  assertz(g_xor(WireA, WireB, Wire)), !.

known_wire(Wire) :-
    g_and(Wire, _, _) ; g_and(_, Wire, _) ; g_and(_, _, Wire)
  ; g_or(Wire, _, _)  ; g_or(_, Wire, _)  ; g_or(_, _, Wire)
  ; g_xor(Wire, _, _) ; g_xor(_, Wire, _) ; g_xor(_, _, Wire).
