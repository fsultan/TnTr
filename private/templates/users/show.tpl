<tmpl_include name=../head.tpl>
<h1>User Details : </h1>
<br>
<p>
	Id: <tmpl_var name=id><br>
	Name: <tmpl_var name=name><br>
	<br>
  Created: <tmpl_var name=created><br>
  Updated: <tmpl_var name=updated><br>
  Closed:  <tmpl_var name=closed><br>
  <br>User is in Groups: 
  <a href="<tmpl_var name=app_base_url>/groups/update_memberships/users/<tmpl_var name=id>">Update user groups</a>
  <br>
  <tmpl_loop name=user_groups>
    Group: <tmpl_var name=groupname><br>
  </tmpl_loop>
</p>
<tmpl_include name=../tail.tpl>
