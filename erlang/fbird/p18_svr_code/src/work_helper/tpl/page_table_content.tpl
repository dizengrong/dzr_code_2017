<!doctype html>
<html lang="en">
{% include "common_head.tpl" %}
<body>
	{% include "nav.tpl" %}
      <div class="starter-template">
      <p align="left">表中记录数：{{ table_size }}</p>
      <nav aria-label="Page navigation example">
			  <ul class="pagination">
			  {% for p in page_size_list %}
			  	{% if p == page %}
			    <li class="page-item active"><a class="page-link" href="?page={{ p }}">{{ p }} <span class="sr-only">(current)</span></a></li>
			  	{% else %}
			    <li class="page-item"><a class="page-link" href="?page={{ p }}">{{ p }}</a></li>
			  	{% endif %}
			  {% endfor %}
			  </ul>
		  </nav>
        <table class="hovertable">
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

  </body>
</html>


