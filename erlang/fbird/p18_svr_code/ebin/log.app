{   
    application, log,
    [   
        {description, "This is log app."},   
        {vsn, "1.0a"},   
        {modules,
		[]},   
        {registered, [log_sup]},
        {applications, [kernel, stdlib]},   
        {mod, {log_app, []}},   
        {start_phases, []}   
    ]   
}.  