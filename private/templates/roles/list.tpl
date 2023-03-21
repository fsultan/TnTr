<tmpl_include name=../head.tpl>
   <h1>List Roles:</h1>
	<br>
<tmpl_loop name=role_list>
	<a href="<tmpl_var name=app_base_url>/roles/edit/<tmpl_var name=id>"><tmpl_var name=id></a>, 
	<tmpl_var name=name>
	[
    <a href="<tmpl_var name=app_base_url>/roles/show/<tmpl_var name=id>">view</a>
    <a href="<tmpl_var name=app_base_url>/roles/edit/<tmpl_var name=id>">edit</a> 
  ] <br>
</tmpl_loop>
<tmpl_include name=../tail.tpl>
