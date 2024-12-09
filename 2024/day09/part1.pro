:- initialization(main, main).

sub0([48 | TCodes], Id, NTCodes, NId) :- Y is Id + 1, sub0(TCodes, Y, NTCodes, NId).
sub0([HCode | TCodes], Id, [HCode | TCodes], Id) :- HCode =\= 48.

sub1([48 | TCodes], Id, NTCodes, NId) :- sub0([48 | TCodes], Id, NTCodes, NId).
sub1([49 | TCodes], Id, NTCodes, NId) :- Y is Id + 1, sub0(TCodes, Y, NTCodes, NId).
sub1([50 | TCodes], Id, [49 | TCodes], Id).
sub1([51 | TCodes], Id, [50 | TCodes], Id).
sub1([52 | TCodes], Id, [51 | TCodes], Id).
sub1([53 | TCodes], Id, [52 | TCodes], Id).
sub1([54 | TCodes], Id, [53 | TCodes], Id).
sub1([55 | TCodes], Id, [54 | TCodes], Id).
sub1([56 | TCodes], Id, [55 | TCodes], Id).
sub1([57 | TCodes], Id, [56 | TCodes], Id).

dsum([], 0).
dsum([HCode | TCodes], Sum) :- dsum(TCodes, Y), Sum is HCode - 48 + Y.

input(0, Codes, 0) :-
  open('aocinput.txt', read, Fd),
  read_line_to_string(Fd, Line),
  close(Fd),
  string_codes(Line, Codes), !.
input(X, Codes, Id) :-
  X =\= 0,
  Y is X - 1,
  input(Y, NCodes, NId),
  sub1(NCodes, NId, Codes, Id), !.

length(Len) :-
  input(0, Codes, _),
  dsum(Codes, Len), !.

space(Idx) :-
  input(Idx, _, TId),
  length(Y),
  Idx =\= Y,
  TId mod 2 =:= 1, !.

block(Idx, Id) :-
  input(Idx, _, TId),
  TId mod 2 =:= 0,
  Id is TId / 2, !.

space_count(0, _, 0).
space_count(_, [], 0).
space_count(_, [_], 0).
space_count(Idx, [Blk | [_ | _]], 0) :-
  RBlk is Blk - 48,
  Idx =< RBlk, !.
space_count(Idx, [Blk | [Sp | _]], SC) :-
  RBlk is Blk - 48,
  RSp is Sp - 48,
  RCmp is RBlk + RSp,
  Idx > RBlk,
  Idx =< RCmp, !,
  SC is Idx - RBlk.
space_count(Idx, [Blk | [Sp | Rest]], SC) :-
  RBlk is Blk - 48,
  RSp is Sp - 48,
  RCmp is RBlk + RSp,
  Idx > RCmp, !,
  NIdx is Idx - RCmp,
  space_count(NIdx, Rest, NSC), !,
  SC is RSp + NSC.

space_count(Idx, SC) :- SCIdx is Idx + 1, input(0, Codes, _), !, space_count(SCIdx, Codes, SC).

block_count([], 0).
block_count([BC0 | []], BC) :- BC is BC0 - 48.
block_count([BC0 | [_ | NCodes]], BC) :-
  block_count(NCodes, NBC), !,
  BC is BC0 - 48 + NBC.

block_count(BC) :- input(0, Codes, _), !, block_count(Codes, BC).

tail_count(0, _, 0).
tail_count(_, [], 0).
tail_count(_, [_], 0).
tail_count(Idx, [Blk | [_ | _]], Idx) :-
  RBlk is Blk - 48,
  Idx =< RBlk, !.
tail_count(Idx, [Blk | [Sp | Rest]], TC) :-
  RBlk is Blk - 48,
  RSp is Sp - 48,
  Idx > RBlk, !,
  NIdx is Idx - RBlk,
  tail_count(NIdx, Rest, NTC), !,
  TC is RBlk + RSp + NTC.

tail_count(0, 0).
tail_count(Idx, TC) :-
  Idx =\= 0,
  TCIdx is Idx,
  input(0, Codes, _), !,
  reverse(Codes, RCodes), !,
  length(Len), !,
  tail_count(TCIdx, RCodes, SubTC),
  TC is Len - SubTC.

tail_block(SC, Id) :- tail_count(SC, Idx), block(Idx, Id), !.

new_block(Idx, Id) :- block(Idx, Id), !.
new_block(Idx, Id) :-
  space(Idx),
  space_count(Idx, SC),
  tail_block(SC, Id), !.

block_checksum(Idx, Chk) :- new_block(Idx, Id), Chk is Idx * Id.

fs_checksum(0, Chk) :- block_checksum(0, Chk).
fs_checksum(Last, Chk) :-
  ButLast is Last - 1,
  block_checksum(Last, ThisChk),
  fs_checksum(ButLast, LastChk),
  Chk is ThisChk + LastChk, !.

fs_checksum(Chk) :- block_count(BC), Last is BC - 1, fs_checksum(Last, Chk).

main :- fs_checksum(Result), write(Result), nl.
