<tmpl_include name=../head.tpl>
<h1>Group Memberships : </h1>
<br>
<p>
	Id: <tmpl_var name=id><br>
	Name: <tmpl_var name=name><br>
	<br>
  <br><tmpl_var name=name> is in Groups: 
  <br>
  <div id='group_select_form'>
  <form action='' method='post'>
  <input type='submit' name='submit' value='Update'>
  <tmpl_loop name=user_groups>
    <div class='group_select_checkbox'>
	   <label for='group_<tmpl_var name=id>'><tmpl_var name=name></label>
	   <input type='checkbox' name='group<tmpl_var name=id>' id='group_<tmpl_var name=id>' <tmpl_if name=checked>checked</tmpl_if> value='enabled'/>
	</div>
  </tmpl_loop>
  </form>
  <div class='clear'></div>
  </div>
</p>
<tmpl_include name=../tail.tpl>
