<tmpl_include name=../head.tpl>

<script language="javascript" type="text/javascript">
<!--
function ClientSelectChanged() {
	$("#project_select_area").removeClass("active_form_element");
	$("#task_select_area").removeClass("active_form_element");
	$.ajax({
	  type: "GET",
	  url: "<tmpl_var name=app_base_url>/projects/project_form_select_html/",
	  data: 'client='+$('#selectclient').val(),
	  success: function (data, textStatus) {
		$("#project_select").replaceWith(data);
	  },
	  complete: function () {
	    $("#client_select_area").removeClass("active_form_element");
	  	$("#project_select_area").addClass("active_form_element");
	  },
	  error: function(){
	  	alert('Unable to retrieve data from server');
	  },
	  });
};

function ProjectSelectChanged() {
	$("#project_select_area").removeClass("active_form_element");
	$("#task_edit_form_sub1").addClass("active_form_element");
};

// -->
</script>
<h1>Create New Task : </h1>
<div id='task_edit_form' class='form_block'>
<tmpl_if name=dfv_errors>
<b>Some fields below are missing or invalid</b>
</tmpl_if>

	<form action='' method='post'>
<!-- first choose client -->
<div id='client_select_area'  class='form_element active_form_element'>
<div id='client_select'>
  <label for='selectclient'>Client: </label>
	<select id='selectclient' name='client' onChange="ClientSelectChanged()">
		<option value='0'>--------</option>
		<tmpl_loop name=client_list>
			<option value='<tmpl_var name=client_id>' 
				<tmpl_if name=selected>selected</tmpl_if>
			>
			<tmpl_var name=client_name></option>
		</tmpl_loop>
	</select> <span class="dfv_errors"><tmpl_var name='err_client'></span>
</div>
</div>
<!-- then choose project based on choice of client -->
<div id='project_select_area' class='form_element'>
	<div id='project_select'>
  <label for='selectproject'>Project: </label>
	<select id='selectproject' name='project'>
		<option>[ Select client first ]</option>
  </select>
	</select><span class="dfv_errors"><tmpl_var name='err_project'></span>
	</div>
  <div id='project_select_ajax_error'></div>
</div>

<div id='task_edit_form_sub1' class='form_element'>
		<label for='name'>Name:</label>
		<input type='text' size='32' name='name' value="<tmpl_var name=name>">
		<span class="dfv_errors"> <tmpl_var name='err_name'></span>
		<label for='description'>Description:</label>
		<input type='text' size='32' name='description' label='Description' value="<tmpl_var name=description>">
		<span class="dfv_errors"> <tmpl_var name='err_description'></span>
</div> <!-- form block -->
<div class='form_block'>
	<input type='submit' value='Save'><input type='reset'>
</div>

	</form>
</div>
<tmpl_include name=../tail.tpl>

