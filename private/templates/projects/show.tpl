<tmpl_include name=../head.tpl>
<h1>Project Details : </h1>
<p>
	(<tmpl_var name=id>) <span style="font-size: 18pt; font-weight: bold;"><tmpl_var name=name></span><br>
	Client: <tmpl_var name=client><br>
	<br>
	Description: <tmpl_var name=description><br>
	
  <dt style="font-size: 10pt;">
	Created: <tmpl_var name=created><br>
  Updated: <tmpl_var name=updated><br>
  Closed:  <tmpl_var name=closed><br>
  </dt>
</p>
<tmpl_if name=tasks>
<h2>Tasks : </h2>
<b>id, name.</b>
<tmpl_loop name=tasks>
<p>
  <tmpl_var name=id>,
  <tmpl_var name=name>
  [
    <a href="<tmpl_var name=app_base_url>/tasks/show/<tmpl_var name=id>">view</a>
    <a href="<tmpl_var name=app_base_url>/tasks/edit/<tmpl_var name=id>">edit</a> 
  ]</p>
</tmpl_loop>
<tmpl_else>
<p><i>Project has no open tasks!</i></p>
</tmpl_if><!-- tasks -->
<tmpl_include name=../tail.tpl>
