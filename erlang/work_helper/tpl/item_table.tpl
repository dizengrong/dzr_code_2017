<table class="hovertable">
	<tr>
		<th>物品id</th><th>物品名</th>
	</tr>
	{% for id, name in item_list %}
		<tr onmouseover="this.style.backgroundColor='#ffff66';" onmouseout="this.style.backgroundColor='#d4e3e5';">
			<td>{{ id }}</td>
			<td>{{ name }}</td>
		</tr>
	{% endfor %}
</table>