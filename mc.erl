-module(mc).
%%-execute([]).
-compile(export_all).

-record(side, {m=3, c=3, s=true}).
-record(state, {left=#side{m=0, c=0, s=false}, right=#side{}}).

start() ->
	State = #state{},
	MasterId = spawn(mc, master, []),
	spawn(mc, worker, [MasterId, State, []]).

printPath([H]) ->
	io:format("~p~n", H);
printPath([H|T]) ->
	io:format("~p~n", H),
	printPath(T).

master() ->
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
		
worker(MasterId, State, Path) ->
	Val = is_invalid(State),
	Goal = is_goal(State),
	Starting = starting_state(State, Path),
	
	if
		Goal ->
			MasterId ! {goal, Path ++ [State]};
		Val ; Starting ->
			MasterId ! {bad, State, Path};
		true -> %%default case
			New = permutation(State),
			report_back(MasterId, New, Path ++ [State])
	end.

is_goal(#state{left=#side{m=3, c=3, s=true}}) -> true;
is_goal(#state{}) -> false.

is_invalid(#state{left=#side{m=LM, c=LC}, right=#side{m=RM, c=RC}}) ->
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

starting_state(_, []) -> false;
starting_state(#state{left=#side{m=0, c=0, s=false}, right=#side{m=3, c=3, s=true}}, _) -> true;
starting_state(_, _) -> false.

permutation(State = #state{right=#side{s=true}}) ->
	Moves = [[1,0,-1,0],[2,0,-2,0],[1,1,-1,-1],[0,1,0,-1],[0,2,0,-2]],
	permutation(State, Moves, []);
permutation(State = #state{left=#side{s=true}}) ->
	Moves = [[-1,0,1,0],[-2,0,2,0],[-1,-1,1,1],[0,-1,0,1],[0,-2,0,2]],
	permutation(State, Moves, []).

permutation(_, [], NewStates) ->
	NewStates;
permutation(State, [H|T], NewStates) ->
	NewState = transform(State, H),
	permutation(State, T, NewStates++[NewState]).	

transform(#state{left=#side{m=LM, c=LC, s=LS}, right=#side{m=RM, c=RC, s=RS}}, [A, B, C, D]) ->
	#state{left=#side{m=LM+A, c=LC+B, s=not LS}, right=#side{m=RM+C, c=RC+D, s=not RS}}.

report_back(MasterId, [H], Path) ->
	MasterId ! {new_state, H, Path};
report_back(MasterId, [H|T], Path) ->
	MasterId ! {new_state, H, Path},
	report_back(MasterId, T, Path).

