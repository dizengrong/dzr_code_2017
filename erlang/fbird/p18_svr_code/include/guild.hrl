%% @doc 公会相关的头文件

%% 公会操作类型
-define(GUILD_EVENT_INVITATION, 1).%%邀请成员
-define(GUILD_EVENT_DEVELOPMENT, 2).%%建设科技
-define(GUILD_EVENT_KICKOUT, 3).%%踢出成员
-define(GUILD_EVENT_APPROVAL,4).%%通过成员
-define(GUILD_EVENT_DISSOLUTION,5).%%解散公会
-define(GUILD_EVENT_OPEN_RAID,6).%%开启副本
-define(GUILD_EVENT_QUIT,7).%%退出公会
-define(GUILD_EVENT_PROMOTE_PRESIDENT, 8).%%%%提升会长
-define(GUILD_EVENT_PROMOTE_VICE_PRESIDENT, 9).%%提升副会长
-define(GUILD_EVENT_PROMOTE_ELDERS, 10).%%提升长老
-define(GUILD_EVENT_DEMOTE_MEMBER,11).%%降为成员
-define(GUILD_EVENT_DEMOTE_ELDERS,12).%%降为长老
-define(GUILD_EVENT_DONATE, 13).%%捐献资源
-define(GUILD_EVENT_TECHNOLOGYADDITION,14).%%科技加成
-define(GUILD_EVENT_GDISBAND,15).%%更新公告
-define(GUILD_EVENT_CALL_UPON,16).%%工会号召
-define(GUILD_EVENT_RECRUIT,17).%%发布公会招募
-define(GUILD_EVENT_CHANGE_NAME,18).%%公会改名
-define(GUILD_EVENT_IMPEACH,19).%%公会弹劾
-define(GUILD_EVENT_MAIL,20).%%发送公会邮件
-define(GUILD_EVENT_POINT,21).%%任命官员


-define(PERM_NULL, 0).%%没有
-define(PERM_NORMAL, 3).%%普通成员
-define(PERM_OFFICIAL, 2).%%长老
-define(PERM_PRESIDENT, 1).%%会长

-define(PERM_OFFICIAL_NUM, 2).%%长老人数

-define(REQ_TIMEOUT, 36000).%%申请公会满了隔多久才能申请
-define(REQ_QUIT_GUILD,36000).%%退回多久才能申请公会


-define(GUILD_IMPEACH_PRESIDENT,259200).%%公会弹劾时间
-define(GUILD_PEOPLE_NUM,2).%%公会弹劾人数
-define(MIN_REQ_LEVEL,15).%%公会成员最低等级
-define(MAX_NOTICE_LEN, 100).%%公告最长

-define(ALL_GUILD_LOG,0).%%全部公会信息
-define(PART_GUILD_LOG,1).%%部分公会信息

