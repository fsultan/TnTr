<tmpl_include name=../head.tpl>
<h1>Tasks Details : </h1>
<p>
	(<tmpl_var name=id>) <span style="font-size: 18pt; font-weight: bold;"><tmpl_var name=name></span><br>
	Project: <tmpl_var name=project><br>
  <br>
	<br>
	Description: <tmpl_var name=description><br>
  <dt style="font-size: 10pt;">
	Created: <tmpl_var name=created><br>
  Updated: <tmpl_var name=updated><br>
  Closed:  <tmpl_var name=closed><br>
  </dt>
</p>
<tmpl_if name=times>
<h2>Times : </h2>
<b>id, name.</b>
<tmpl_loop name=times>
<p>
  <tmpl_var name=id>,
  <tmpl_var name=name>
  [
    <a href="<tmpl_var name=app_base_url>/times/show/<tmpl_var name=id>">view</a>
    <a href="<tmpl_var name=app_base_url>/times/edit/<tmpl_var name=id>">edit</a> 
  ]</p>
</tmpl_loop>
<tmpl_else>
<p><i>Task has no entered times!</i></p>
</tmpl_if><!-- times -->
<tmpl_include name=../tail.tpl>
