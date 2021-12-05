in_range(N, L, U) :- N >= L,N =< U;N =< L,N >= U.

line_over_x(X, Y, [K, L], [M, N]) :- line([K, L], [M, N]),in_range(Y, L, N),X=:=K,X=:=M.
line_over_y(X, Y, [K, L], [M, N]) :- line([K, L], [M, N]),in_range(X, K, M),Y=:=L,Y=:=N.
line_over_df(X, Y, [K, L], [M, N]) :- line([K, L], [M, N]),in_range(X, K, M),in_range(Y, L, N),X-K=:=Y-L,X-M=:=Y-N.
line_over_dr(X, Y, [K, L], [M, N]) :- line([K, L], [M, N]),in_range(X, K, M),in_range(Y, L, N),K-X=:=Y-L,M-X=:=Y-N.
line_over(X, Y, F, T) :- line_over_x(X, Y, F, T);line_over_y(X, Y, F, T);line_over_df(X, Y, F, T);line_over_dr(X, Y, F, T).

danger(X, Y) :- line_over(X, Y, FA, TA),line_over(X, Y, FB, TB),(FA\==FB;TA\==TB).

coords(T, A) :- findall([X,Y], (member(X, A), member(Y, A)), T).

find_dangers(T) :- numlist(0,1000,NL),coords(C, NL),bagof([X,Y], (member([X,Y], C), danger(X, Y)), T).

solve(Q) :- find_dangers(L),sort(L,T),length(T,Q).
