<tmpl_include name=../head.tpl>
   <h1>Projects : </h1>
	 <br>
	 <p>You have <tmpl_var name="total_projects"> projects</p>
<tmpl_loop name=project_list>
	<a href="<tmpl_var name=app_base_url>/projects/edit/<tmpl_var name=id>"><tmpl_var name=id></a>, 
	<tmpl_var name=name>, 
	<tmpl_var name=description>,
	<tmpl_var name=client> 
	<tmpl_var name=create_time>
	[
    <a href="<tmpl_var name=app_base_url>/projects/show/<tmpl_var name=id>">view</a>
    <a href="<tmpl_var name=app_base_url>/projects/edit/<tmpl_var name=id>">edit</a> 
  ] <br>
</tmpl_loop>
<tmpl_include name=../tail.tpl>
