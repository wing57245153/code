%%% -------------------------------------------------------------------
%%% Author  : Administrator
%%% Description :
%%%
%%% Created : 2012-4-4
%%% -------------------------------------------------------------------
-module(compareFile).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

-define(EXCLUDE_FOLDERS,".svn").
%% --------------------------------------------------------------------
%% External exports
-export([start/0,compare/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {
				oldPath,
				newPath,
				difPath}).

%% ====================================================================
%% External functions
%% ====================================================================
start() -> 
	gen_server:start_link({local,?MODULE}, ?MODULE, [],[]).

compare() ->
	gen_server:cast(?MODULE, {compare}).


%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
	{ok,IoDevice} = file:open("compare.ini", read),
	{ok,OldPath} = file:read_line(IoDevice),
	{ok,NewPath} = file:read_line(IoDevice),
	{ok,DifPath} = file:read_line(IoDevice),
	State = #state{oldPath = lists:sublist(OldPath,length(OldPath)-1),
				   newPath = lists:sublist(NewPath,length(NewPath)-1),
				   difPath = lists:sublist(DifPath,length(DifPath)-1)},
    {ok, State}.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast({compare}, State) ->	
	compareFile(State#state.newPath,State#state.oldPath,State#state.difPath),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}        |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% ---------------------------- ----------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

compareFile(NewPath,OldPath,DifPath) ->
	case file:list_dir(NewPath) of
		{ok, Files} -> 
			compareFile(NewPath,Files,OldPath,DifPath);
		_ -> error
	end.

compareFile(NewPath,Files,OldPath,DifPath) when length(Files) > 0 ->
	[H|T] = Files,
	NewPathFileName = lists:concat([NewPath,"/",H]),
	OldPathFileName = lists:concat([OldPath,"/",H]),
	DifPathFileName = lists:concat([DifPath,"/",H]),
	case filelib:is_dir(NewPathFileName) of
		true -> 
			compareFile(filename:join([NewPath,H]),filename:join([OldPath,H]),filename:join([DifPath,H]));
		_ -> 
			case filelib:is_file(OldPathFileName) of %%compare old file
			 	false -> copy(NewPathFileName,DifPathFileName);
				true -> compareFileAndCopyDif(NewPathFileName,OldPathFileName,DifPathFileName)
			end
	end,
	compareFile(NewPath,T,OldPath,DifPath);
compareFile(_NewPath,_Files,_OldPath,_DifPath) -> ok.

compareFileAndCopyDif(NewPathFileName,OldPathFileName,DifPathFileName) ->
	{ok,NewBin} = file:read_file(NewPathFileName),
	{ok,OldBin} = file:read_file(OldPathFileName),
	NewMd5 = erlang:md5(NewBin),
	OldMd5 = erlang:md5(OldBin),
	if
		NewMd5 == OldMd5 -> ok;
		true -> copy(NewPathFileName,DifPathFileName)
	end.

copy(NewPathFileName,DifPathFileName) ->
	filelib:ensure_dir(DifPathFileName),
	io:format(DifPathFileName),
	io:format("~n"),
	file:copy(NewPathFileName, DifPathFileName).

