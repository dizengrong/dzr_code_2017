%% Feel free to use, reuse and abuse the code in this file.

{application, work_helper, [
	{description, "work_helper_app"},
	{vsn, "1"},
	{modules, []},
	{registered, [work_helper_sup]},
	{applications, [
		kernel,
		stdlib
	]},
	{mod, {work_helper_app, []}},
	{env, []}
]}.
