%% Feel free to use, reuse and abuse the code in this file.

{application, rsync_service, [
	{description, "rsync_service_app"},
	{vsn, "1"},
	{modules, []},
	{registered, [hello_world_sup]},
	{applications, [
		kernel,
		stdlib
	]},
	{mod, {rsync_service_app, []}},
	{env, []}
]}.
