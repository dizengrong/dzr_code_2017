%% Feel free to use, reuse and abuse the code in this file.

{application, work_helper, [
	{description, "work_helper_app"},
	{vsn, "1"},
	{modules, ['work_helper_app','work_helper_main','work_helper_sup']},
	{registered, [work_helper_sup]},
	{applications, [
		kernel,
		stdlib
	]},
	{mod, {work_helper_app, []}},
	{env, []}
]}.
