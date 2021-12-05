straight([A, B], [C, D]) :- line([A, B], [C, D]), (A == C ; B == D).

in_range(N, L, U) :- N >= L,N =< U;N =< L,N >= U.

line_over_x(X, Y, [K, L]) :- straight([X, K], [X, L]),in_range(Y, K, L).
line_over_y(X, Y, [M, N]) :- straight([M, Y], [N, Y]),in_range(X, M, N).

danger_x(X, Y) :- line_over_x(X, Y, A),line_over_x(X, Y, B),(A\=B).
danger_y(X, Y) :- line_over_y(X, Y, A),line_over_y(X, Y, B),(A\=B).
danger_d(X, Y) :- line_over_x(X, Y, [_, _]),line_over_y(X, Y, [_, _]).
danger(X, Y) :- danger_x(X, Y);danger_y(X, Y);danger_d(X, Y).

coords(T, A) :- findall([X,Y], (member(X, A), member(Y, A)), T).

find_dangers(T) :- numlist(0,1000,NL),coords(C, NL),bagof([X,Y], (member([X,Y], C), danger(X, Y)), T).

solve(Q) :- find_dangers(L),sort(L,T),length(T,Q).
