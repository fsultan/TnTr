<tmpl_include name=../head.tpl>
<h1>Client Detail</h1>
<p>
	(<tmpl_var name=id>) <span style="font-size: 18pt; font-weight: bold;"><tmpl_var name=name></span><br>
  <br>
  <dt style="font-size: 10pt;">
  Created: <tmpl_var name=created><br>
  Updated: <tmpl_var name=updated><br>
  Closed:  <tmpl_var name=closed><br>
  </dt>
</p>
<tmpl_if name=projects>
<h2>Projects : </h2>
<b>id, name.</b>
<tmpl_loop name=projects>
<p>
  <tmpl_var name=id>,
  <tmpl_var name=name>
  [
    <a href="<tmpl_var name=app_base_url>/projects/show/<tmpl_var name=id>">view</a>
    <a href="<tmpl_var name=app_base_url>/projects/edit/<tmpl_var name=id>">edit</a> 
  ]</p>
</tmpl_loop>
<tmpl_else>
<p><i>Client has no open projects!</i></p>
</tmpl_if><!-- projects -->
<tmpl_include name=../tail.tpl>
