<?py def split_items(item_str):?>
<?py 	if item_str.strip() == "":?>
<?py 		return "{}" ?>
<?py 	else: ?>
<?py 		return "{{" + "},{".join(item_str.split("|")) + "}}" ?>
<?py 	#endif ?>
<?py #enddef ?>

local data_item = {
<?py for data in all_data: ?> 
	[${data['ID']}] = 
	{
		sort = ${data['sort']},
		max = ${data['max']},
		name = "${data['name']}",
		req_lv = ${data['req_lv']},
		attribute = ${split_items(data['Attribute'])},
<?py 	data['SpecialAttribute'] = data['SpecialAttribute'].replace('[', '{') ?>
<?py 	data['SpecialAttribute'] = data['SpecialAttribute'].replace(']', '}') ?>
		specialAttribute = ${split_items(data['SpecialAttribute'])},
		des = "${data['Des']}",
		bind = ${data['bind']},
		business = ${data['business']},
		quality = ${data['quality']},
		equip_model = "${data['equip_model']}",
		showType = "${data['showType']}",
		action = ${data['action']},
		action_arg = ${str(data['action_arg']).replace('[', '{').replace(']', '}')},
		action_arg2 = ${str(data['action_arg2']).replace('[', '{').replace(']', '}')},
		price = ${data['price']},
		item_res = "${data['item_res']}",
		multi_open = ${data['multi_open']},
		quickBuy = ${data['quickBuy']},		
		source = {${str(data['Source']).replace('|', ',')}},
		previewScale = ${data['previewScale']},
<?py 	data['previewPosition'] = data['previewPosition'].replace('|', ',') ?>
		previewPosition = {${data['previewPosition']}},
<?py 	data['previewRotation'] = data['previewRotation'].replace('|', ',') ?>
		previewRotation = {${data['previewRotation']}},
<?py 	data['boneEffectList'] = data['boneEffectList'].replace(':', ',') ?>
		boneEffectList = ${split_items(data['boneEffectList'])},
		dropModel = "${data['dropModel']}",
		dropEffect = "${data['dropEffect']}",
		attentionType = "${data['attentionType']}",
		projection = "${data['projection']}",
		dropSound = "${data['dropSound']}",
		openShow = ${data['openShow']},
		iconEff = ${data['iconEff']},
		campIcon = "${data['campIcon']}",
		scrapIcon = "${data['scrapIcon']}",
		classification = ${data['classification']},
		previewStar = ${data['star']},
		order = ${data['order']},
	},
<?py #endfor ?>
}
return data_item
		