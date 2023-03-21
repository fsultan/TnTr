<tmpl_include name=../head.tpl>
<h1>Time Details : </h1>
<br>
<br><tmpl_var name=time_tree>
<br>
<p>
	Id: <tmpl_var name=id><br>
	Name: <tmpl_var name=name><br>
	Description: <tmpl_var name=description><br>
	<br>
	User: <tmpl_var name=user><br>
	Task: <tmpl_var name=task><br>
  <br>
  <dt style="font-size: 12pt;">
	Start time: <tmpl_var name=start_datetime><br>
    End time: <tmpl_var name=end_datetime><br>
  </dt>
  <br>
  <dt style="font-size: 10pt;">
 Created: <tmpl_var name=created><br>
  Updated: <tmpl_var name=updated><br>
  Closed:  <tmpl_var name=closed><br>
  </dt>
</p>
<tmpl_include name=../tail.tpl>
