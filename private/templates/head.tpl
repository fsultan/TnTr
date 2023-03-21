<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
 <head>
  <title>Travis TnTr Demo - pre alpha!</title>
  <link rel="stylesheet" href="<tmpl_var name=default_css_url>" type="text/css">
  <link rel="stylesheet" href="<tmpl_var name=site_base_url>/css/auth.css" type="text/css">
  <link rel="stylesheet" href="<tmpl_var name=site_base_url>/css/html_cal.css" type="text/css">
  <tmpl_loop name=include_javascripts>
   <script src="<tmpl_var name=site_base_url><tmpl_var name=js_url>" type="text/javascript"></script></tmpl_loop>
 </head>
 <body>

<div id='header'>
<img src='/images/travis_tntr_logo.png' style='background-color: #fff; float: left;'>
<div id='dev_version'> <span> Pre-alpha! </span> </div>
	<tmpl_if name=authen_username>
	  <tmpl_include name=menu.tpl>
	<tmpl_else>
	  <a href="<tmpl_var name=app_base_url>/login">Login</a>
	</tmpl_if>
	
	<!-- <tmpl_var name=app_base_url> -->
</div>
	<tmpl_if name=flash_msg>
		<div id='flash_msg'><tmpl_var name=flash_msg></div>
	</tmpl_if>
<div id='gen_content'> <!-- close div in tail.tpl -->
