-module(fun_property).
-include("common.hrl").

-export([get_property_sort/1,get_base_per_property/0,get_base_property/2,get_monster_property/4,get_robot_property/1,
		 property_add_data/3,property_set_data/3,property_get_data/2,check_hp/2,check_mp/2,
		 make_property_pt/2,make_property_pt/3,get_skill_power1/3,get_skill_power2/3,
		 property_get_data_by_type/1,updata_fighting/1,property_get_scene_show_by_type/1]).
-export([merge_property/1, get_monster_property_by_difficulty/2, get_monster_property_by_addition_attr/2]).
-export([get_lev_fighting/1, get_usr_fighting/1]).
-export([
	property_add/2, property_minus/2, to_property_rec/1, add_attrs_to_property/2, add_attrs_to_property_ex/2,
	minus_attrs_from_property/2, minus_attrs_from_property3/3
]).

get_skill_power1(Oid,Skill,Lev) ->
	case data_skillleveldata:get_skillleveldata(Skill) of
		#st_skillleveldata_config{power1= Power,power1_add=PowerAdd} ->get_inscription_effects_power1(Oid, Power+PowerAdd*(Lev-1), Skill);
		_ -> 0
	end.
get_skill_power2(Oid,Skill,Lev) ->
	case data_skillleveldata:get_skillleveldata(Skill) of
		#st_skillleveldata_config{power2= Power,power2_add=PowerAdd} ->get_inscription_effects_power2(Oid, Power+PowerAdd*(Lev-1), Skill);
		_ -> 0
	end.

get_inscription_effects_power1(Uid,Power,Skill)->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data = #scene_usr_ex{inscription_effects=InscriptionEffects}}->
			case lists:keyfind(Skill, 2, InscriptionEffects) of
				{_SkillMainId,_Skill,_Id,_Lev,Sort,_BuffType,NewBaseatt}->
					case Sort of
						"PowerOne" ->util:ceil((NewBaseatt+1) * Power);
						_->Power
					end;
				_->Power
			end;
		_->Power
	end.

get_inscription_effects_power2(Uid,Power,Skill)->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data = #scene_usr_ex{inscription_effects=InscriptionEffects}}->
			case lists:keyfind(Skill, 2, InscriptionEffects) of
				{_SkillMainId,_Skill,_Id,_Lev,Sort,_BuffType,NewBaseatt}->
					case Sort of
						"PowerTwo" ->util:ceil(Power + NewBaseatt);
						_->Power
					end;
				_->Power
			end;
		_->Power
	end.

make_property_pt(Oid,Propertys) -> make_property_pt(Oid,Propertys,0).
make_property_pt(Oid,Propertys,Seq) ->
	Fun=fun({ProID,ProVal}) ->
		Sort = fun_property:get_property_sort(ProID),
		#pt_public_property{data=ProVal,sort=Sort,type=ProID}
	end,		
	PropList1=lists:map(Fun, Propertys),
	Pt=#pt_update_base{property_list=PropList1,uid=Oid},
	proto:pack(Pt, Seq).

get_property_sort(?PROPERTY_ATK) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_HPLIMIT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_MPLIMIT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_REALDMG) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_DMGDOWN) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_DEFIGNORE) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_DEF) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_CRI) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_CRIDOWN) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_HIT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_DOD) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_CRIDMG) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_TOUGHNESS) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_BLOCKRATE) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_BREAKDEF) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_BREAKDEFRATE) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_BLOCKDMGRATE) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_DMGRATE) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_DMGDOWNRATE) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_CONTORLRATE) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_CONTORLDEFRATE) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_MOVESPD) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_LIMITDMG) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_ATK_PERCENT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_HP_PERCENT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_MP_PERCENT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_REALDMG_PERCENT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_DMGDOWN_PERCENT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_DEFIGNORE_PERCENT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_DEF_PERCENT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_CRI_PERCENT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_CRIDOWN_PERCENT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_HIT_PERCENT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_DOD_PERCENT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_CRIDMG_PERCENT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_TOUGHNESS_PERCENT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_BLOCKRATE_PERCENT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_BREAKDEF_PERCENT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_BREAKDEFRATE_PERCENT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_BLOCKDMGRATE_PERCENT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_DMGRATE_PERCENT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_DMGDOWNRATE_PERCENT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_CONTORLRATE_PERCENT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_CONTORLDEFRATE_PERCENT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_MOVESPD_PERCENT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_LIMITDMG_PERCENT) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(?PROPERTY_GS) -> ?PROPERTY_SORT_BATTLE;
get_property_sort(_) -> ?PROPERTY_SORT_NORMAL.

check_hp(Hp,_) when Hp < 0 -> 0;
check_hp(Hp,_) -> Hp.

check_mp(Mp,_) when Mp < 0 -> 0;
check_mp(Mp,_) -> Mp.


get_base_property(_Prof,_Lev) -> #battle_property{hpLimit = 100}.


get_monster_property_by_addition_attr(Type, Attrs) ->
	case data_monster:get_monster_prop(Type) of
		Config = #st_monster_battle{} ->
			Rec = #battle_property{
				atk            = Config#st_monster_battle.atk,
				hpLimit        = Config#st_monster_battle.hplimit,
				mpLimit        = Config#st_monster_battle.mplimit,
				realdmg        = Config#st_monster_battle.realdmg,
				dmgdown        = Config#st_monster_battle.dmgdown,
				defignore      = Config#st_monster_battle.defignore,
				def            = Config#st_monster_battle.def,
				cri            = Config#st_monster_battle.cri,
				cridown        = Config#st_monster_battle.cridown,
				hit            = Config#st_monster_battle.hit,
				dod            = Config#st_monster_battle.dod,
				cridmg         = Config#st_monster_battle.cridmg,
				toughness      = Config#st_monster_battle.toughness,
				blockrate      = Config#st_monster_battle.blockrate,
				breakdef       = Config#st_monster_battle.breakdef,
				breakdefrate   = Config#st_monster_battle.breakdefrate,
				blockdmgrate   = Config#st_monster_battle.blockdmgrate,
				dmgrate        = Config#st_monster_battle.dmgrate,
				dmgdownrate    = Config#st_monster_battle.dmgdownrate,
				contorlrate    = Config#st_monster_battle.contorlrate,
				contorldefrate = Config#st_monster_battle.contorldefrate,
				movespd        = Config#st_monster_battle.movespd,
				limitdmg       = Config#st_monster_battle.limitdmg
			},
			add_attrs_to_property(Rec, Attrs);
		_ -> #battle_property{}
	end.

