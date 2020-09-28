<!doctype html>
<html lang="en">
{% include "common_head.tpl" %}
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
					<td><a href="gm_codes/{{ url1 }}">{{ arg1 }}</a></td>
				{% else %}
					<td>{{ arg1 }}</td>
				{% endif %}

				{% if url2 != ""  %}
					<td><a href="gm_codes/{{ url2 }}" target="_blank">{{ arg2 }}</a></td>
				{% else %}
					<td>{{ arg2 }}</td>
				{% endif %}

				{% if url3 != ""  %}
					<td><a href="gm_codes/{{ url3 }}" target="_blank">{{ arg3 }}</a></td>
				{% else %}
					<td>{{ arg3 }}</td>
				{% endif %}

				{% if url4 != ""  %}
					<td><a href="gm_codes/{{ url4 }}" target="_blank">{{ arg4 }}</a></td>
				{% else %}
					<td>{{ arg4 }}</td>
				{% endif %}

				{% if url5 != ""  %}
					<td><a href="gm_codes/{{ url5 }}" target="_blank">{{ arg5 }}</a></td>
				{% else %}
					<td>{{ arg5 }}</td>
				{% endif %}

				<td>{{ descripte }}</td>
			</tr>
		{% endfor %}

	</table>
	</div>

	<div style="float:left; padding-left:10px;">
	<table class="hovertable">
		<tr>
			<th>属性名称</th><th>属性id</th>
		</tr>
		{% for attrid, attrval in attr_list1 %}
			<tr onmouseover="this.style.backgroundColor='#ffff66';" onmouseout="this.style.backgroundColor='#d4e3e5';">
				<td>{{ attrid }}</td>
				<td>{{ attrval }}</td>
			</tr>
		{% endfor %}

	</table>
	</div>
	<div style="float:left; padding-left:10px;">
	<table class="hovertable">
		<tr>
			<th>属性名称</th><th>属性id</th>
		</tr>
		{% for attrid, attrval in attr_list2 %}
			<tr onmouseover="this.style.backgroundColor='#ffff66';" onmouseout="this.style.backgroundColor='#d4e3e5';">
				<td>{{ attrid }}</td>
				<td>{{ attrval }}</td>
			</tr>
		{% endfor %}

	</table>
	</div>


</body>

</html>
