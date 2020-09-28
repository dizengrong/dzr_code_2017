%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% author : wangming
%% date :  2016-4-7
%% Company : fbird.Co.Ltd
%% Desc : fun_item_model_clothes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-module(fun_item_model_clothes).
-include("common.hrl").
-export([req_model_clothes_info/3,add_model_clothes/2,req_upgrade_model_clothes/4,req_model_clothes_dress/4,get_model_clothes_gs/1,get_all_model_clothes/1
		,check_model_clothes/2,get_model_clothes_dress/1,check_model_clothes_type/1,get_model_clothes_prop/1,req_model_clothes_unfix/3,
		 req_active_clothes/4, on_login/1]).

%% =============================================================================
get_data(Uid) -> 
	case mod_role_tab:lookup(Uid, t_clothes) of
		[] -> #t_clothes{uid = Uid};
		[Rec] -> Rec
	end.

% set_data(Rec) -> 
% 	mod_role_tab:insert(Rec#t_clothes.uid, Rec).

get_clothes(Uid) -> 
	Rec = get_data(Uid),
	Rec#t_clothes.clothes.

% set_one_clothes(Uid, Clothes) -> 
% 	Rec = get_data(Uid),
% 	List = lists:keystore(Clothes#model_clothes.clothes_type, #model_clothes.clothes_type, Rec#t_clothes.clothes, Clothes),
% 	set_data(Rec#t_clothes{clothes = List}).
%% =============================================================================

get_all_model_clothes(Uid) ->
	case db:dirty_get(model_clothes, Uid, #model_clothes.uid) of
		List when is_list(List)->
			Fun=fun(#model_clothes{clothes_type=Type},Acc)-> Acc++[Type] end,
			lists:foldl(Fun, [], List);
		_->[]
	end.


%%请求所有时装数据
req_model_clothes_info(Sid,Seq,Uid)->
	case db:dirty_get(model_clothes, Uid, #model_clothes.uid) of
		ModelClothesList when is_list(ModelClothesList)->
			Fun = fun(#model_clothes{activity_state=ActivityState,clothes_type=Type,lev=Lev},Acc)->
						  Acc++[{ActivityState,Type,Lev}]
				  end,
			List = lists:foldl(Fun, [], ModelClothesList),
			send_item_model_clothes(Sid, List, Seq);
		_->skip
	end.

%%请求穿戴时装
req_model_clothes_dress(Sid,Uid,Seq,ModelId)->
	case db:dirty_match(model_clothes, #model_clothes{uid=Uid,activity_state=2,clothes_type=ModelId,_='_'}) of
		[_]->skip;%%已经穿了这套时装
		_->
			case db:dirty_match(model_clothes, #model_clothes{uid=Uid,activity_state=2,_='_'}) of
				[ModelClothes = #model_clothes{clothes_type=ClothesType,lev = Lev}|_]->
					case db:dirty_match(model_clothes, #model_clothes{uid=Uid,clothes_type=ModelId,_='_'}) of
						[NewModelClothes = #model_clothes{lev = Lev1}|_]->
							db:dirty_put(ModelClothes#model_clothes{activity_state=1}),
							db:dirty_put(NewModelClothes#model_clothes{activity_state=2}),
							send_item_model_clothes(Sid, [{1,ClothesType,Lev},{2,ModelId,Lev1}], Seq),
							fun_item:send_all_usr_items_to_sid(Sid, Uid, []),
							fun_property:updata_fighting(Uid),
							fun_agent:send_to_scene({update_model_clothes, Uid,ModelId}),
							fun_task_count:process_count_event(task_model_clothes,{0,0,1},Uid,Sid);
%% 							case get(scene_hid) of				
%% 								SceneHid when erlang:is_pid(SceneHid) -> 
%% 									gen_server:cast(SceneHid, {update_model_clothes, Uid,ModelId});
%% 								_->skip
%% 							end;
						_->skip
					end;
				_->
					case db:dirty_match(model_clothes, #model_clothes{uid=Uid,clothes_type=ModelId,_='_'}) of
						[NewModelClothes = #model_clothes{lev = Lev1}|_]->
							db:dirty_put(NewModelClothes#model_clothes{activity_state=2}),
							send_item_model_clothes(Sid, [{2,ModelId,Lev1}], Seq),
							fun_item:send_all_usr_items_to_sid(Sid, Uid, []),
							fun_property:updata_fighting(Uid),
							fun_agent:send_to_scene({update_model_clothes, Uid,ModelId}),
							fun_task_count:process_count_event(task_model_clothes,{0,0,1},Uid,Sid);
%% 							case get(scene_hid) of				
%% 								SceneHid when erlang:is_pid(SceneHid) -> 
%% 									gen_server:cast(SceneHid, {update_model_clothes, Uid,ModelId});
%% 								_->skip
%% 							end;
						_->skip
					end
			end
	end.

get_model_clothes_dress(Uid)->
	List = get_clothes(Uid),
	case lists:keyfind(2, #model_clothes.activity_state, List) of
		#model_clothes{clothes_type=ClothesType} -> ClothesType;
		_ ->0
	end.
%%请求脱下时装
req_model_clothes_unfix(Sid,Uid,Seq)->
	case db:dirty_match(model_clothes, #model_clothes{uid=Uid,activity_state=2,_='_'}) of
		[ModelClothes = #model_clothes{clothes_type=ClothesType,lev=Lev}|_]-> 
			db:dirty_put(ModelClothes#model_clothes{activity_state=1}),
			send_item_model_clothes(Sid, [{1,ClothesType,Lev}], Seq),
			fun_item:send_all_usr_items_to_sid(Sid, Uid, []);
		_->skip
	end.
			

%%添加时装
add_model_clothes(Uid,ModelId)->
	case check_model_clothes(Uid, ModelId) of
		false->
			Sid = util:get_sid_by_uid(Uid),
			db:insert(#model_clothes{uid=Uid,clothes_type=ModelId,activity_state=1,lev=1}),
			req_model_clothes_dress(Sid, Uid, 0, ModelId);
			%%添加时装时更新套装,上面已经更新了,不用重复更新
			%%fun_dress_suit:update_dress_suit(Uid);
		_->skip
	end.
%%检查是否有这个时装
check_model_clothes(Uid,ModelId)->
	case db:dirty_get(model_clothes, Uid, #model_clothes.uid) of
		[] -> false;
		List -> 
			case lists:keyfind(ModelId, #model_clothes.clothes_type, List) of
				false -> false;
				_ -> true
			end
	end.
%%时装升级
req_upgrade_model_clothes(_Sid,_Uid,_ModelId,_Seq)->
%% 	case db:dirty_match(model_clothes, #model_clothes{uid=Uid,clothes_type=ModelId,_='_'}) of
%% 		[ModelClothes = #model_clothes{lev=Lev,activity_state=State}|_]->
%% 			case data_model_clothes:get_data(ModelId) of
%% 				#st_model_clothes{dressItem=DressItem,upgradeItem=UpgradeItem,incUpgradeNum=IncUpgradeNum,maxLv=MaxLv}->
%% 						if MaxLv > Lev->
%% 							NeedNum = UpgradeItem + (Lev-1) * IncUpgradeNum,
%% 							case fun_item:check_item_num(Uid, DressItem, NeedNum) of
%% 								true->
%% 									db:dirty_put(ModelClothes#model_clothes{lev=Lev+1}),
%% 									fun_item:del_item_by_type(Uid, Sid, DressItem, NeedNum,?ITEM_WAY_DRESS_UP),
%% 									send_item_model_clothes(Sid, [{State,ModelId,Lev+1}], Seq),
%% 									fun_property:updata_fighting(Uid);
%% 								_->skip
%% 							end;
%% 						   true->skip
%% 						end;
%% 				_->skip
%% 			end;
%% 		_->skip
%% 	end.
ok.
	
%%检查是否是时装物品
check_model_clothes_type(Type)->
	case data_item:get_data(Type) of
		#st_item_type{sort = 203}->true;
		_->false
	end.
						   
%%时装属性
get_model_clothes_prop(Uid)->
	case db:dirty_get(model_clothes, Uid, #model_clothes.uid) of
		ModelClothesList when is_list(ModelClothesList)->
			Fun = fun(#model_clothes{clothes_type=Type,lev=Lev},Acc)->
						  Acc++[{Type,Lev}]
				  end,
			List = lists:foldl(Fun, [], ModelClothesList),
			lists:foldl(fun({ModelId,Lev},Acc)->Acc ++ model_clothes_prop(ModelId, Lev) end, [], List);
		_->[]
	end.
%%时装战力
get_model_clothes_gs(Uid)->
	case db:dirty_get(model_clothes, Uid, #model_clothes.uid) of
		ModelClothesList when is_list(ModelClothesList)->
			Fun = fun(#model_clothes{clothes_type=Type,lev=Lev,activity_state=_State},Acc)-> 
						  Acc+model_clothes_gs(Type, Lev)
				  end,
			lists:foldl(Fun,0, ModelClothesList);
		_->0
	end.
model_clothes_prop(ModelId,_Lev)->
	case data_model_clothes:get_data(ModelId) of
		#st_model_clothes{attribute=BaseProp}->
			Fun = fun({PropType,PropNum},Acc)->
								 Acc ++ [{PropType,PropNum}]
				  end,
			lists:foldl(Fun, [], BaseProp);
		_->[]
	end.

model_clothes_gs(ModelId,_Lev)->
	case data_model_clothes:get_data(ModelId) of
		#st_model_clothes{power=BaseGS}->
			BaseGS;
		_->0
	end.
%%发送协议
send_item_model_clothes(Sid,List,Seq)->
	Fun = fun({ActivityState,Type,Lev})->
		#pt_public_item_model_clothes{state=ActivityState,type=Type,lev=Lev}
	end,
	NewList = lists:map(Fun, List),
	Pt = #pt_item_model_clothes{item_model_clothes=NewList},
	?send(Sid,proto:pack(Pt,Seq)).



%%激活时装
req_active_clothes(Uid, Sid, _Seq, ModelId)->
	case data_model_clothes:get_data(ModelId) of
		#st_model_clothes{dressitem=Need_item,active_num=Need_num} ->
			SuccCallBack = fun() ->
								   add_model_clothes(Uid, ModelId)	end,
			fun_item_api:check_and_add_items(Uid, Sid, [{?ITEM_WAY_DRESS_UP, Need_item, Need_num}], [], SuccCallBack, undefined),
			ok;
		_->
			skip
	end.


%%玩家登录时，自动获得默认时装
on_login(Uid)->
	case db:dirty_get(usr, Uid) of
		[#usr{prof=Prof}] ->
			ModelId = get_normal_clothes(Prof),
			case check_model_clothes(Uid, ModelId) of
				false ->
					add_model_clothes(Uid, ModelId);
				_->skip
			end;
		_->skip
	end.
%%策划要求写死
get_normal_clothes(3)-> 101;
get_normal_clothes(6)-> 102;
get_normal_clothes(9)-> 103.






