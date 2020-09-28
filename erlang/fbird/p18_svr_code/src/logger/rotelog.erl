-module(rotelog).

-export([start/1]).

start(Node_list)->
	[{error_logger,Node} ! {user_command,srv_logger_rotate_file} || Node<-Node_list].
