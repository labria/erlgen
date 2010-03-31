{application, <%= @project_name%>,
  [{description, "<%= @project_name%> application"},
   {vsn, "0.2"},
   {modules, [<%= @project_name%>]},
   {registered, []},
   {applications, [kernel, stdlib]},
   {env, []},
   {mod, {<%= @project_name%>, []}}]}.

