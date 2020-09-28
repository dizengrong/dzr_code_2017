<!doctype html>
<html lang="en">
{% include "common_head.tpl" %}
<body>
	{% include "nav.tpl" %}
      <div class="starter-template">
		{% for tab, fields, datas in tables %}
		<div style="display:block;font-size:12px;text-align: left;float:left;padding:0px 10px 10px 10px">
	        <table class="hovertable">
	        	<tr><th colspan="{{ fields|length }}" style="text-align: center;">{{ tab }}</th></tr>
				<tr>
				{% for f in fields %}
					<th>{{ f }}</th>
				{% endfor %}
				</tr>
				{% for rec in datas %}
					<tr onmouseover="this.style.backgroundColor='#ffff66';" onmouseout="this.style.backgroundColor='#d4e3e5';">
					{% for val in rec %}
						<td>{{ val }}</td>
					{% endfor %}
					</tr>
				{% endfor %}
			</table>
		</div>
		{% endfor %}
      </div>

  </body>
</html>


