<!doctype html>
<html lang="en">
{% include "common_head.tpl" %}
<body>
	{% include "nav.tpl" %}
      <div class="starter-template">
      <p align="left">表的总数：{{ table_num }}</p>
        <table class="hovertable">
			<tr>
			{% for n in col_num %}
				<th>表名</th>
			{% endfor %}
			</tr>
			{% for tabs in tables %}
				<tr onmouseover="this.style.backgroundColor='#ffff66';" onmouseout="this.style.backgroundColor='#d4e3e5';">
				{% for tab in tabs %}
					<td><a href="view_table/{{ tab }}" target="_blank">{{ tab }}</a></td>
					{% endfor %}
				</tr>
			{% endfor %}
		</table>
      </div>

  </body>
</html>


