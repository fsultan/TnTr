<tmpl_include name=../head.tpl>
<h1>Edit Time : </h1>
<tmpl_var name=time_tree><br><br>
<div id='times_edit_form'>
<tmpl_if name=dfv_errors>
<b>Some fields below are missing or invalid</b>
</tmpl_if>
	<form action='' method='post'>
		<input type='text' size='32' name='name' label='Name' value="<tmpl_var name=name>"><span class="dfv_errors"> <tmpl_var name='err_name'></span>
		<input type='text' size='32' name='description' label='Description' value="<tmpl_var name=description>"><span class="dfv_errors"> <tmpl_var name='err_description'></span>
<br>
		<select  name='task' label='Task'>
			<option value='0'>--------</option>
			<option value='<tmpl_var name=task_id>' selected><tmpl_var name=task_name></option>
		</select><span class="dfv_errors"><tmpl_var name='err_task'></span>
<br>
	<input type='text' size='10' name='start_date' label='Start date' value="<tmpl_var name=start_date>">
		<span class='form_field_format'>YYYY-MM-DD</span>
		<span class="dfv_errors"> <tmpl_var name='err_start_date'></span>

	<input type='text' size='5' name='start_time' label='Start time' value="<tmpl_var name=start_time>">
		<span class='form_field_format'>HH:MM:SS</span>
		<span class="dfv_errors"> <tmpl_var name='err_start_time'></span>
<br>
	<input type='text' size='10' name='end_date' label='End date' value="<tmpl_var name=end_date>">
		<span class='form_field_format'>YYYY-MM-DD</span>
		<span class="dfv_errors"> <tmpl_var name='err_end_date'></span>
	<input type='text' size='5' name='end_time' label='End time' value="<tmpl_var name=end_time>">
		<span class='form_field_format'>HH:MM:SS</span>
		<span class="dfv_errors"> <tmpl_var name='err_end_time'></span>
<br>

	<input type='submit' value='Save'><input type='reset'>
	</form>
</div>
<tmpl_include name=../tail.tpl>
