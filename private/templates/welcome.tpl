<tmpl_include name=head.tpl>
   <h1>Welcome!</h1>
   <br>
   <p><a href="<tmpl_var name=app_base_url>/times/create">Enter New Time</a></p>
	 <p>We currently have <tmpl_var name="total_users"> users<br>
	 We currently have <tmpl_var name="total_projects"> projects<br>
	 We currently have <tmpl_var name="total_clients"> clients</p>
	 <img src='/images/tntr_image.png'>
<tmpl_include name=tail.tpl>
