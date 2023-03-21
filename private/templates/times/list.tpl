<tmpl_include name=../head.tpl>
   <h1>Times:</h1>
	 <br>
	 <p>We have <tmpl_var name="total_times"> times</p>
   <p>They are:</p>
    <b>id, name, description, task, user, start time, end time.</b><br>
<tmpl_loop name=time_list>
<a href="<tmpl_var name=app_base_url>/times/edit/<tmpl_var name=id>"><tmpl_var name=id></a>,
 <tmpl_var name=name>, <tmpl_var name=description>,  
 <tmpl_var name=user>, <tmpl_var name=task>,
  <tmpl_var name=start_time>, <tmpl_var name=end_time> 
  [
    <a href="<tmpl_var name=app_base_url>/times/show/<tmpl_var name=id>">view</a>
    <a href="<tmpl_var name=app_base_url>/times/edit/<tmpl_var name=id>">edit</a> 
  ]<br>
</tmpl_loop>
<tmpl_include name=../tail.tpl>
