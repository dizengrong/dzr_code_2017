
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>场景列表</title>
</head>

<body>
	<!-- CSS goes in the document HEAD or added to your external stylesheet -->
	<style type="text/css">
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
	<table class="hovertable">
		<tr>
			<th>场景id</th><th>场景名称</th><th>入口X坐标</th><th>入口Z坐标</th>
		</tr>
		{% for id, name, inx, inz in scene_list %}
			<tr onmouseover="this.style.backgroundColor='#ffff66';" onmouseout="this.style.backgroundColor='#d4e3e5';">
				<td>{{ id }}</td>
				<td>{{ name }}</td>
				<td>{{ inx }}</td>
				<td>{{ inz }}</td>
			</tr>
		{% endfor %}

	</table>


</body>

</html>
