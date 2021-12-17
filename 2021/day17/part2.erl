-mode(compile).

input() -> string:chomp(io:get_line("")).
parse(Str) -> case re:run(Str, "target area: x=(-?\\d+)..(-?\\d+), y=(-?\\d+)..(-?\\d+)") of
    {_, Groups} -> {
      list_to_integer(string:substr(Str, element(1, lists:nth(2, Groups)) + 1, element(2, lists:nth(2, Groups)))),
      list_to_integer(string:substr(Str, element(1, lists:nth(3, Groups)) + 1, element(2, lists:nth(3, Groups)))),
      list_to_integer(string:substr(Str, element(1, lists:nth(4, Groups)) + 1, element(2, lists:nth(4, Groups)))),
      list_to_integer(string:substr(Str, element(1, lists:nth(5, Groups)) + 1, element(2, lists:nth(5, Groups))))
    }
  end.

tx(Start, Steps) when (Start == 0) or (Steps =< 0) -> 0;
tx(Start, Steps) when Start < 0 -> Start + tx(Start + 1, Steps - 1);
tx(Start, Steps) -> Start + tx(Start - 1, Steps - 1).

ty(_, Steps) when Steps =< 0 -> 0;
ty(Start, Steps) -> Start + ty(Start - 1, Steps - 1).

inside(X, Y, {X1, X2, Y1, Y2}) -> (X >= X1) and (X =< X2) and (Y >= Y1) and (Y =< Y2).

hits(X, Y, Coords, Steps) -> lists:filter(fun(S) -> inside(tx(X, S), ty(Y, S), Coords) end, lists:seq(1, Steps)) /= [].
bool2int(B) -> if B -> 1; true -> 0 end.

main(_) ->
  Coords = parse(input()),
  {X1, X2, Y1, Y2} = Coords,
  Distance = abs(min(Y1, Y2)),
  MaxY = Distance + 1,
  MinY = -MaxY,
  MaxX = max(X1, X2),
  MaxSteps = min(MaxX, 2 * MaxY),
  Tries = lists:flatmap(fun(X) -> lists:map(fun(Y) -> {X, Y} end, lists:seq(MinY, MaxY)) end, lists:seq(1, MaxX)),
  R = lists:foldl(fun({X, Y}, Acc) -> Acc + bool2int(hits(X, Y, Coords, MaxSteps)) end, 0, Tries),
  io:fwrite("~p~n", [ R ]).
