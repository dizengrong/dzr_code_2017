<!doctype html>
<html lang="en">
{% include "common_head.tpl" %}
<body>
	{% include "nav.tpl" %}
      <div class="starter-template">
		<div style="display:block;font-size:12px;text-align: left;float:left;padding:0px 10px 10px 10px">
	        <table class="hovertable">
				<tr>
					<th>注册名称</th>
					<th>进程</th>
					<th>操作</th>
				</tr>
				{% for reg_name, pid in scenes %}
					<tr onmouseover="this.style.backgroundColor='#ffff66';" onmouseout="this.style.backgroundColor='#d4e3e5';">
						<td>{{ reg_name }}</td>
						<td>{{ pid }}</td>
						<td><a href="scenes/{{ pid }}" target="_blank">查看</a></td>
					</tr>
				{% endfor %}
			</table>
		</div>
      </div>

  </body>
</html>


