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

main(_) -> Input =
  parse(input()),
  Distance = abs(min(element(3, Input), element(4, Input))),
  Result = (Distance * (Distance - 1)) div 2,
  io:fwrite("~p~n", [ Result ]).
