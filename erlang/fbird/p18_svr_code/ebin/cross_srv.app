%% This is the application resource file (.app file) for the 'base'
%% application.
{application, cross_srv,
[{description, "cross server"},
 {vsn, "0.0.1"},
 {modules, [ cross_srv_app, cross_srv_sup]},
 {registered,[cross_srv]},
 {applications, [kernel,stdlib]},
 {mod, {cross_srv_app,[]}},
 {start_phases, []}
]}.

