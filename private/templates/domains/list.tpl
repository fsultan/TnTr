<tmpl_include name=../head.tpl>
   <h1>Welcome to Domains!</h1>
	 <br>
	 <p>We currently have <tmpl_var name="total_domains"> domains</p>
	<br>
   <p>They are:</p>
<tmpl_loop name=domain_list>
<a href="<tmpl_var name=app_base_url>/domains/edit/<tmpl_var name=id>"><tmpl_var name=id></a>, <tmpl_var name=name>.<br>
</tmpl_loop>
<tmpl_include name=../tail.tpl>
