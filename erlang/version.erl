%%% -------------------------------------------------------------------
%%% Author  : Administrator
%%% Description :
%%%
%%% Created : 2011-11-3
%%% -------------------------------------------------------------------
-module(version).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("kernel/include/file.hrl").

-define(VER_DATA, "data2.tab").

-define(INCLUDE_FOLDERS, ["ui", "config", "res"]).
-define(EXCLUDE_FOLDERS, [".git"]).
-define(EXCLUDE_FILES, [".fla",
						".as",
					  	".db"]).
-define(EXCLUDE_MIX_SWF, ["iLoader.swf", "Game.swf", "mainloading.swf", "mainloading_bg.swf", "iLoader2D.swf"]).
-define(PURGE_FILE, "purgedir.log").
%% --------------------------------------------------------------------
%% External exports
-export([
		 start/0,
		 clear/0,
		 build/0,
		 build/1,
		 lookup/1,
		 updateOneVersion/1,
		 release/0,
		 makeSelfVersion/0,
		 writeLog/0
		 ]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(ver,
		{
		 url,		% path and filename
		 md5,		% md5 str
		 v = 1		% version number
		 }).

-record(state, 
		{
		 table,
		 source,
		 output,
		 difUrl
		 }).

%% ====================================================================
%% External functions
%% ====================================================================
start() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

clear() -> gen_server:cast(?MODULE, clear).
build() -> gen_server:cast(?MODULE, build).
build(Folder) -> gen_server:cast(?MODULE, {build, Folder}).

lookup(Key) ->
	gen_server:cast(?MODULE, {lookup,Key}).
updateOneVersion(Key) -> 
	gen_server:cast(?MODULE, {updateOneVersion,Key}).
release() -> 
	gen_server:cast(?MODULE, release).

makeSelfVersion() ->
	gen_server:cast(?MODULE, makeSelfVersion).

writeLog() ->
	gen_server:cast(?MODULE, writeLog).
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
	{ok, IoDevice} = file:open("config.ini", read),
	{ok, Source} = file:read_line(IoDevice),
	{ok, Output} = file:read_line(IoDevice),
	{ok, DifUrl} = file:read_line(IoDevice),
	
	State = #state{ source=lists:sublist(Source, length(Source)-1),
				 	output=lists:sublist(Output, length(Output)-1),
					difUrl=lists:sublist(DifUrl, length(DifUrl)-1 ) },
	
	case ets:file2tab( lists:concat([State#state.source, '/', ?VER_DATA]) ) of
		{ok, Table} -> ok;
		_ -> Table = ets:new(version, [{keypos, 2}])
	end,
	
    {ok, State#state{ table = Table}}.

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

handle_cast(clear, State) ->
	
	del_folder( State#state.output ),
	{noreply, State};

handle_cast({build, "config"}, State) ->
	
	Config = lists:concat([State#state.source, "/bin-debug/config.zd"]),
	file:delete( Config ),
	
	Output = "f:/",
	ConfigFolder = lists:concat([State#state.source, "/config"]),
	case file:list_dir( ConfigFolder ) of
		{ok, Files} ->
			lists:foreach(fun(File)->
								  Source = lists:concat([ConfigFolder, '/', File]),
								  Dest = lists:concat([Output, "/config/", File]),
								  filelib:ensure_dir(Dest),
								  file:copy(Source, Dest)
						  end, Files);
		_ ->
			ok
	end,
	
	OutputFolder = lists:concat([Output, "/config"]),
	OutputFile = lists:concat([Output, "/config.zd"]),
	rar(OutputFile, OutputFolder),
	del_folder(OutputFolder),
	
	file:copy(OutputFile, Config),
	file:delete( OutputFile ),
	
	{noreply, State};

handle_cast({build, "data"}, State) ->
	
	Config = lists:concat([State#state.source, "/bin-debug/data.zd"]),
	file:delete( Config ),
	
	Output = "f:/",
	ConfigFolder = lists:concat([State#state.source, "/res/data"]),
	case file:list_dir( ConfigFolder ) of
		{ok, Files} ->
			lists:foreach(fun(File)->
								  Source = lists:concat([ConfigFolder, '/', File]),
								  Dest = lists:concat([Output, "/data/", File]),
								  filelib:ensure_dir(Dest),
								  file:copy(Source, Dest)
						  end, Files);
		_ ->
			ok
	end,
	
	OutputFolder = lists:concat([Output, "/data"]),
	OutputFile = lists:concat([Output, "/data.zd"]),
	rar(OutputFile, OutputFolder),
	del_folder(OutputFolder),
	
	file:copy(OutputFile, Config),
	file:delete( OutputFile ),
	
	{noreply, State};

handle_cast(build, State) ->
	
	del_folder( State#state.difUrl ),
	PurgeDestination = lists:concat([State#state.output, '/', ?PURGE_FILE]),
	file:delete(PurgeDestination),
	%copy files from project to the dest folder
	copy_files(State#state.source, ?INCLUDE_FOLDERS, State),
	
	%zip data files
	Config = lists:concat([State#state.output, "/config"]),
	rar(lists:concat([State#state.output, "/config.zd"]), Config),
	del_folder(Config),
	Data = lists:concat([State#state.output, "/res/data"]),
	rar(lists:concat([State#state.output, "/data.zd"]), Data),
	del_folder(Data),
	
	Html = lists:concat([State#state.source, "/html"]),
	case file:list_dir( Html ) of
		{ok, Files} ->
			lists:foreach(fun(File)->
								  Source = lists:concat([Html, '/', File]),
								  Dest = lists:concat([State#state.output, '/', File]),
								  filelib:ensure_dir(Dest),
								  file:copy(Source, Dest)
						  end, Files);
		_ ->
			ok
	end,
	%make md5 for each, and mix swf files
	makeMD5AndMix(State#state.output, State#state.table, State#state.output , State),
	
	%make and zip the version file
	%Xml = lists:concat([State#state.output, "/version.txt"]),	
	%Version = lists:concat([State#state.output, "/version.zd"]),
	%Info = ets:tab2list( State#state.table ),
	%file:write_file(Xml, list_to_binary(format(Info))),
	%zip:zip(Version, [Xml]),
	%file:delete(Xml),
	
	%save in local file
	%ets:tab2file( State#state.table, lists:concat([State#state.source, '/', ?VER_DATA]) ),
	makeVersionFile(State),
	
	%some html file
	io:format("build end......"),
	%makeVersionSelfByHtml(State),
	{noreply, State};

handle_cast({lookup,Key}, State) ->
	List = ets:lookup(State#state.table, Key),
	if 		
		length(List) =:= 0 ->
		   io:format(string:concat(Key, " not in the table\n"));
		length(List) =/= 0 ->
			[Item] = List,       
			io:format("version:~p\n",[Item#ver.v])
	end,
	{noreply, State};

handle_cast({updateOneVersion,Key}, State) ->
	Table = State#state.table,
	List = ets:lookup(Table, Key),
	if 		
		length(List) =:= 0 ->
		   ets:insert(Table, #ver{ url=Key}),
		   io:format(string:concat(Key, " not in the table\n"));
		length(List) =/= 0 ->
			[Item] = List,       
			io:format("current version:~p\n",[Item#ver.v]),
			Source = lists:concat([State#state.output, '/', Key]),
			Version = readFileInfo(Source),
			ets:insert(Table, Item#ver{v = Version}),			
			NewList = ets:lookup(Table, Key),
			[NewItem] = NewList,
			io:format("now version:~p\n",[NewItem#ver.v]),
			makeVersionFile(State),
			io:format("the new version file is created\n"),
			PurgeDestination = lists:concat([State#state.output, '/', ?PURGE_FILE]),
			file:delete(PurgeDestination),
			Content = lists:concat([Key,'?',NewItem#ver.v,'\n']),
			writePurgedirLog(PurgeDestination, Content)
	end,
	%makeVersionSelfByHtml(State),
	{noreply, State};

handle_cast(release, State) ->
	del_folder( State#state.difUrl ),
	%make md5 for each, and mix swf files
	makeMD5AndMix(State#state.output, State#state.table, State#state.output,State),
	%make and zip the version file
	makeVersionFile(State),
	%makeVersionSelfByHtml(State),
    {noreply, State};

handle_cast(makeSelfVersion, State) ->
	%makeVersionSelfByHtml(State),
    {noreply, State};

handle_cast(writeLog, State) ->
	Table = State#state.table,
	FirstKey = ets:first(Table),
	traversalTable(Table, FirstKey),
	{noreply, State};

handle_cast(_Msg, State) ->
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

copy_files(Project, Folder, State) when length(Folder)>0 ->
	[H|T] = Folder,
	copy_files(lists:concat([Project, '/', H]), State),
	copy_files(Project, T, State);
copy_files(_Project, _Folder, _State) ->
	ok.

makeMD5AndMix(Path, Table, Output ,State) ->
	case file:list_dir(Path) of
		{ok, Files} ->
			makeMD5AndMix(Path, Files, Table, Output,State);
		_ ->
			ok
	end.
makeMD5AndMix(Path, Files, Table, Output,State) when length(Files)>0 ->
	[H|T] = Files,
	FileName = lists:concat([Path, '/', H]),
	case filelib:is_dir(FileName) of
		true ->
			makeMD5AndMix(filename:join([Path, H]), Table, Output,State);
		false ->
			case file:read_file(FileName) of
				{ok, Bin} ->
					Key = relative(FileName, Output),
					DifDestination = lists:concat([State#state.difUrl, '/', Key]),
					PurgeDestination = lists:concat([State#state.output, '/', ?PURGE_FILE]),
					PurgeDif = lists:concat([State#state.difUrl, '/', ?PURGE_FILE]),
					io:format("makeMD5AndMix:~p\n" , [Key]),
					MD5 = erlang:md5(Bin),
					List = ets:lookup(Table, Key),
					if
						length(List) == 0 ->				
							filelib:ensure_dir(DifDestination),
							file:copy(FileName, DifDestination),
							ets:insert(Table, #ver{ url=Key, md5=MD5 , v=readFileInfo(FileName)}),
							Content = lists:concat([Key,'?',readFileInfo(FileName),'\n']),
							writePurgedirLog(PurgeDestination, Content),
							writePurgedirLog(PurgeDif, Content);
						true ->
						[Item] = List,
						if
							MD5 == Item#ver.md5 -> ok;
							true -> 
								filelib:ensure_dir(DifDestination),
								file:copy(FileName, DifDestination),
								ets:insert(Table, Item#ver{md5=MD5, v=readFileInfo(FileName)}),
								Content = lists:concat([Key,'?',Item#ver.v,'\n']),
							    writePurgedirLog(PurgeDestination, Content),
								writePurgedirLog(PurgeDif, Content)
						end
					end;
				_ ->
					ok
			end,
			case string:str(FileName, ".swf") of
				0 -> ok;
				_-> mix(FileName)
			end
	end,
	makeMD5AndMix(Path, T, Table, Output,State);
makeMD5AndMix(_Path, _Files, _Table, _Output,_State) ->
	ok.
		
readFileInfo(FileName) ->
	case file:read_file_info(FileName) of
		{ok,Facts} ->
			io:format("the dif file ~p", [FileName]),
			io:format(" version is ~p~n", [dateStr(Facts#file_info.ctime)]),
			dateStr(Facts#file_info.mtime);
		_ ->
			error
	end.
dateStr(Date) ->
	{{Year,Mon,Day},{Hour,Min,Sec}} = Date,
	lists:concat([Year,Mon,Day,Hour,Min,Sec]).

writePurgedirLog(FileName,Content) ->
	filelib:ensure_dir(FileName),
	file:write_file(FileName, to_binary(Content), [append]).

copy_files(Path, State) ->
	case limit(Path, ?EXCLUDE_FOLDERS) of
		false -> 
			case file:list_dir(Path) of
				{ok, Files} ->
					io:format("copy file: ~p\n" , [Path]),
					copy_folder(Path, Files, State);
				_ -> ok
			end;
		true -> ok
	end.

copy_folder(Path, Names, State) when length(Names)>0 ->
	[H|T] = Names,
	Url = lists:concat([Path, '/', H]),
	IsDir = filelib:is_dir(Url),
	if
		IsDir == false ->
			case limit(Url, ?EXCLUDE_FILES) of
				false ->
 					copy(Url, State);
				true ->
					ok
			end;
		true ->
			copy_files(filename:join([Path, H]), State)
	end,
	copy_folder(Path, T, State),
	ok;
copy_folder(_, _, _) ->
	ok.

limit(FileName, Filter) when length(Filter)>0 ->
	[H|T] = Filter,
	case string:str(FileName, H) of
		0 -> limit(FileName, T);
		_ -> true
	end;
limit(_FileName, _Filter) ->
	false.

relative(Source, Head) ->
	string:sub_string(Source, length(Head)+2).

copy(Source, State) ->
    Relative = relative(Source, State#state.source),
	Destination = lists:concat([State#state.output, '/', Relative]),
			
	filelib:ensure_dir(Destination),
	file:copy(Source, Destination),
	ok.

mix(FileName) ->
	case limit(FileName, ?EXCLUDE_MIX_SWF) of
		true ->
			limited;
		false ->
			case file:read_file(FileName) of
				{ok, Bin} ->
					{_, P2} = split_binary(Bin, 3),
					file:write_file(FileName, <<170, 170, 170, P2/binary>>);
				_ ->
					read_error
			end
	end.


rar(Target, Folder) ->
	{ok, Files} = file:list_dir(Folder),
	N = lists:map(fun(Elem) ->
						  lists:concat([Folder, "/", Elem])
						  end, Files),
	zip:zip(Target, N).

del_folder(Dir) ->
	case file:list_dir(Dir) of
		{ok, Files} -> 
			del_folder(Dir, Files),
			file:del_dir(Dir);
		_ ->
			ok
	end.
del_folder(Path, Names) when length(Names)>0 ->
	[H|T] = Names,
	Url = lists:concat([Path, '/', H]),
	IsDir = filelib:is_dir(Url),
	if
		IsDir == false ->
			file:delete(Url);
		true ->
			del_folder(filename:join([Path, H])),
			file:del_dir(Url)
	end,
	del_folder(Path, T);
del_folder(_, _) ->
	ok.
makeVersionFile(State) ->
	%make and zip the version file
	%Xml = lists:concat([State#state.output, "/version.txt"]),	
	%Version = lists:concat([State#state.output, "/version.zd"]),
	Info = ets:tab2list( State#state.table ),
	%file:write_file(Xml, list_to_binary(format(Info))),
	%file:write_file(Xml, unicode:characters_to_binary(unicode:characters_to_list(format(Info)))),
	%zip:zip(Version, [Xml]),
	%file:delete(Xml),
	VersionFile = lists:concat([State#state.output, "/fileTime.zd"]),
	DifVersion = lists:concat([State#state.difUrl, "/fileTime.zd"]),
	%formatBatys(Info),
		
	Bin = list_to_binary(formatBatys(Info)),
	CompressBin = zlib:compress(Bin),
	file:write_file(VersionFile, CompressBin),
	io:format("write version file end:~p\n" , [VersionFile]),
	
	filelib:ensure_dir(DifVersion),
	file:copy(VersionFile, DifVersion),
	%save in local file
	ets:tab2file( State#state.table, lists:concat([State#state.source, '/', ?VER_DATA]) ).

%% format(List) ->
%% 	lists:concat(["<config>", item(List), "</config>"]).
%% item(List) when length(List)>0 ->
%% 	[H|T] = List,
%% 	Index = string:str(H#ver.url,".git"),
%% 	if
%% 		Index == 0 ->
%% 			S = lists:concat(["<f v=\"", H#ver.v, "\" u=\"", H#ver.url, "\"/>\n"]);
%% 		true -> 
%% 			S = [],
%% 			git
%% 	end,
%% 	[S|item(T)];
%% item(_) ->
%% 	[].

formatBatys(List) when length(List)>0 ->
	[H|T] = List,
	Index = string:str(H#ver.url,".git"),
	if
 		Index == 0 ->
 			Bin_url = to_binary(lists:concat([H#ver.url,""])),
			%io:format("~p\n" , [lists:concat([H#ver.url,""])]),
			Bin_url_len = byte_size(Bin_url),
			Bin_v = to_binary(lists:concat([H#ver.v])),
			Bin_v_len = byte_size(Bin_v),
	
			S = binary_to_list(<<Bin_url_len:16,Bin_url/binary,
						 Bin_v_len:16,Bin_v/binary>>);
			%io:format("~p\n" , [H]),
 		true -> 
 			S = [],
 			git
 	end,
	
	[S | formatBatys(T)];
formatBatys(_) ->
	[].

traversalTable(Table,Key) ->
	io:format("current key:~p\n",[Key]),
	[Item] = ets:lookup(Table, Key),
	Content = lists:concat([Key,'?',Item#ver.v,'\n']),
	writePurgedirLog(?PURGE_FILE, Content),
	case ets:next(Table, Key) of
		'$end_of_table' ->
			endTable;
		NextKey ->
			traversalTable(Table,NextKey)
	end.

to_binary(Msg) when is_binary(Msg) -> 
    Msg;
to_binary(Msg) when is_atom(Msg) ->
	list_to_binary(atom_to_list(Msg));
	%%atom_to_binary(Msg, utf8);
to_binary(Msg) when is_list(Msg) -> 
	%io:format("make version:~p\n" ,[Msg]),
	%list_to_binary(Msg);
	unicode:characters_to_binary(Msg);
to_binary(Msg) when is_integer(Msg) -> 
	list_to_binary(integer_to_list(Msg));
to_binary(Msg) when is_float(Msg) -> 
	list_to_binary(f2s(Msg));
to_binary(_Msg) ->
    throw(other_value).

%% @doc convert float to string,  f2s(1.5678) -> 1.57
f2s(N) when is_integer(N) ->
    integer_to_list(N) ++ ".00";
f2s(F) when is_float(F) ->
    [A] = io_lib:format("~.2f", [F]),
	A.

	
	
	
	
	