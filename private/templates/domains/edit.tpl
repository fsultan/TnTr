<tmpl_include name=../head.tpl>
<div id='domain_edit_form'>
<tmpl_if name=dfv_errors>
<b>Some fields below are missing or invalid</b>
</tmpl_if>
	<form action='' method='post'>
		<input type='text' size='32' name='name' label='Name' value="<tmpl_var name=name>"><span class="dfv_errors"> <tmpl_var name='err_name'></span>
	<input type='submit' value='Save'><input type='reset'>
	</form>
</div>
<tmpl_include name=../tail.tpl>
