%% -*- coding: utf-8 -*-

%% @doc 属性表
-module (property_code_list).
-include("common.hrl").
-compile([export_all]).

all() ->
	[
		% {?PROPERTY_STR, "力量"},
		% {?PROPERTY_AGI, "敏捷"},
		% {?PROPERTY_STA, "耐力"},
		% {?PROPERTY_WIS, "智力"},
		% {?PROPERTY_SPI, "精神"},
		% {?PROPERTY_ATK, "攻击"},
		% {?PROPERTY_DEF, "防御"},
		% {?PROPERTY_DEFIGNORE, "穿透，忽略护甲百分比"},
		% {?PROPERTY_HPLIMIT, "生命上限"},
		% {?PROPERTY_MPLIMIT, "法力上限"},
		% {?PROPERTY_CRI, "暴击"},
		% {?PROPERTY_CRIDMG, "暴击伤害"},
		% {?PROPERTY_TOUGH, "韧性"},
		% {?PROPERTY_HIT, "命中"},
		% {?PROPERTY_DOD, "闪避"},
		% {?PROPERTY_CD, "CD"},
		% {?PROPERTY_DMGRATE, "增伤比率"},
		% {?PROPERTY_DMGDOWNRATE, "免伤比率"},
		% {?PROPERTY_BLOCKRATE, "格挡"},
		% {?PROPERTY_BLOCKDMGRATE, "格挡免伤比率"},
		% {?PROPERTY_REALDMG, "真实伤害"},
		% {?PROPERTY_STIFLE, "压制"},
		% {?PROPERTY_LONGSUFFERING, "坚忍"},
		% {?PROPERTY_MOVESPD, "移动速度"},
		% {?PROPERTY_FIRSTAID, "急救术回复"}
	].


% battle_field_2_name(str) -> ?PROPERTY_STR;
% battle_field_2_name(agi) -> ?PROPERTY_AGI;
% battle_field_2_name(sta) -> ?PROPERTY_STA;
% battle_field_2_name(wis) -> ?PROPERTY_WIS;
% battle_field_2_name(spi) -> ?PROPERTY_SPI;
% battle_field_2_name(atk) -> ?PROPERTY_ATK;
% battle_field_2_name(def) -> ?PROPERTY_DEF;
% battle_field_2_name(defignore) -> ?PROPERTY_DEFIGNORE;
% battle_field_2_name(hpLimit) -> ?PROPERTY_HPLIMIT;
% battle_field_2_name(mpLimit) -> ?PROPERTY_MPLIMIT;
% battle_field_2_name(cri) -> ?PROPERTY_CRI;
% battle_field_2_name(criDmg) -> ?PROPERTY_CRIDMG;
% battle_field_2_name(tough) -> ?PROPERTY_TOUGH;
% battle_field_2_name(hit) -> ?PROPERTY_HIT;
% battle_field_2_name(dod) -> ?PROPERTY_DOD;
% battle_field_2_name(cd) -> ?PROPERTY_CD;
% battle_field_2_name(dmgRate) -> ?PROPERTY_DMGRATE;
% battle_field_2_name(dmgDownRate) -> ?PROPERTY_DMGDOWNRATE;
% battle_field_2_name(blockRate) -> ?PROPERTY_BLOCKRATE;
% battle_field_2_name(blockDownRate) -> ?PROPERTY_BLOCKDMGRATE;
% battle_field_2_name(realDmg) -> ?PROPERTY_REALDMG;
% battle_field_2_name(stifle) -> ?PROPERTY_STIFLE;
% battle_field_2_name(longSuffering) -> ?PROPERTY_LONGSUFFERING;
% battle_field_2_name(moveSpd) -> ?PROPERTY_MOVESPD;
% battle_field_2_name(firstaid) -> ?PROPERTY_FIRSTAID;
battle_field_2_name(_) -> undefined.


% property_id_2_name(?PROPERTY_STR) -> battle_field_2_name(str);
% property_id_2_name(?PROPERTY_AGI) -> battle_field_2_name(agi);
% property_id_2_name(?PROPERTY_STA) -> battle_field_2_name(sta);
% property_id_2_name(?PROPERTY_WIS) -> battle_field_2_name(wis);
% property_id_2_name(?PROPERTY_SPI) -> battle_field_2_name(spi);
% property_id_2_name(?PROPERTY_ATK) -> battle_field_2_name(atk);
% property_id_2_name(?PROPERTY_DEF) -> battle_field_2_name(def);
% property_id_2_name(?PROPERTY_DEFIGNORE) -> battle_field_2_name(defIgnore);
% property_id_2_name(?PROPERTY_HPLIMIT) -> battle_field_2_name(hpLimit);
% property_id_2_name(?PROPERTY_MPLIMIT) -> battle_field_2_name(mpLimit);
% property_id_2_name(?PROPERTY_CRI) -> battle_field_2_name(cri);
% property_id_2_name(?PROPERTY_CRIDMG) -> battle_field_2_name(criDmg);
% property_id_2_name(?PROPERTY_TOUGH) -> battle_field_2_name(tough);
% property_id_2_name(?PROPERTY_HIT) -> battle_field_2_name(hit);
% property_id_2_name(?PROPERTY_DOD) -> battle_field_2_name(dod);
% property_id_2_name(?PROPERTY_CD) -> battle_field_2_name(cd);
% property_id_2_name(?PROPERTY_DMGRATE) -> battle_field_2_name(dmgRate);
% property_id_2_name(?PROPERTY_DMGDOWNRATE) -> battle_field_2_name(dmgDownRate);
% property_id_2_name(?PROPERTY_BLOCKRATE) -> battle_field_2_name(blockRate);
% property_id_2_name(?PROPERTY_BLOCKDMGRATE) -> battle_field_2_name(blockDownRate);
% property_id_2_name(?PROPERTY_REALDMG) -> battle_field_2_name(realDmg);
% property_id_2_name(?PROPERTY_STIFLE) -> battle_field_2_name(stifle);
% property_id_2_name(?PROPERTY_LONGSUFFERING) -> battle_field_2_name(longSuffering);
% property_id_2_name(?PROPERTY_MOVESPD) -> battle_field_2_name(moveSpd);
% property_id_2_name(?PROPERTY_FIRSTAID) -> battle_field_2_name(firstaid);
property_id_2_name(_) -> undefined.