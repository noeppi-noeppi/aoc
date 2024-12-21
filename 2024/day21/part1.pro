:- initialization(main, main).
:- dynamic(robopress/3).

main :-
  read_input(ButtonSeqs, NumericValues),
  maplist(robopress, ButtonSeqs, StepValues),
  maplist(complexity, StepValues, NumericValues, ComplexityValues),
  sum_list(ComplexityValues, Result),
  write(Result), nl.

complexity(Steps, NumericValue, Complexity) :- Complexity is Steps * NumericValue.

robopress(ButtonSeq, Steps) :- once(robopress(3, ButtonSeq, Steps)).
robopress(0, ButtonSeq, Steps) :- buttonseq_len(ButtonSeq, Steps).
robopress(Level, ButtonSeq, Steps) :-
  PrevLevel is Level - 1,
  buttonseq(ButtonSeq, Buttons),
  robopress_count(PrevLevel, apply, Buttons, Steps), !,
  asserta(robopress(Level, ButtonSeq, Steps)).

robopress1(Level, ButtonSeq, Steps) :- once(robopress(Level, ButtonSeq, Steps)).

robopress_count(_PrevLevel, apply, [], 0).
robopress_count(PrevLevel, CurrentlyAt, [NextButton | RestButtons], Steps) :-
  kp_reach(CurrentlyAt, NextButton, TravelSeqs),
  maplist(press_seq, TravelSeqs, PressSeqs), !,
  maplist(robopress1(PrevLevel), PressSeqs, PressSeqSteps),
  min_list(PressSeqSteps, MinSteps), !,
  robopress_count(PrevLevel, NextButton, RestButtons, OtherSteps), !,
  Steps is MinSteps + OtherSteps.

press_seq(TravelSeq, PressSeq) :-
  buttonseq(TravelSeq, Travel),
  append([Travel, [apply]], Press),
  buttonseq(PressSeq, Press), !.

kp_reach(CurrentButton, TargetButton, ButtonSeqs) :-
  kp_coords(CurrentButton, Start),
  kp_coords(TargetButton, End),
  reach(Start, End, [0, 3], ButtonSeqs).
kp_coords(apply, [2, 3]).
kp_coords(zero, [1, 3]).
kp_coords(one, [0, 2]).
kp_coords(two, [1, 2]).
kp_coords(three, [2, 2]).
kp_coords(four, [0, 1]).
kp_coords(five, [1, 1]).
kp_coords(six, [2, 1]).
kp_coords(seven, [0, 0]).
kp_coords(eight, [1, 0]).
kp_coords(nine, [2, 0]).
kp_coords(up, [1, 3]).
kp_coords(down, [1, 4]).
kp_coords(left, [0, 4]).
kp_coords(right, [2, 4]).

reach([StartX, StartY], [EndX, EndY], [NotX, NotY], ButtonSeqs) :-
  reach_list([StartX, StartY], [EndX, EndY], [NotX, NotY], ButtonLists),
  maplist(buttonseq, ButtonSeqs, ButtonLists).
reach_list([StartX, StartY], [StartX, StartY], [_NotX, _NotY], [[]]) :- !.
reach_list([StartX, StartY], [EndX, EndY], [NotX, NotY], ButtonLists) :-
  AbsX is EndX - StartX, (AbsX > 0 -> repeat(right, AbsX, Hor) ; repeat(left, AbsX, Hor)), !,
  AbsY is EndY - StartY, (AbsY > 0 -> repeat(down, AbsY, Vert) ; repeat(up, AbsY, Vert)), !,
  append([Hor, Vert], HorVert), append([Vert, Hor], VertHor),
  ((StartX =:= NotX, EndY =:= NotY) ->
      ButtonLists = [HorVert]
    ; (StartY =:= NotY, EndX =:= NotX) ->
        ButtonLists = [VertHor]
      ; ButtonLists = [HorVert, VertHor]).

buttonseq(ButtonSeq, Buttons) :- ButtonSeq =.. [buttons | Buttons].
buttonseq_len(ButtonSeq, Len) :- functor(ButtonSeq, buttons, Len).
buttonseq_string(ButtonSeq, String) :-
  var(ButtonSeq), !,
  string_codes(String, Codes), !,
  maplist(button_code, Buttons, Codes), !,
  ButtonSeq =.. [buttons | Buttons], !.
buttonseq_string(ButtonSeq, String) :-
  ButtonSeq =.. [buttons | Buttons], !,
  maplist(button_code, Buttons, Codes), !,
  string_codes(String, Codes), !.

button_code(apply, 65).
button_code(zero, 48).
button_code(one, 49).
button_code(two, 50).
button_code(three, 51).
button_code(four, 52).
button_code(five, 53).
button_code(six, 54).
button_code(seven, 55).
button_code(eight, 56).
button_code(nine, 57).
button_code(up, 94).
button_code(down, 76).
button_code(left, 60).
button_code(right, 62).

prepend(H, T, [H | T]).
is(X, _, X).
repeat(X, N, L) :- NA is abs(N), length(LL, NA), maplist(is(X), LL, L), !.

read_input(ButtonSeqs, NumericValues) :-
  open('aocinput.txt', read, Fd),
  read_string(Fd, _, File),
  close(Fd),
  split_string(File, "\n", "\n", Lines), !,
  split_string(File, "\n", "A\n", NumberLines), !,
  maplist(buttonseq_string, ButtonSeqs, Lines),
  maplist(number_string, NumericValues, NumberLines).
