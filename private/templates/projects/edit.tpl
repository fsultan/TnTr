<tmpl_include name=../head.tpl>
<h1>Edit Project : </h1>
<div id='project_edit_form'>
<tmpl_if name=dfv_errors>
<b>Some fields below are missing or invalid.</b>
</tmpl_if>
	<form action='' method='post'>
		<label for='name'>Name : </label>
		<input type='text' size='32' name='name' label='Name' value="<tmpl_var name=name>">
		<span class="dfv_errors"> <tmpl_var name='err_name'></span><br>
		<label for='description'>Description : </label>
		<input type='text' size='32' name='description' label='Description' value="<tmpl_var name=description>">
		<span class="dfv_errors"> <tmpl_var name='err_description'></span><br>
		<label for='client'>Client : </label>
		<select  name='client' label='Client'>
			<option value='0'>--------</option>
			<tmpl_loop name=client_list>
				<option value='<tmpl_var name=client_id>' 
					<tmpl_if name=selected>selected</tmpl_if>
				>
				<tmpl_var name=client_name></option>
			</tmpl_loop>
		</select> <span class="dfv_errors"><tmpl_var name='err_client'></span><br><br>
	<input type='submit' value='Save'><input type='reset'>
	</form>
</div>
<tmpl_include name=../tail.tpl>
