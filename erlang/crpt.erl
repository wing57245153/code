%%% -------------------------------------------------------------------
%%% Author  : wing
%%% Description :
%%%
%%% Created : 2012-6-5
%%% -------------------------------------------------------------------
-module(crpt).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([start/0,decode/1,encode/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {}).

%% ====================================================================
%% External functions
%% ====================================================================
start() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

decode(FileName) ->
	gen_server:cast(?MODULE, {decode,FileName}).

encode(FileName) ->
	gen_server:cast(?MODULE, {encode,FileName}).

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
    {ok, #state{}}.

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
handle_cast({decode,FileName},State) ->  
	case file:read_file(FileName) of
		{ok, Bin} ->
			{_, P2} = split_binary(Bin, 3),
			DecodeFileName = string:concat("decode_", FileName),
			file:write_file(DecodeFileName, <<67,87,83,P2/binary>>),
			decode_ok;
		_ ->
			read_error
	end,
	{noreply, State};
handle_cast({encode,FileName},State) -> 
	case file:read_file(FileName) of
		{ok, BinE} ->
			{_, PE} = split_binary(BinE, 3),
			EncodeFileName = string:concat("encode_", FileName),
			file:write_file(EncodeFileName, <<170,170,170,PE/binary>>);
		_ ->
			read_error
	end,
	{noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
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
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

