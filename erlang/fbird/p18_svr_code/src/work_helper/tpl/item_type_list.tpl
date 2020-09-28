<!doctype html>
<html lang="en">
{% include "common_head.tpl" %}
<body>
	{% include "nav.tpl" %}
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
	{% for a, sub_list in item_list %}
		<div style="float:left;padding:1px 1px 1px 20px;line-height:0.5">
			<table class="hovertable">
				<tr><th>item id</th><th>item name</th></tr>
				{% for id, color, name in sub_list %}
					<tr onmouseover="this.style.backgroundColor='#ffff66';" onmouseout="this.style.backgroundColor='#d4e3e5';">
						<td>{{ id }}</td>
						<!-- <td style="color:{{color}}">{{ name }}</td> -->
						<td>{{ name }}</td>
					</tr>
				{% endfor %}
			</table>
		</div>
	{% endfor %}

	<!-- <div style="float:left;padding:1px 1px 1px 20px;">
		{% include "item_table.tpl" %}
	</div>

</body>

</html>
