-module(ptc_pet_book_list).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D264.

get_name() -> pet_book.

get_des() ->
	 [
	  	{books,{list,pet_skill_books},[]} 	 
	 ].

get_note() -> "宠物技能书". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


