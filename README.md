Erlang
======

Missionaries and Cannibals implemented in Erlang as an example of the language's features.

[erlang.org](http://www.erlang.org/)

[wikipedia](http://en.wikipedia.org/wiki/Erlang_%28programming_language%29)

Variables
---------

Variables must begin with uppercase letters.

Atoms
-----

Atoms must begin with lowercase letters or be contained within single quotes.

Examples:
* `goal`
* `bad`
* `'Bad'`
* `new_state`
* `'new state'`

Records
-------

Records are like structs.

They can contain values, which can be named.

You can use a `#` in front of a struct name followd by `{}` to reference it. This will give the default struct.

If you want to change any of the values, you can change them by name.

Examples:
* `-record(side, {m=3, c=3, s=true}).`
* `-record(state, {left=#side{m=0, c=0, s=false}, right=#side{}}).`

Functions
---------

Function parameters use pattern matching.

Function syntax:
```Erlang
sum(X, Y) ->
  Total = X + Y,
  io:fwrite(Total).
```

Spawning
--------

Spawning creates an instance of function.

Syntax: `spawn(module_name, function_name, [Parameters, Here])`

Examples: 
* `spawn(mc, worker, [MasterId, State, []]).`
* `spawn(mc, worker, [self(), State, Path]).`

If Statements
-------------

If statements are like a switch/case. They use pattern matching.

Example:
```Erlang
	if
		LM < 0 ; LC < 0 ; RM < 0 ; LC < 0 ->
			true;
		LM < LC , LM /= 0 ->
			true;
		RM < RC , RM /= 0 ->
			true;
		true ->
			false
	end.
```

Sending Messages
----------------

When sending a message, you use the address of the funtion you are sending to, followed by an exclamation mark, then pass it a message. A message can be an atom, a variable, or a tuple.

Example: `MasterId ! {bad, State, Path};`

Receiving Messages
------------------

The `receive` syntax is much like the `if` syntax.  It is common to use atoms for pattern matching.

```Erlang
	receive
		{goal, Path} ->
			io:fwrite("Reached the other side with everyone safely across.~n"),
			%%printPath(Path);
			io:format("~p~n", [Path]);
		{bad, _, _} ->
			master();
		{new_state, State, Path} ->
			spawn(mc, worker, [self(), State, Path]),
			master()

	end.
```

Death
-----
Erlang: the emo language.

A function must call itself in order for it to keep living. If it does not call itself, it will kill itself.

If a master function dies, all of it's worker functions also kill themselves.
