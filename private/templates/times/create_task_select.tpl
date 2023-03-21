<!-- does not call the head/tail tpl
 make sure to $self->param('skip_set_default_t_params',1) 
-->
<div id='task_select' class='form_element'>
  <label for='selecttask'>Task: </label>
<select id='selecttask' name='task' onChange='TaskSelectChanged()'>
	<option value='0'>Select</option>
	<tmpl_loop name=task_list>
		<option value='<tmpl_var name=task_id>' 
			<tmpl_if name=selected>selected</tmpl_if>
		>
		<tmpl_var name=task_name></option>
	</tmpl_loop>
</select>
		</select><span class="dfv_errors"><tmpl_var name='err_task'></span>
</div>
