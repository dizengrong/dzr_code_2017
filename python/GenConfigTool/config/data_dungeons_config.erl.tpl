-module(data_dungeons_config).
-include("common.hrl").
-compile(export_all).


<?py for data in all_data: ?>
get_dungeons(${data[0]}) -> #st_dungeons_config{
	id              = ${data[0]},
	dungenScene     = ${data[3]},
	dungeonScript   = ${data[4]},
	dungeonLvl      = ${data[5]},
	resetBaseCost   = ${data[8]},
	playerNum       = ${data[9]},
	finishReward    = ${data[14]},
	maxPlayerNum    = ${data[16]},
	rewardExp       = ${data[17]},
	rewardCoin      = ${data[18]},
	failExp         = ${data[19]},
	failCoin        = ${data[20]},
	rebornTimes     = ${data[21]},
	matchingId      = ${data[23]},
	sweepboxid      = ${data[25]},
	dungeonsType    = "${data[22]}",
	cost            = ${data[26]},
	front           = ${data[27]},
	first           = ${data[28]},
	firstNum        = ${data[29]},
	monsterId       = [${", ".join(data[30].split("|"))}],
	bossId          = ${data[31]},
	monDrop         = ${data[32]},
	stageAward      = ${data[33]},
	nextStage       = ${data[34]},
	offLineMoneyGet = ${data[35]},
	offLineExpGet   = ${data[36]},
	offLineItemGet  = ${data[37]},
	wave            = ${data[40]},
	difficulty      = {${data[38]}}
}; 
<?py #endfor ?>
get_dungeons(_) -> {}.

<?py for data in all_data: ?>
select(${data[3]}) -> [${data[0]}];
<?py #endfor ?>
select(_) -> [].

