%%%-------------------------------------------------------------------
%%% Author  : Author Name 
%%% @doc The top level supervisor for our application.
%%% @end
%%%-------------------------------------------------------------------
-module(<%= @project_name%>_sup).

-behaviour(supervisor).

%%--------------------------------------------------------------------
%% External exports
%%--------------------------------------------------------------------
-export([start_link/1]).

%%--------------------------------------------------------------------
%% Internal exports
%%--------------------------------------------------------------------
-export([init/1]).

%%--------------------------------------------------------------------
%% Macros
%%--------------------------------------------------------------------
-define(SERVER, ?MODULE).

%%====================================================================
%% External functions
%%====================================================================
%%--------------------------------------------------------------------
%% @doc Starts the supervisor.
%% @spec start_link(StartArgs) -> {ok, pid()} | Error
%% @end
%%--------------------------------------------------------------------
start_link(StartArgs) ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Server functions
%%====================================================================
%%--------------------------------------------------------------------
%% Func: init/1
%% Returns: {ok,  {SupFlags,  [ChildSpec]}} |
%%          ignore                          |
%%          {error, Reason}
%%--------------------------------------------------------------------
init([]) ->
    RestartStrategy    = one_for_one,
    MaxRestarts        = 1000,
    MaxTimeBetRestarts = 3600,

    SupFlags = {RestartStrategy, MaxRestarts, MaxTimeBetRestarts},
    
    %% Replace <%= @project_name%>_server with your actual module
    ChildSpecs =
    [
     {<%= @project_name%>_server,
      {<%= @project_name%>_server, start_link, []},
      permanent,
      1000,
      worker,
      [<%= @project_name%>_server]}
     ],
    {ok,{SupFlags, ChildSpecs}}.

