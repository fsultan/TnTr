<div id='header_user_info'>
username: <tmpl_var name=authen_username>.<br>
<a href="<tmpl_var name=app_base_url>/logout">Logout</a>
</div>

<div id='navbar'>
<ul>
 <li><a href="<tmpl_var name=site_base_url>/index.html">index</a></li>
 <li><a href="<tmpl_var name=app_base_url>/default">default</a></li>
 <li><a href=<tmpl_var name=app_base_url>/users/>Users</a>
   <ul><li><a href=<tmpl_var name=app_base_url>/users/list>list</a></li></ul>
 </li>
 <li><a href=<tmpl_var name=app_base_url>/groups/>Groups</a>
 	<ul><li><a href=<tmpl_var name=app_base_url>/groups/list>list</a></li></ul>
 </li>
 <li><a href=<tmpl_var name=app_base_url>/roles/>Roles</a></li>
 <li><a href=<tmpl_var name=app_base_url>/clients/>Clients</a>
 	<ul><li><a href=<tmpl_var name=app_base_url>/clients/list>list</a></li></ul>
 </li>
 <li><a href=<tmpl_var name=app_base_url>/projects/>Projects</a>
   <ul>
     <li><a href=<tmpl_var name=app_base_url>/projects/list>list</a></li>
     <li><a href=<tmpl_var name=app_base_url>/projects/create>create</a></li>
   </ul>
 </li>
 <li><a href=<tmpl_var name=app_base_url>/tasks/>Tasks</a>
   <ul>
     <li><a href=<tmpl_var name=app_base_url>/tasks/list>list</a></li>
     <li><a href=<tmpl_var name=app_base_url>/tasks/create>create</a></li>
   </ul>
 </li>
 <li><a href=<tmpl_var name=app_base_url>/times/>Times</a>
   <ul>
     <li><a href=<tmpl_var name=app_base_url>/times/list>list</a></li>
     <li><a href=<tmpl_var name=app_base_url>/times/create>create</a></li>
   </ul>
 </li>
 <li>Views : 
	 <ul>
	 	<li><a href=<tmpl_var name=app_base_url>/calendar/>Calendar View</a></li>
	</ul>
 </li>
</ul>
</div>

<script type="text/javascript">
  $(document).ready(function() {
    $("#navbar li ul").hide();
    
    $("#navbar li").hover(
      function() {
		$(this).children("ul").show();
      },
      function() {
	 	$(this).children("ul").hide();
      }); //hover
  });     //document ready
</script>