get_monster_property_by_difficulty(Type, Difficulty) ->
	case data_monster:get_monster_prop(Type) of
		Config = #st_monster_battle{} ->
			#battle_property{
				atk            = util:ceil(Config#st_monster_battle.atk            * Difficulty#st_dungeon_dificulty.atkPower),
				hpLimit        = util:ceil(Config#st_monster_battle.hplimit        * Difficulty#st_dungeon_dificulty.hpPower),
				mpLimit        = util:ceil(Config#st_monster_battle.mplimit        * Difficulty#st_dungeon_dificulty.mpPower),
				realdmg        = util:ceil(Config#st_monster_battle.realdmg        * Difficulty#st_dungeon_dificulty.realdmgPower),
				dmgdown        = util:ceil(Config#st_monster_battle.dmgdown        * Difficulty#st_dungeon_dificulty.dmgdownPower),
				defignore      = util:ceil(Config#st_monster_battle.defignore      * Difficulty#st_dungeon_dificulty.defignorePower),
				def            = util:ceil(Config#st_monster_battle.def            * Difficulty#st_dungeon_dificulty.defPower),
				cri            = util:ceil(Config#st_monster_battle.cri            * Difficulty#st_dungeon_dificulty.criPower),
				cridown        = util:ceil(Config#st_monster_battle.cridown        * Difficulty#st_dungeon_dificulty.cridownPower),
				hit            = util:ceil(Config#st_monster_battle.hit            * Difficulty#st_dungeon_dificulty.hitPower),
				dod            = util:ceil(Config#st_monster_battle.dod            * Difficulty#st_dungeon_dificulty.dodPower),
				cridmg         = util:ceil(Config#st_monster_battle.cridmg         * Difficulty#st_dungeon_dificulty.cridmgPower),
				toughness      = util:ceil(Config#st_monster_battle.toughness      * Difficulty#st_dungeon_dificulty.toughnessPower),
				blockrate      = util:ceil(Config#st_monster_battle.blockrate      * Difficulty#st_dungeon_dificulty.blockratePower),
				breakdef       = util:ceil(Config#st_monster_battle.breakdef       * Difficulty#st_dungeon_dificulty.breakdefPower),
				breakdefrate   = util:ceil(Config#st_monster_battle.breakdefrate   * Difficulty#st_dungeon_dificulty.breakdefratePower),
				blockdmgrate   = util:ceil(Config#st_monster_battle.blockdmgrate   * Difficulty#st_dungeon_dificulty.blockdmgratePower),
				dmgrate        = util:ceil(Config#st_monster_battle.dmgrate        * Difficulty#st_dungeon_dificulty.dmgratePower),
				dmgdownrate    = util:ceil(Config#st_monster_battle.dmgdownrate    * Difficulty#st_dungeon_dificulty.dmgdownratePower),
				contorlrate    = util:ceil(Config#st_monster_battle.contorlrate    * Difficulty#st_dungeon_dificulty.contorlratePower),
				contorldefrate = util:ceil(Config#st_monster_battle.contorldefrate * Difficulty#st_dungeon_dificulty.contorldefratePower),
				movespd        = util:ceil(Config#st_monster_battle.movespd        * Difficulty#st_dungeon_dificulty.movespdPower),
				limitdmg       = util:ceil(Config#st_monster_battle.limitdmg       * Difficulty#st_dungeon_dificulty.limitdmgPower)
			};
		_ -> #battle_property{}
	end.

get_monster_property(Type,AtkPer,DefPer,HpPer) ->
	case data_monster:get_monster_prop(Type) of
		Config = #st_monster_battle{} ->
			#battle_property{
				atk            = util:ceil(Config#st_monster_battle.atk * AtkPer),
				hpLimit        = util:ceil(Config#st_monster_battle.hplimit * HpPer),
				mpLimit        = Config#st_monster_battle.mplimit,
				realdmg        = Config#st_monster_battle.realdmg,
				dmgdown        = Config#st_monster_battle.dmgdown,
				defignore      = Config#st_monster_battle.defignore,
				def            = util:ceil(Config#st_monster_battle.def * DefPer),
				cri            = Config#st_monster_battle.cri,
				cridown        = Config#st_monster_battle.cridown,
				hit            = Config#st_monster_battle.hit,
				dod            = Config#st_monster_battle.dod,
				cridmg         = Config#st_monster_battle.cridmg,
				toughness      = Config#st_monster_battle.toughness,
				blockrate      = Config#st_monster_battle.blockrate,
				breakdef       = Config#st_monster_battle.breakdef,
				breakdefrate   = Config#st_monster_battle.breakdefrate,
				blockdmgrate   = Config#st_monster_battle.blockdmgrate,
				dmgrate        = Config#st_monster_battle.dmgrate,
				dmgdownrate    = Config#st_monster_battle.dmgdownrate,
				contorlrate    = Config#st_monster_battle.contorlrate,
				contorldefrate = Config#st_monster_battle.contorldefrate,
				movespd        = Config#st_monster_battle.movespd,
				limitdmg       = Config#st_monster_battle.limitdmg
			};
		_ -> #battle_property{}
	end.

get_robot_property(ID) ->
	case data_robot:get_data(ID) of
		#st_robot{} -> #battle_property{hpLimit = 100};
		_ -> #battle_property{}
	end.

get_base_per_property() ->
	#battle_property{}.

property_add(A,B) -> 
	#battle_property{
		atk                    = util:ceil(A#battle_property.atk                    + B#battle_property.atk),
		hpLimit                = util:ceil(A#battle_property.hpLimit                + B#battle_property.hpLimit),
		mpLimit                = util:ceil(A#battle_property.mpLimit                + B#battle_property.mpLimit),
		realdmg                = util:ceil(A#battle_property.realdmg                + B#battle_property.realdmg),
		dmgdown                = util:ceil(A#battle_property.dmgdown                + B#battle_property.dmgdown),
		defignore              = util:ceil(A#battle_property.defignore              + B#battle_property.defignore),
		def                    = util:ceil(A#battle_property.def                    + B#battle_property.def),
		cri                    = util:ceil(A#battle_property.cri                    + B#battle_property.cri),
		cridown                = util:ceil(A#battle_property.cridown                + B#battle_property.cridown),
		hit                    = util:ceil(A#battle_property.hit                    + B#battle_property.hit),
		dod                    = util:ceil(A#battle_property.dod                    + B#battle_property.dod),
		cridmg                 = util:ceil(A#battle_property.cridmg                 + B#battle_property.cridmg),
		toughness              = util:ceil(A#battle_property.toughness              + B#battle_property.toughness),
		blockrate              = util:ceil(A#battle_property.blockrate              + B#battle_property.blockrate),
		breakdef               = util:ceil(A#battle_property.breakdef               + B#battle_property.breakdef),
		breakdefrate           = util:ceil(A#battle_property.breakdefrate           + B#battle_property.breakdefrate),
		blockdmgrate           = util:ceil(A#battle_property.blockdmgrate           + B#battle_property.blockdmgrate),
		dmgrate                = util:ceil(A#battle_property.dmgrate                + B#battle_property.dmgrate),
		dmgdownrate            = util:ceil(A#battle_property.dmgdownrate            + B#battle_property.dmgdownrate),
		contorlrate            = util:ceil(A#battle_property.contorlrate            + B#battle_property.contorlrate),
		contorldefrate         = util:ceil(A#battle_property.contorldefrate         + B#battle_property.contorldefrate),
		movespd                = util:ceil(A#battle_property.movespd                + B#battle_property.movespd),
		limitdmg               = util:ceil(A#battle_property.limitdmg               + B#battle_property.limitdmg),
		atk_percent            = util:ceil(A#battle_property.atk_percent            + B#battle_property.atk_percent),
		hp_percent             = util:ceil(A#battle_property.hp_percent             + B#battle_property.hp_percent),
		mp_percent             = util:ceil(A#battle_property.mp_percent             + B#battle_property.mp_percent),
		realdmg_percent        = util:ceil(A#battle_property.realdmg_percent        + B#battle_property.realdmg_percent),
		dmgdown_percent        = util:ceil(A#battle_property.dmgdown_percent        + B#battle_property.dmgdown_percent),
		defignore_percent      = util:ceil(A#battle_property.defignore_percent      + B#battle_property.defignore_percent),
		def_percent            = util:ceil(A#battle_property.def_percent            + B#battle_property.def_percent),
		cri_percent            = util:ceil(A#battle_property.cri_percent            + B#battle_property.cri_percent),
		cridown_percent        = util:ceil(A#battle_property.cridown_percent        + B#battle_property.cridown_percent),
		hit_percent            = util:ceil(A#battle_property.hit_percent            + B#battle_property.hit_percent),
		dod_percent            = util:ceil(A#battle_property.dod_percent            + B#battle_property.dod_percent),
		cridmg_percent         = util:ceil(A#battle_property.cridmg_percent         + B#battle_property.cridmg_percent),
		toughness_percent      = util:ceil(A#battle_property.toughness_percent      + B#battle_property.toughness_percent),
		blockrate_percent      = util:ceil(A#battle_property.blockrate_percent      + B#battle_property.blockrate_percent),
		breakdef_percent       = util:ceil(A#battle_property.breakdef_percent       + B#battle_property.breakdef_percent),
		breakdefrate_percent   = util:ceil(A#battle_property.breakdefrate_percent   + B#battle_property.breakdefrate_percent),
		blockdmgrate_percent   = util:ceil(A#battle_property.blockdmgrate_percent   + B#battle_property.blockdmgrate_percent),
		dmgrate_percent        = util:ceil(A#battle_property.dmgrate_percent        + B#battle_property.dmgrate_percent),
		dmgdownrate_percent    = util:ceil(A#battle_property.dmgdownrate_percent    + B#battle_property.dmgdownrate_percent),
		contorlrate_percent    = util:ceil(A#battle_property.contorlrate_percent    + B#battle_property.contorlrate_percent),
		contorldefrate_percent = util:ceil(A#battle_property.contorldefrate_percent + B#battle_property.contorldefrate_percent),
		movespd_percent        = util:ceil(A#battle_property.movespd_percent        + B#battle_property.movespd_percent),
		limitdmg_percent       = util:ceil(A#battle_property.limitdmg_percent       + B#battle_property.limitdmg_percent),
		gs                     = util:ceil(A#battle_property.gs                     + B#battle_property.gs)
	}.

property_minus(A,B) -> 
	#battle_property{
		atk                    = util:ceil(A#battle_property.atk                    - B#battle_property.atk),
		hpLimit                = util:ceil(A#battle_property.hpLimit                - B#battle_property.hpLimit),
		mpLimit                = util:ceil(A#battle_property.mpLimit                - B#battle_property.mpLimit),
		realdmg                = util:ceil(A#battle_property.realdmg                - B#battle_property.realdmg),
		dmgdown                = util:ceil(A#battle_property.dmgdown                - B#battle_property.dmgdown),
		defignore              = util:ceil(A#battle_property.defignore              - B#battle_property.defignore),
		def                    = util:ceil(A#battle_property.def                    - B#battle_property.def),
		cri                    = util:ceil(A#battle_property.cri                    - B#battle_property.cri),
		cridown                = util:ceil(A#battle_property.cridown                - B#battle_property.cridown),
		hit                    = util:ceil(A#battle_property.hit                    - B#battle_property.hit),
		dod                    = util:ceil(A#battle_property.dod                    - B#battle_property.dod),
		cridmg                 = util:ceil(A#battle_property.cridmg                 - B#battle_property.cridmg),
		toughness              = util:ceil(A#battle_property.toughness              - B#battle_property.toughness),
		blockrate              = util:ceil(A#battle_property.blockrate              - B#battle_property.blockrate),
		breakdef               = util:ceil(A#battle_property.breakdef               - B#battle_property.breakdef),
		breakdefrate           = util:ceil(A#battle_property.breakdefrate           - B#battle_property.breakdefrate),
		blockdmgrate           = util:ceil(A#battle_property.blockdmgrate           - B#battle_property.blockdmgrate),
		dmgrate                = util:ceil(A#battle_property.dmgrate                - B#battle_property.dmgrate),
		dmgdownrate            = util:ceil(A#battle_property.dmgdownrate            - B#battle_property.dmgdownrate),
		contorlrate            = util:ceil(A#battle_property.contorlrate            - B#battle_property.contorlrate),
		contorldefrate         = util:ceil(A#battle_property.contorldefrate         - B#battle_property.contorldefrate),
		movespd                = util:ceil(A#battle_property.movespd                - B#battle_property.movespd),
		limitdmg               = util:ceil(A#battle_property.limitdmg               - B#battle_property.limitdmg),
		atk_percent            = util:ceil(A#battle_property.atk_percent            - B#battle_property.atk_percent),
		hp_percent             = util:ceil(A#battle_property.hp_percent             - B#battle_property.hp_percent),
		mp_percent             = util:ceil(A#battle_property.mp_percent             - B#battle_property.mp_percent),
		realdmg_percent        = util:ceil(A#battle_property.realdmg_percent        - B#battle_property.realdmg_percent),
		dmgdown_percent        = util:ceil(A#battle_property.dmgdown_percent        - B#battle_property.dmgdown_percent),
		defignore_percent      = util:ceil(A#battle_property.defignore_percent      - B#battle_property.defignore_percent),
		def_percent            = util:ceil(A#battle_property.def_percent            - B#battle_property.def_percent),
		cri_percent            = util:ceil(A#battle_property.cri_percent            - B#battle_property.cri_percent),
		cridown_percent        = util:ceil(A#battle_property.cridown_percent        - B#battle_property.cridown_percent),
		hit_percent            = util:ceil(A#battle_property.hit_percent            - B#battle_property.hit_percent),
		dod_percent            = util:ceil(A#battle_property.dod_percent            - B#battle_property.dod_percent),
		cridmg_percent         = util:ceil(A#battle_property.cridmg_percent         - B#battle_property.cridmg_percent),
		toughness_percent      = util:ceil(A#battle_property.toughness_percent      - B#battle_property.toughness_percent),
		blockrate_percent      = util:ceil(A#battle_property.blockrate_percent      - B#battle_property.blockrate_percent),
		breakdef_percent       = util:ceil(A#battle_property.breakdef_percent       - B#battle_property.breakdef_percent),
		breakdefrate_percent   = util:ceil(A#battle_property.breakdefrate_percent   - B#battle_property.breakdefrate_percent),
		blockdmgrate_percent   = util:ceil(A#battle_property.blockdmgrate_percent   - B#battle_property.blockdmgrate_percent),
		dmgrate_percent        = util:ceil(A#battle_property.dmgrate_percent        - B#battle_property.dmgrate_percent),
		dmgdownrate_percent    = util:ceil(A#battle_property.dmgdownrate_percent    - B#battle_property.dmgdownrate_percent),
		contorlrate_percent    = util:ceil(A#battle_property.contorlrate_percent    - B#battle_property.contorlrate_percent),
		contorldefrate_percent = util:ceil(A#battle_property.contorldefrate_percent - B#battle_property.contorldefrate_percent),
		movespd_percent        = util:ceil(A#battle_property.movespd_percent        - B#battle_property.movespd_percent),
		limitdmg_percent       = util:ceil(A#battle_property.limitdmg_percent       - B#battle_property.limitdmg_percent),
		gs                     = util:ceil(A#battle_property.gs                     - B#battle_property.gs)
	}.

property_multiple(A, AddRate) -> 
	#battle_property{
		atk                    = util:ceil(A#battle_property.atk * (1 + AddRate/10000)),
		hpLimit                = util:ceil(A#battle_property.hpLimit * (1 + AddRate/10000)),
		mpLimit                = util:ceil(A#battle_property.mpLimit * (1 + AddRate/10000)),
		realdmg                = util:ceil(A#battle_property.realdmg * (1 + AddRate/10000)),
		dmgdown                = util:ceil(A#battle_property.dmgdown * (1 + AddRate/10000)),
		defignore              = util:ceil(A#battle_property.defignore * (1 + AddRate/10000)),
		def                    = util:ceil(A#battle_property.def * (1 + AddRate/10000)),
		cri                    = util:ceil(A#battle_property.cri * (1 + AddRate/10000)),
		cridown                = util:ceil(A#battle_property.cridown * (1 + AddRate/10000)),
		hit                    = util:ceil(A#battle_property.hit * (1 + AddRate/10000)),
		dod                    = util:ceil(A#battle_property.dod * (1 + AddRate/10000)),
		cridmg                 = util:ceil(A#battle_property.cridmg * (1 + AddRate/10000)),
		toughness              = util:ceil(A#battle_property.toughness * (1 + AddRate/10000)),
		blockrate              = util:ceil(A#battle_property.blockrate * (1 + AddRate/10000)),
		breakdef               = util:ceil(A#battle_property.breakdef * (1 + AddRate/10000)),
		breakdefrate           = util:ceil(A#battle_property.breakdefrate * (1 + AddRate/10000)),
		blockdmgrate           = util:ceil(A#battle_property.blockdmgrate * (1 + AddRate/10000)),
		dmgrate                = util:ceil(A#battle_property.dmgrate * (1 + AddRate/10000)),
		dmgdownrate            = util:ceil(A#battle_property.dmgdownrate * (1 + AddRate/10000)),
		contorlrate            = util:ceil(A#battle_property.contorlrate * (1 + AddRate/10000)),
		contorldefrate         = util:ceil(A#battle_property.contorldefrate * (1 + AddRate/10000)),
		movespd                = util:ceil(A#battle_property.movespd * (1 + AddRate/10000)),
		limitdmg               = util:ceil(A#battle_property.limitdmg * (1 + AddRate/10000)),
		atk_percent            = util:ceil(A#battle_property.atk_percent * (1 + AddRate/10000)),
		hp_percent             = util:ceil(A#battle_property.hp_percent * (1 + AddRate/10000)),
		mp_percent             = util:ceil(A#battle_property.mp_percent * (1 + AddRate/10000)),
		realdmg_percent        = util:ceil(A#battle_property.realdmg_percent * (1 + AddRate/10000)),
		dmgdown_percent        = util:ceil(A#battle_property.dmgdown_percent * (1 + AddRate/10000)),
		defignore_percent      = util:ceil(A#battle_property.defignore_percent * (1 + AddRate/10000)),
		def_percent            = util:ceil(A#battle_property.def_percent * (1 + AddRate/10000)),
		cri_percent            = util:ceil(A#battle_property.cri_percent * (1 + AddRate/10000)),
		cridown_percent        = util:ceil(A#battle_property.cridown_percent * (1 + AddRate/10000)),
		hit_percent            = util:ceil(A#battle_property.hit_percent * (1 + AddRate/10000)),
		dod_percent            = util:ceil(A#battle_property.dod_percent * (1 + AddRate/10000)),
		cridmg_percent         = util:ceil(A#battle_property.cridmg_percent * (1 + AddRate/10000)),
		toughness_percent      = util:ceil(A#battle_property.toughness_percent * (1 + AddRate/10000)),
		blockrate_percent      = util:ceil(A#battle_property.blockrate_percent * (1 + AddRate/10000)),
		breakdef_percent       = util:ceil(A#battle_property.breakdef_percent * (1 + AddRate/10000)),
		breakdefrate_percent   = util:ceil(A#battle_property.breakdefrate_percent * (1 + AddRate/10000)),
		blockdmgrate_percent   = util:ceil(A#battle_property.blockdmgrate_percent * (1 + AddRate/10000)),
		dmgrate_percent        = util:ceil(A#battle_property.dmgrate_percent * (1 + AddRate/10000)),
		dmgdownrate_percent    = util:ceil(A#battle_property.dmgdownrate_percent * (1 + AddRate/10000)),
		contorlrate_percent    = util:ceil(A#battle_property.contorlrate_percent * (1 + AddRate/10000)),
		contorldefrate_percent = util:ceil(A#battle_property.contorldefrate_percent * (1 + AddRate/10000)),
		movespd_percent        = util:ceil(A#battle_property.movespd_percent * (1 + AddRate/10000)),
		limitdmg_percent       = util:ceil(A#battle_property.limitdmg_percent * (1 + AddRate/10000)),
		gs                     = util:ceil(A#battle_property.gs * (1 + AddRate/10000))
	}.

property_add_data(P,?PROPERTY_ATK,Data) -> P#battle_property{atk = P#battle_property.atk + Data};
property_add_data(P,?PROPERTY_HPLIMIT,Data) -> P#battle_property{hpLimit = P#battle_property.hpLimit + Data};
property_add_data(P,?PROPERTY_MPLIMIT,Data) -> P#battle_property{mpLimit = P#battle_property.mpLimit + Data};
property_add_data(P,?PROPERTY_REALDMG,Data) -> P#battle_property{realdmg = P#battle_property.realdmg + Data};
property_add_data(P,?PROPERTY_DMGDOWN,Data) -> P#battle_property{dmgdown = P#battle_property.dmgdown + Data};
property_add_data(P,?PROPERTY_DEFIGNORE,Data) -> P#battle_property{defignore = P#battle_property.defignore + Data};
property_add_data(P,?PROPERTY_DEF,Data) -> P#battle_property{def = P#battle_property.def + Data};
property_add_data(P,?PROPERTY_CRI,Data) -> P#battle_property{cri = P#battle_property.cri + Data};
property_add_data(P,?PROPERTY_CRIDOWN,Data) -> P#battle_property{cridown = P#battle_property.cridown + Data};
property_add_data(P,?PROPERTY_HIT,Data) -> P#battle_property{hit = P#battle_property.hit + Data};
property_add_data(P,?PROPERTY_DOD,Data) -> P#battle_property{dod = P#battle_property.dod + Data};
property_add_data(P,?PROPERTY_CRIDMG,Data) -> P#battle_property{cridmg = P#battle_property.cridmg + Data};
property_add_data(P,?PROPERTY_TOUGHNESS,Data) -> P#battle_property{toughness = P#battle_property.toughness + Data};
property_add_data(P,?PROPERTY_BLOCKRATE,Data) -> P#battle_property{blockrate = P#battle_property.blockrate + Data};
property_add_data(P,?PROPERTY_BREAKDEF,Data) -> P#battle_property{breakdef = P#battle_property.breakdef + Data};
property_add_data(P,?PROPERTY_BREAKDEFRATE,Data) -> P#battle_property{breakdefrate = P#battle_property.breakdefrate + Data};
property_add_data(P,?PROPERTY_BLOCKDMGRATE,Data) -> P#battle_property{blockdmgrate = P#battle_property.blockdmgrate + Data};
property_add_data(P,?PROPERTY_DMGRATE,Data) -> P#battle_property{dmgrate = P#battle_property.dmgrate + Data};
property_add_data(P,?PROPERTY_DMGDOWNRATE,Data) -> P#battle_property{dmgdownrate = P#battle_property.dmgdownrate + Data};
property_add_data(P,?PROPERTY_CONTORLRATE,Data) -> P#battle_property{contorlrate = P#battle_property.contorlrate + Data};
property_add_data(P,?PROPERTY_CONTORLDEFRATE,Data) -> P#battle_property{contorldefrate = P#battle_property.contorldefrate + Data};
property_add_data(P,?PROPERTY_MOVESPD,Data) -> P#battle_property{movespd = P#battle_property.movespd + Data};
property_add_data(P,?PROPERTY_LIMITDMG,Data) -> P#battle_property{limitdmg = P#battle_property.limitdmg + Data};
property_add_data(P,?PROPERTY_ATK_PERCENT,Data) -> P#battle_property{atk_percent = P#battle_property.atk_percent + Data};
property_add_data(P,?PROPERTY_HP_PERCENT,Data) -> P#battle_property{hp_percent = P#battle_property.hp_percent + Data};
property_add_data(P,?PROPERTY_MP_PERCENT,Data) -> P#battle_property{mp_percent = P#battle_property.mp_percent + Data};
property_add_data(P,?PROPERTY_REALDMG_PERCENT,Data) -> P#battle_property{realdmg_percent = P#battle_property.realdmg_percent + Data};
property_add_data(P,?PROPERTY_DMGDOWN_PERCENT,Data) -> P#battle_property{dmgdown_percent = P#battle_property.dmgdown_percent + Data};
property_add_data(P,?PROPERTY_DEFIGNORE_PERCENT,Data) -> P#battle_property{defignore_percent = P#battle_property.defignore_percent + Data};
property_add_data(P,?PROPERTY_DEF_PERCENT,Data) -> P#battle_property{def_percent = P#battle_property.def_percent + Data};
property_add_data(P,?PROPERTY_CRI_PERCENT,Data) -> P#battle_property{cri_percent = P#battle_property.cri_percent + Data};
property_add_data(P,?PROPERTY_CRIDOWN_PERCENT,Data) -> P#battle_property{cridown_percent = P#battle_property.cridown_percent + Data};
property_add_data(P,?PROPERTY_HIT_PERCENT,Data) -> P#battle_property{hit_percent = P#battle_property.hit_percent + Data};
property_add_data(P,?PROPERTY_DOD_PERCENT,Data) -> P#battle_property{dod_percent = P#battle_property.dod_percent + Data};
property_add_data(P,?PROPERTY_CRIDMG_PERCENT,Data) -> P#battle_property{cridmg_percent = P#battle_property.cridmg_percent + Data};
property_add_data(P,?PROPERTY_TOUGHNESS_PERCENT,Data) -> P#battle_property{toughness_percent = P#battle_property.toughness_percent + Data};
property_add_data(P,?PROPERTY_BLOCKRATE_PERCENT,Data) -> P#battle_property{blockrate_percent = P#battle_property.blockrate_percent + Data};
property_add_data(P,?PROPERTY_BREAKDEF_PERCENT,Data) -> P#battle_property{breakdef_percent = P#battle_property.breakdef_percent + Data};
property_add_data(P,?PROPERTY_BREAKDEFRATE_PERCENT,Data) -> P#battle_property{breakdefrate_percent = P#battle_property.breakdefrate_percent + Data};
property_add_data(P,?PROPERTY_BLOCKDMGRATE_PERCENT,Data) -> P#battle_property{blockdmgrate_percent = P#battle_property.blockdmgrate_percent + Data};
property_add_data(P,?PROPERTY_DMGRATE_PERCENT,Data) -> P#battle_property{dmgrate_percent = P#battle_property.dmgrate_percent + Data};
property_add_data(P,?PROPERTY_DMGDOWNRATE_PERCENT,Data) -> P#battle_property{dmgdownrate_percent = P#battle_property.dmgdownrate_percent + Data};
property_add_data(P,?PROPERTY_CONTORLRATE_PERCENT,Data) -> P#battle_property{contorlrate_percent = P#battle_property.contorlrate_percent + Data};
property_add_data(P,?PROPERTY_CONTORLDEFRATE_PERCENT,Data) -> P#battle_property{contorldefrate_percent = P#battle_property.contorldefrate_percent + Data};
property_add_data(P,?PROPERTY_MOVESPD_PERCENT,Data) -> P#battle_property{movespd_percent = P#battle_property.movespd_percent + Data};
property_add_data(P,?PROPERTY_LIMITDMG_PERCENT,Data) -> P#battle_property{limitdmg_percent = P#battle_property.limitdmg_percent + Data};
property_add_data(P,?PROPERTY_GS,Data) -> P#battle_property{gs = P#battle_property.gs + Data}.

property_get_data(P,?PROPERTY_ATK) -> P#battle_property.atk;
property_get_data(P,?PROPERTY_HPLIMIT) -> P#battle_property.hpLimit;
property_get_data(P,?PROPERTY_MPLIMIT) -> P#battle_property.mpLimit;
property_get_data(P,?PROPERTY_REALDMG) -> P#battle_property.realdmg;
property_get_data(P,?PROPERTY_DMGDOWN) -> P#battle_property.dmgdown;
property_get_data(P,?PROPERTY_DEFIGNORE) -> P#battle_property.defignore;
property_get_data(P,?PROPERTY_DEF) -> P#battle_property.def;
property_get_data(P,?PROPERTY_CRI) -> P#battle_property.cri;
property_get_data(P,?PROPERTY_CRIDOWN) -> P#battle_property.cridown;
property_get_data(P,?PROPERTY_HIT) -> P#battle_property.hit;
property_get_data(P,?PROPERTY_DOD) -> P#battle_property.dod;
property_get_data(P,?PROPERTY_CRIDMG) -> P#battle_property.cridmg;
property_get_data(P,?PROPERTY_TOUGHNESS) -> P#battle_property.toughness;
property_get_data(P,?PROPERTY_BLOCKRATE) -> P#battle_property.blockrate;
property_get_data(P,?PROPERTY_BREAKDEF) -> P#battle_property.breakdef;
property_get_data(P,?PROPERTY_BREAKDEFRATE) -> P#battle_property.breakdefrate;
property_get_data(P,?PROPERTY_BLOCKDMGRATE) -> P#battle_property.blockdmgrate;
property_get_data(P,?PROPERTY_DMGRATE) -> P#battle_property.dmgrate;
property_get_data(P,?PROPERTY_DMGDOWNRATE) -> P#battle_property.dmgdownrate;
property_get_data(P,?PROPERTY_CONTORLRATE) -> P#battle_property.contorlrate;
property_get_data(P,?PROPERTY_CONTORLDEFRATE) -> P#battle_property.contorldefrate;
property_get_data(P,?PROPERTY_MOVESPD) -> P#battle_property.movespd;
property_get_data(P,?PROPERTY_LIMITDMG) -> P#battle_property.limitdmg;
property_get_data(P,?PROPERTY_ATK_PERCENT) -> P#battle_property.atk_percent;
property_get_data(P,?PROPERTY_HP_PERCENT) -> P#battle_property.hp_percent;
property_get_data(P,?PROPERTY_MP_PERCENT) -> P#battle_property.mp_percent;
property_get_data(P,?PROPERTY_REALDMG_PERCENT) -> P#battle_property.realdmg_percent;
property_get_data(P,?PROPERTY_DMGDOWN_PERCENT) -> P#battle_property.dmgdown_percent;
property_get_data(P,?PROPERTY_DEFIGNORE_PERCENT) -> P#battle_property.defignore_percent;
property_get_data(P,?PROPERTY_DEF_PERCENT) -> P#battle_property.def_percent;
property_get_data(P,?PROPERTY_CRI_PERCENT) -> P#battle_property.cri_percent;
property_get_data(P,?PROPERTY_CRIDOWN_PERCENT) -> P#battle_property.cridown_percent;
property_get_data(P,?PROPERTY_HIT_PERCENT) -> P#battle_property.hit_percent;
property_get_data(P,?PROPERTY_DOD_PERCENT) -> P#battle_property.dod_percent;
property_get_data(P,?PROPERTY_CRIDMG_PERCENT) -> P#battle_property.cridmg_percent;
property_get_data(P,?PROPERTY_TOUGHNESS_PERCENT) -> P#battle_property.toughness_percent;
property_get_data(P,?PROPERTY_BLOCKRATE_PERCENT) -> P#battle_property.blockrate_percent;
property_get_data(P,?PROPERTY_BREAKDEF_PERCENT) -> P#battle_property.breakdef_percent;
property_get_data(P,?PROPERTY_BREAKDEFRATE_PERCENT) -> P#battle_property.breakdefrate_percent;
property_get_data(P,?PROPERTY_BLOCKDMGRATE_PERCENT) -> P#battle_property.blockdmgrate_percent;
property_get_data(P,?PROPERTY_DMGRATE_PERCENT) -> P#battle_property.dmgrate_percent;
property_get_data(P,?PROPERTY_DMGDOWNRATE_PERCENT) -> P#battle_property.dmgdownrate_percent;
property_get_data(P,?PROPERTY_CONTORLRATE_PERCENT) -> P#battle_property.contorlrate_percent;
property_get_data(P,?PROPERTY_CONTORLDEFRATE_PERCENT) -> P#battle_property.contorldefrate_percent;
property_get_data(P,?PROPERTY_MOVESPD_PERCENT) -> P#battle_property.movespd_percent;
property_get_data(P,?PROPERTY_LIMITDMG_PERCENT) -> P#battle_property.limitdmg_percent;
property_get_data(P,?PROPERTY_GS) -> P#battle_property.gs;
property_get_data(_P,_) -> 0.


property_set_data(P,?PROPERTY_ATK,Data) -> P#battle_property{atk = Data};
property_set_data(P,?PROPERTY_HPLIMIT,Data) -> P#battle_property{hpLimit = Data};
property_set_data(P,?PROPERTY_MPLIMIT,Data) -> P#battle_property{mpLimit = Data};
property_set_data(P,?PROPERTY_REALDMG,Data) -> P#battle_property{realdmg = Data};
property_set_data(P,?PROPERTY_DMGDOWN,Data) -> P#battle_property{dmgdown = Data};
property_set_data(P,?PROPERTY_DEFIGNORE,Data) -> P#battle_property{defignore = Data};
property_set_data(P,?PROPERTY_DEF,Data) -> P#battle_property{def = Data};
property_set_data(P,?PROPERTY_CRI,Data) -> P#battle_property{cri = Data};
property_set_data(P,?PROPERTY_CRIDOWN,Data) -> P#battle_property{cridown = Data};
property_set_data(P,?PROPERTY_HIT,Data) -> P#battle_property{hit = Data};
property_set_data(P,?PROPERTY_DOD,Data) -> P#battle_property{dod = Data};
property_set_data(P,?PROPERTY_CRIDMG,Data) -> P#battle_property{cridmg = Data};
property_set_data(P,?PROPERTY_TOUGHNESS,Data) -> P#battle_property{toughness = Data};
property_set_data(P,?PROPERTY_BLOCKRATE,Data) -> P#battle_property{blockrate = Data};
property_set_data(P,?PROPERTY_BREAKDEF,Data) -> P#battle_property{breakdef = Data};
property_set_data(P,?PROPERTY_BREAKDEFRATE,Data) -> P#battle_property{breakdefrate = Data};
property_set_data(P,?PROPERTY_BLOCKDMGRATE,Data) -> P#battle_property{blockdmgrate = Data};
property_set_data(P,?PROPERTY_DMGRATE,Data) -> P#battle_property{dmgrate = Data};
property_set_data(P,?PROPERTY_DMGDOWNRATE,Data) -> P#battle_property{dmgdownrate = Data};
property_set_data(P,?PROPERTY_CONTORLRATE,Data) -> P#battle_property{contorlrate = Data};
property_set_data(P,?PROPERTY_CONTORLDEFRATE,Data) -> P#battle_property{contorldefrate = Data};
property_set_data(P,?PROPERTY_MOVESPD,Data) -> P#battle_property{movespd = Data};
property_set_data(P,?PROPERTY_LIMITDMG,Data) -> P#battle_property{limitdmg = Data};
property_set_data(P,?PROPERTY_ATK_PERCENT,Data) -> P#battle_property{atk_percent = Data};
property_set_data(P,?PROPERTY_HP_PERCENT,Data) -> P#battle_property{hp_percent = Data};
property_set_data(P,?PROPERTY_MP_PERCENT,Data) -> P#battle_property{mp_percent = Data};
property_set_data(P,?PROPERTY_REALDMG_PERCENT,Data) -> P#battle_property{realdmg_percent = Data};
property_set_data(P,?PROPERTY_DMGDOWN_PERCENT,Data) -> P#battle_property{dmgdown_percent = Data};
property_set_data(P,?PROPERTY_DEFIGNORE_PERCENT,Data) -> P#battle_property{defignore_percent = Data};
property_set_data(P,?PROPERTY_DEF_PERCENT,Data) -> P#battle_property{def_percent = Data};
property_set_data(P,?PROPERTY_CRI_PERCENT,Data) -> P#battle_property{cri_percent = Data};
property_set_data(P,?PROPERTY_CRIDOWN_PERCENT,Data) -> P#battle_property{cridown_percent = Data};
property_set_data(P,?PROPERTY_HIT_PERCENT,Data) -> P#battle_property{hit_percent = Data};
property_set_data(P,?PROPERTY_DOD_PERCENT,Data) -> P#battle_property{dod_percent = Data};
property_set_data(P,?PROPERTY_CRIDMG_PERCENT,Data) -> P#battle_property{cridmg_percent = Data};
property_set_data(P,?PROPERTY_TOUGHNESS_PERCENT,Data) -> P#battle_property{toughness_percent = Data};
property_set_data(P,?PROPERTY_BLOCKRATE_PERCENT,Data) -> P#battle_property{blockrate_percent = Data};
property_set_data(P,?PROPERTY_BREAKDEF_PERCENT,Data) -> P#battle_property{breakdef_percent = Data};
property_set_data(P,?PROPERTY_BREAKDEFRATE_PERCENT,Data) -> P#battle_property{breakdefrate_percent = Data};
property_set_data(P,?PROPERTY_BLOCKDMGRATE_PERCENT,Data) -> P#battle_property{blockdmgrate_percent = Data};
property_set_data(P,?PROPERTY_DMGRATE_PERCENT,Data) -> P#battle_property{dmgrate_percent = Data};
property_set_data(P,?PROPERTY_DMGDOWNRATE_PERCENT,Data) -> P#battle_property{dmgdownrate_percent = Data};
property_set_data(P,?PROPERTY_CONTORLRATE_PERCENT,Data) -> P#battle_property{contorlrate_percent = Data};
property_set_data(P,?PROPERTY_CONTORLDEFRATE_PERCENT,Data) -> P#battle_property{contorldefrate_percent = Data};
property_set_data(P,?PROPERTY_MOVESPD_PERCENT,Data) -> P#battle_property{movespd_percent = Data};
property_set_data(P,?PROPERTY_LIMITDMG_PERCENT,Data) -> P#battle_property{limitdmg_percent = Data};
property_set_data(P,?PROPERTY_GS,Data) -> P#battle_property{gs = Data}.

%%属性列表
property_get_data_by_type(BattleInfo)->
	[
		{?PROPERTY_ATK                    , BattleInfo#battle_property.atk},
		{?PROPERTY_HPLIMIT                , BattleInfo#battle_property.hpLimit},
		{?PROPERTY_MPLIMIT                , BattleInfo#battle_property.mpLimit},
		{?PROPERTY_REALDMG                , BattleInfo#battle_property.realdmg},
		{?PROPERTY_DMGDOWN                , BattleInfo#battle_property.dmgdown},
		{?PROPERTY_DEFIGNORE              , BattleInfo#battle_property.defignore},
		{?PROPERTY_DEF                    , BattleInfo#battle_property.def},
		{?PROPERTY_CRI                    , BattleInfo#battle_property.cri},
		{?PROPERTY_CRIDOWN                , BattleInfo#battle_property.cridown},
		{?PROPERTY_HIT                    , BattleInfo#battle_property.hit},
		{?PROPERTY_DOD                    , BattleInfo#battle_property.dod},
		{?PROPERTY_CRIDMG                 , BattleInfo#battle_property.cridmg},
		{?PROPERTY_TOUGHNESS              , BattleInfo#battle_property.toughness},
		{?PROPERTY_BLOCKRATE              , BattleInfo#battle_property.blockrate},
		{?PROPERTY_BREAKDEF               , BattleInfo#battle_property.breakdef},
		{?PROPERTY_BREAKDEFRATE           , BattleInfo#battle_property.breakdefrate},
		{?PROPERTY_BLOCKDMGRATE           , BattleInfo#battle_property.blockdmgrate},
		{?PROPERTY_DMGRATE                , BattleInfo#battle_property.dmgrate},
		{?PROPERTY_DMGDOWNRATE            , BattleInfo#battle_property.dmgdownrate},
		{?PROPERTY_CONTORLRATE            , BattleInfo#battle_property.contorlrate},
		{?PROPERTY_CONTORLDEFRATE         , BattleInfo#battle_property.contorldefrate},
		{?PROPERTY_MOVESPD                , BattleInfo#battle_property.movespd},
		{?PROPERTY_LIMITDMG               , BattleInfo#battle_property.limitdmg},
		{?PROPERTY_ATK_PERCENT            , BattleInfo#battle_property.atk_percent},
		{?PROPERTY_HP_PERCENT             , BattleInfo#battle_property.hp_percent},
		{?PROPERTY_MP_PERCENT             , BattleInfo#battle_property.mp_percent},
		{?PROPERTY_REALDMG_PERCENT        , BattleInfo#battle_property.realdmg_percent},
		{?PROPERTY_DMGDOWN_PERCENT        , BattleInfo#battle_property.dmgdown_percent},
		{?PROPERTY_DEFIGNORE_PERCENT      , BattleInfo#battle_property.defignore_percent},
		{?PROPERTY_DEF_PERCENT            , BattleInfo#battle_property.def_percent},
		{?PROPERTY_CRI_PERCENT            , BattleInfo#battle_property.cri_percent},
		{?PROPERTY_CRIDOWN_PERCENT        , BattleInfo#battle_property.cridown_percent},
		{?PROPERTY_HIT_PERCENT            , BattleInfo#battle_property.hit_percent},
		{?PROPERTY_DOD_PERCENT            , BattleInfo#battle_property.dod_percent},
		{?PROPERTY_CRIDMG_PERCENT         , BattleInfo#battle_property.cridmg_percent},
		{?PROPERTY_TOUGHNESS_PERCENT      , BattleInfo#battle_property.toughness_percent},
		{?PROPERTY_BLOCKRATE_PERCENT      , BattleInfo#battle_property.blockrate_percent},
		{?PROPERTY_BREAKDEF_PERCENT       , BattleInfo#battle_property.breakdef_percent},
		{?PROPERTY_BREAKDEFRATE_PERCENT   , BattleInfo#battle_property.breakdefrate_percent},
		{?PROPERTY_BLOCKDMGRATE_PERCENT   , BattleInfo#battle_property.blockdmgrate_percent},
		{?PROPERTY_DMGRATE_PERCENT        , BattleInfo#battle_property.dmgrate_percent},
		{?PROPERTY_DMGDOWNRATE_PERCENT    , BattleInfo#battle_property.dmgdownrate_percent},
		{?PROPERTY_CONTORLRATE_PERCENT    , BattleInfo#battle_property.contorlrate_percent},
		{?PROPERTY_CONTORLDEFRATE_PERCENT , BattleInfo#battle_property.contorldefrate_percent},
		{?PROPERTY_MOVESPD_PERCENT        , BattleInfo#battle_property.movespd_percent},
		{?PROPERTY_LIMITDMG_PERCENT       , BattleInfo#battle_property.limitdmg_percent},
		{?PROPERTY_GS                     , BattleInfo#battle_property.gs}
	].

property_get_scene_show_by_type(BattleInfo)->
	[
	 {?PROPERTY_HPLIMIT,fun_property:property_get_data(BattleInfo,?PROPERTY_HPLIMIT)}
	].

to_property_rec(PropList) -> 
	Fun = fun({ID,Val}, Acc) ->
		property_add_data(Acc, ID, Val)
	end,
	lists:foldl(Fun, #battle_property{}, PropList).

updata_fighting(_Uid)-> 0.

get_usr_fighting(Uid) -> 
	case db:dirty_get(usr, Uid) of
		[#usr{fighting=Fighting}|_]->
			Fighting;
		_ -> 
			0
	end.

get_lev_fighting(_Usr) -> 100.

%%发送战力到场景
% send_fighting_bank(Uid,Fighting) ->
% 	fun_agent:send_to_scene({update_fighting,Uid,Fighting}).
% 	SceneHid=get(scene_hid),
% 	if
% 		erlang:is_pid(SceneHid) ->
% 			gen_server:cast(SceneHid, {update_fighting,Uid,Fighting});
% 		true -> skip
% 	end.	


merge_property(PropertyList) ->
	merge_property2(PropertyList, []).

merge_property2([], Acc) -> Acc;
merge_property2([{Id, Val} | Rest], Acc) ->
	Acc2 = case lists:keyfind(Id, 1, Acc) of
		false -> [{Id, Val} | Acc];
		{_, OldVal} -> 
			T = {Id, Val + OldVal},
			lists:keystore(Id, 1, Acc, T) 
	end,
	merge_property2(Rest, Acc2).

%% 将属性列表加到属性record里去
%% PropRec:#battle_property{} Attrs有不同的格式可以在这里扩展
add_attrs_to_property_ex(PropRec, Attrs) ->
	case Attrs of
		{all, AddRate} ->
			property_multiple(PropRec, AddRate);
		undefined -> PropRec;
		_ when is_list(Attrs) -> 
			add_attrs_to_property(PropRec, Attrs)
	end.

%% 将属性列表加到属性record里去
%% PropRec:#battle_property{} Attrs:[{AttrId, Val}]
add_attrs_to_property(PropRec, Attrs) ->
	add_attrs_to_property2(PropRec, Attrs).

add_attrs_to_property2(PropRec, [{AttrId, Val} | Rest]) ->
	PropRec2 = property_add_data(PropRec, AttrId, Val),
	add_attrs_to_property2(PropRec2, Rest);
add_attrs_to_property2(PropRec, []) -> PropRec.


%% 将属性列表从属性record里减去
%% PropRec:#battle_property{} Attrs:[{AttrId, Val}]
minus_attrs_from_property(PropRec, Attrs) ->
	minus_attrs_from_property2(PropRec, Attrs).

minus_attrs_from_property2(PropRec, [{AttrId, Val} | Rest]) -> 
	case ?DEBUG_MODE of
		true -> 
			CurrentVal = property_get_data(PropRec, AttrId),
			case CurrentVal >= Val of
				false -> 
					?ERROR("minus attr error, AttrId:~p, CurrentVal:~p, Val:~p", [AttrId, CurrentVal, Val]);
				_ -> skip
			end;
		_ -> skip
	end,
	PropRec2 = property_add_data(PropRec, AttrId, -Val),
	minus_attrs_from_property2(PropRec2, Rest);
minus_attrs_from_property2(PropRec, []) -> PropRec.


%% 这个作为临时测试用，回头改为调用minus_attrs_from_property/2
minus_attrs_from_property3(Obj, PropRec, Attrs) -> 
	minus_attrs_from_property32(Obj, PropRec, Attrs).

minus_attrs_from_property32(Obj, PropRec, [{AttrId, Val} | Rest]) -> 
	case ?DEBUG_MODE of
		true -> 
			CurrentVal = property_get_data(PropRec, AttrId),
			case CurrentVal >= Val of
				false -> 
					?ERROR("minus attr error, AttrId:~p, CurrentVal:~p, Val:~p", [AttrId, CurrentVal, Val]),
					case Obj of
						#scene_spirit_ex{data = #scene_usr_ex{}} ->
							ok;
							_ -> skip
						end;
				_ -> skip
			end;
		_ -> skip
	end,
	PropRec2 = property_add_data(PropRec, AttrId, -Val),
	minus_attrs_from_property32(Obj, PropRec2, Rest);
minus_attrs_from_property32(_Obj, PropRec, []) -> PropRec.

