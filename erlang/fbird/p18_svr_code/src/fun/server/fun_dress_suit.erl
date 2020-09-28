%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% name :  
%% author : Andy lee
%% date :  2017-1-18
%% Company : fbird.Co.Ltd
%% Desc : 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-module(fun_dress_suit).
-include("common.hrl").
-export([req_own_dress_suit/3,update_dress_suit/1,init_dress_suit_prop/1,get_dress_suit_gs/1]).

%%请求拥有的套装
req_own_dress_suit(Uid,Sid,Seq) ->
	List=get_own_dress_suit(Uid),
	Fun=fun(ID) ->
		#pt_public_id_list{
			id = ID
		}
	end,
	Data=lists:map(Fun, List),
	Pt=#pt_dress_suit_data{
		dress_suit_list = Data
	},
	?send(Sid,proto:pack(Pt, Seq)).

%%添加时装
update_dress_suit(Uid) ->	
	fun_property:updata_fighting(Uid).


%%获取拥有的套装
get_own_dress_suit(Uid) ->
	DressList=fun_item_model_clothes:get_all_model_clothes(Uid),
	SkinList=fun_ride:get_curr_own_skins(Uid),
	All=get_all_dress_suit(Uid),
	
	Fun=fun(DressID,{Ret1,Ret2,List}) ->
			{NRet1,NRet2}=match_dress(DressID,List,{Ret1,Ret2}),
			{NRet1,[],NRet2}
		end,
	{R2,_,_}=lists:foldl(Fun, {[],[],All}, DressList),

	Fun2=fun(PetID,{Ret1,Ret2,List}) ->
			{NRet1,NRet2}=match_pet(PetID,List,{Ret1,Ret2}),
			{NRet1,[],NRet2}
		end,	
	{R3,_,_}=lists:foldl(Fun2, {[],[],R2}, SkinList),
	R3.

get_all_dress_suit(Uid) ->
	case db:dirty_get(usr, Uid) of
		[#usr{prof=Prof}|_]->	
			L=data_dress_suit:get_all(),
			Fun=fun(ID) ->
					case data_dress_suit:get_data(ID) of
						#st_dress_suit{prof=Prof} -> true;							
						_ -> false 	
					end
				end,
			lists:filter(Fun, L);	
		_ -> []
	end.

%%符合条件的是Ret1,不满足的Ret2
match_dress(_,[],{Ret1,Ret2}) -> {Ret1,Ret2};
match_dress(DressID,[ID|Next],{Ret1,Ret2}) ->
	case data_dress_suit:get_data(ID) of
		#st_dress_suit{dressid=DressID} ->
			match_dress(DressID,Next,{Ret1++[ID],Ret2});							
		_ -> match_dress(DressID,Next,{Ret1,Ret2++[ID]}) 	
	end.	
%%匹配宠物,函数名写错
% match_ride(_,[],{Ret1,Ret2}) -> {Ret1,Ret2};
% match_ride(MountID,[ID|Next],{Ret1,Ret2}) ->
% 	case data_dress_suit:get_data(ID) of
% 		#st_dress_suit{petid=MountID} ->
% 			match_ride(MountID,Next,{Ret1++[ID],Ret2});
% 		_ -> match_ride(MountID,Next,{Ret1,Ret2++[ID]})
% 	end.
%%匹配坐骑,函数名写错				 
match_pet(_,[],{Ret1,Ret2}) -> {Ret1,Ret2};
match_pet(PetID,[ID|Next],{Ret1,Ret2}) ->
	case data_dress_suit:get_data(ID) of
		#st_dress_suit{mountid=PetID} ->
			match_pet(PetID,Next,{Ret1++[ID],Ret2});
		_ -> match_pet(PetID,Next,{Ret1,Ret2++[ID]})
	end.

init_dress_suit_prop(Uid) ->
	List=get_own_dress_suit(Uid),
	Fun=fun(ID,Acc) ->
				case data_dress_suit:get_data(ID) of
					#st_dress_suit{prop=PropList} ->
						lists:append(Acc, PropList);							
					_ -> Acc
				end	
		end,
	lists:foldl(Fun, [], List).

get_dress_suit_gs(Uid) ->
	List=get_own_dress_suit(Uid),
	Fun=fun(ID,Acc) ->
				case data_dress_suit:get_data(ID) of
					#st_dress_suit{gs=GS} ->
						Acc+GS;							
					_ -> Acc
				end	
		end,
	lists:foldl(Fun, 0, List).




