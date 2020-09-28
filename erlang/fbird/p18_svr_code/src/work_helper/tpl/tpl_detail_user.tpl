
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>玩家详细数据</title>
</head>

<body>
	<!-- CSS goes in the document HEAD or added to your external stylesheet -->
	<style type="text/css">
		a {
			color:green;
		}
		table.hovertable {
			font-family: verdana,arial,sans-serif;
			font-size:10px;
			color:#333333;
			border-width: 10px;
			border-color: #999999;
			border-collapse: collapse;
		}
		table.hovertable th {
			background-color:#c3dde0;
			border-width: 1px;
			padding: 8px;
			border-style: solid;
			border-color: #a9c6c9;
		}
		table.hovertable tr {
			background-color:#d4e3e5;
		}
		table.hovertable td {
			border-width: 1px;
			padding: 3px;
			border-style: solid;
			border-color: #a9c6c9;
		}
		table.hovertable td {
			text-align: center;
		}
	</style>

	<div id="main_list" style="float:left;padding-bottom:10px;padding-right:20px">
		<table class="hovertable">
			<tr>
				<th colspan="7" style="text-align: center;">{{user_name}}的详细属性</th>
			</tr>
			<tr>
				<th>属性名称</th>
				<th>属性字段</th>
				<th>agent进程值</th>
				<th>scene进程值</th>
				<th>agent、scene值是否相等</th>
			</tr>
			{% for fieldname, field, agent_val, scene_val, buff_val, buff_per_val in battle_property %}
			<tr onmouseover="this.style.backgroundColor='#ffff66';" onmouseout="this.style.backgroundColor='#d4e3e5';">
				<td>{{ fieldname }}</td>
				<td>{{ field }}</td>
				<td>{{ agent_val }}</td>
				<td>{{ scene_val }}</td>
				{% if agent_val == scene_val %}
				<td>true</td>
				{% else %}
				<td style="color:red">false</td>
				{% endif %}

			</tr>
			{% endfor %}
		</table>
	</div>

	<div style="float:left; width:900px">
		{% for name, data_list in all_module_property %}
		<div style="display:block;font-size:12px;text-align: left;float:left;padding:0px 5px 5px 5px">
			<table class="hovertable">
				<tr><th colspan="2" style="text-align: center;">{{ name }}</th></tr>
				<tr>
					<th>属性名称</th>
					<th>属性值</th>
				</tr>
				{% for fieldname, field_atom, val in data_list %}
				<tr onmouseover="this.style.backgroundColor='#ffff66';" onmouseout="this.style.backgroundColor='#d4e3e5';">
					<td>{{ fieldname }}</td>
					<td>{{ val }}</td>
	
				</tr>
				{% endfor %}
			</table>
		</div>
		{% endfor %}
	</div>

	<div style="float:left; padding-left:10px; padding-top:10px; clear:left">
		<table class="hovertable">
			<tr>
				<th colspan="11" style="text-align: center;">{{user_name}}穿戴的装备</th>
			</tr>
			<tr>
				<th>名称</th>
				<th>唯一id</th>
				<th>类型</th>
				<th>颜色</th>
				<th>等级</th>
				<th>星级</th>
				<th>随机属性</th>
				<th>神装</th>
				<th>铭文1</th>
				<th>铭文2</th>
				<th>铭文3</th>
			</tr>
			{% for e in all_equip %}
			<tr onmouseover="this.style.backgroundColor='#ffff66';" onmouseout="this.style.backgroundColor='#d4e3e5';">
				<td>{{ e.name }}</td>
				<td>{{ e.id }}</td>
				<td>{{ e.type }}</td>
				<td>{{ e.color }}</td>
				<td>{{ e.lev }}</td>
				<td>{{ e.star }}</td>
				<td style="padding:1px;">{{ e.property_random }}</td>
				<td>{{ e.special_lv }}</td>
				<td>{{ e.imprinting1 }}</td>
				<td>{{ e.imprinting2 }}</td>
				<td>{{ e.imprinting3 }}</td>
			</tr>
			{% endfor %}
		</table>
	</div>

	<div id="property_list" style="display:block;font-size:12px;text-align: left;float:left;padding:10px 10px 10px 10px;">
		<table class="hovertable">
			<tr>
				<th colspan="1" style="text-align: center; color: red;">玩家身上的buff列表</th>
			</tr>
			<tr>
				<th>buff type</th>
			</tr>
			{% for b in buff %}
				<tr onmouseover="this.style.backgroundColor='#ffff66';" onmouseout="this.style.backgroundColor='#d4e3e5';">
					<td style="text-align: center;">{{b}}</td>
				</tr>
			{% endfor %}
		</table>
	</div> 
	<div id="property_list" style="display:block;font-size:12px;text-align: left;float:left;padding:10px 10px 10px 10px;">
		<table class="hovertable">
			<tr>
				<th colspan="2" style="text-align: center; color: red;">玩家身上的buff加的属性</th>
			</tr>
			<tr>
				<th>buff type</th>
				<th>buff 增加的属性</th>
			</tr>
			{% for buff, attr in buff_attrs %}
				<tr onmouseover="this.style.backgroundColor='#ffff66';" onmouseout="this.style.backgroundColor='#d4e3e5';">
					<td style="text-align: center;">{{buff}}</td>
					<td style="text-align: center;">{{attr.1}}：{{attr.2}}</td>
				</tr>
			{% endfor %}
		</table>
	</div> 

	<div id="property_list" style="display:block;font-size:12px;text-align: left;float:left;padding:10px 10px 10px 10px;">
		<table class="hovertable">
			<tr>
				<th colspan="2" style="text-align: center;">战力来源列表</th>
			</tr>
			<tr>
				<th style="text-align: center;">来源</th>
				<th style="text-align: center;">数值</th>
			</tr>
			{% for label, val in all_module_fighting %}
				<tr onmouseover="this.style.backgroundColor='#ffff66';" onmouseout="this.style.backgroundColor='#d4e3e5';">
					<td style="text-align: center;">{{label}}</td>
					<td style="text-align: center;">{{val}}</td>
				</tr>
			{% endfor %}
		</table>
	</div> 



</body>

</html>
