<tmpl_include name=../head.tpl>
   <h1>Tasks : </h1>
	 <p>You have <tmpl_var name="total_tasks"> tasks</p>
   <p>They are:</p>
 <b>id, name, description, create date.</b><br>
<tmpl_loop name=task_list>
<a href="<tmpl_var name=app_base_url>/tasks/edit/<tmpl_var name=id>"><tmpl_var name=id></a>, 
<tmpl_var name=name>, <tmpl_var name=description>,
<tmpl_var name=create_time> [
    <a href="<tmpl_var name=app_base_url>/tasks/show/<tmpl_var name=id>">view</a>
    <a href="<tmpl_var name=app_base_url>/tasks/edit/<tmpl_var name=id>">edit</a> 
  ] <br>
</tmpl_loop>
<tmpl_include name=../tail.tpl>
