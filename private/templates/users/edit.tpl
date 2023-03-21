<tmpl_include name=../head.tpl>
<h1>Edit User:</h1>
<div id='client_edit_form'>
<tmpl_if name=dfv_errors>
<b>Some fields below are missing or invalid</b>
</tmpl_if>
	<form action='' method='post'>
  <label for='name'>Name : </label>
		<input type='text' size='32' name='name' label='Name' value="<tmpl_var name=name>"><span class="dfv_errors"> <tmpl_var name='err_name'></span>
<br>
<br>
	<input type='submit' value='Save'><input type='reset'>
	</form>
</div>
<tmpl_include name=../tail.tpl>
