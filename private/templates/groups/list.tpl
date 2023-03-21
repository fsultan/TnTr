<tmpl_include name=../head.tpl>
   <h1>Groups:</h1>
	 <br>
<tmpl_loop name=group_list>
	<a href="<tmpl_var name=app_base_url>/groups/edit/<tmpl_var name=id>"><tmpl_var name=id></a>,
 	<tmpl_var name=name>
 	[
    <a href="<tmpl_var name=app_base_url>/groups/show/<tmpl_var name=id>">view</a>
    <a href="<tmpl_var name=app_base_url>/groups/edit/<tmpl_var name=id>">edit</a> 
  ] <br>
</tmpl_loop>
<tmpl_include name=../tail.tpl>
