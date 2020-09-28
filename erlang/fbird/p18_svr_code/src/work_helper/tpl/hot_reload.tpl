
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>热更新</title>
</head>

<body>
	{% include "nav.tpl" %}
	<!-- CSS goes in the document HEAD or added to your external stylesheet -->
	<style type="text/css">
		/*body{
			text-align: center;
		}*/
		.bor{
			border:0px dashed black;
			width:50%;
			margin-left: 25%;
			margin-top:5px;
			/*text-align: center;*/
		} 
		.myButton {
			background-color:#44c767;
			-moz-border-radius:20px;
			-webkit-border-radius:20px;
			border-radius:20px;
			border:1px solid #18ab29;
			display:inline-block;
			cursor:pointer;
			color:#ffffff;
			font-family:Arial;
			font-size:15px;
			padding:6px 11px;
			text-decoration:none;
			text-shadow:0px 1px 0px #2f6627;
		}
		.myButton:hover {
			background-color:#5cbf2a;
		}
		.myButton:active {
			position:relative;
			top:1px;
		}
	</style>

	<div class="bor">
	{% if is_post %}
		更新结果：</br>
	{% else %}
		<form action="hot_reload" method="post">
		  <input class="myButton" type="submit" value="开始热更新"/>
		</form>
	{% endif %}
	</div> 
	<div class="bor">
		{% for f in reload_files %}
			<span>已热更新模块：{{f}}</span></br>
		{% endfor %}
	</div> 

</body>

</html>
