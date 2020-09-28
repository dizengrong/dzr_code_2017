<!doctype html>
<html lang="en">
{% include "common_head.tpl" %}
<body>
	{% include "nav.tpl" %}
      <div class="starter-template">
        <table class="hovertable">
			<tr>
				<th>账号id</th>
				<th>账号名</th>
				<th>账号密码</th>
				<th>角色id</th>
				<th>角色名</th>
				<th>创建时间</th>
				<th>职业</th>
				<th>性别</th>
				<th>当前等级</th>
				<th>当前所在场景id</th>
				<th>操作</th>
				<th>操作</th>
				<th>操作</th>
				<th>操作</th>
			</tr>
			{% for ply in online_users %}
				<tr onmouseover="this.style.backgroundColor='#ffff66';" onmouseout="this.style.backgroundColor='#d4e3e5';">
					<td>{{ ply.aid }}</td>
					<td>{{ ply.account_name }}</td>
					<td>{{ ply.password }}</td>
					<td>{{ ply.uid }}</td>
					<td>{{ ply.name }}</td>
					<td>{{ ply.create_time }}</td>
					<td>{{ ply.prof }}</td>
					<td>{{ ply.sex }}</td>
					<td>{{ ply.lev }}</td>
					<td>{{ ply.scene_type }}</td>
					<td><a href="{{ ply.property_url }}" target="_blank">属性详情</a></td>
					<td><a href="{{ ply.db_url }}" target="_blank">数据详情</a></td>
					<td><a href="{{ ply.agent_dict_url }}" target="_blank">agent进程字典</a></td>
					<td><a href="{{ ply.scene_dict_url }}" target="_blank">scene进程字典</a></td>
				</tr>
			{% endfor %}
		</table>
      </div>

  </body>
</html>


