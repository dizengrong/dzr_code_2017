
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>GM命令</title>
</head>

<body>
	{% include "nav.tpl" %}
	<!-- CSS goes in the document HEAD or added to your external stylesheet -->
	<style type="text/css">
		a {
			color:green;
		}
		table.hovertable {
			font-family: verdana,arial,sans-serif;
			font-size:11px;
			color:#333333;
			border-width: 1px;
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
			padding: 8px;
			border-style: solid;
			border-color: #a9c6c9;
		}
		table.hovertable td {
			text-align: left;
		}
	</style>

	<!-- Table goes in the document BODY -->
	<div style="float:left">
	<table class="hovertable">
		<tr>
			<th>GM命令</th><th>参数1</th><th>参数2</th><th>参数3</th><th>参数4</th><th>参数5</th><th>描述</th>
		</tr>
		{% for cmd, url1, arg1, url2, arg2, url3, arg3, url4, arg4, url5, arg5, descripte in cmd_list %}
			<tr onmouseover="this.style.backgroundColor='#ffff66';" onmouseout="this.style.backgroundColor='#d4e3e5';">
				<td>{{ cmd }}</td>
				{% if url1 != ""  %}
					<td><a href="/{{ url1 }}" target="_blank">{{ arg1 }}</a></td>
				{% else %}
					<td>{{ arg1 }}</td>
				{% endif %}

				{% if url2 != ""  %}
					<td><a href="/{{ url2 }}" target="_blank">{{ arg2 }}</a></td>
				{% else %}
					<td>{{ arg2 }}</td>
				{% endif %}

				{% if url3 != ""  %}
					<td><a href="/{{ url3 }}" target="_blank">{{ arg3 }}</a></td>
				{% else %}
					<td>{{ arg3 }}</td>
				{% endif %}

				{% if url4 != ""  %}
					<td><a href="/{{ url4 }}" target="_blank">{{ arg4 }}</a></td>
				{% else %}
					<td>{{ arg4 }}</td>
				{% endif %}

				{% if url5 != ""  %}
					<td><a href="/{{ url5 }}" target="_blank">{{ arg5 }}</a></td>
				{% else %}
					<td>{{ arg5 }}</td>
				{% endif %}

				<td>{{ descripte }}</td>
			</tr>
		{% endfor %}

	</table>
	</div>

	<!-- <div style="float:right;border:1px blue solid;">
	<p>aaaa</p>
	</div> -->

	<div id="property_list" style="display:block;border:1px solid #ffe9b3;color:#666;font-size:12px;background-color:#ffffcc;padding:10px;text-align: left;float:right;">战斗属性表:
	<a style="margin-left:300px;" href="#" onclick="javascript:document.getElementById('property_list').style.display='none';return false;">关闭</a> 
		<table >
			<tr>
				<th>属性id</th><th>属性名称</th>
			</tr>
			{% for id1, name1, id2, name2 in property_list %}
				<tr>
					<td style="background-color:#d4e3e5;text-align: center;">{{id1}}</td>
					<td style="background-color:#d4e3e5;text-align: center;">{{name1}}</td>
					<td style="background-color:#d4e3e5;text-align: center;">{{id2}}</td>
					<td style="background-color:#d4e3e5;text-align: center;">{{name2}}</td>
				</tr>
			{% endfor %}
		</table>
	</div> 

	<div id="property_list" style="display:block;font-size:12px;text-align: left;float:left;padding:1px 1px 1px 20px;">
		<table class="hovertable">
			<tr>
				<th colspan="2" style="text-align: center;">颜色品质表</th>
			</tr>
			<tr>
				<th>颜色id</th><th>颜色名</th>
			</tr>
			{% for id, name, color in color_list %}
				<tr onmouseover="this.style.backgroundColor='#ffff66';" onmouseout="this.style.backgroundColor='#d4e3e5';">
					<td style="text-align: center;">{{id}}</td>
					<td style="text-align: center;color:{{color}}">{{name}}</td>
				</tr>
			{% endfor %}
		</table>
	</div> 

</body>

</html>
