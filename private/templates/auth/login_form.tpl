<tmpl_include name=../head.tpl>
<form name="loginform" method="post" action="">
  <div class="login">
    <div class="login_header">
      Sign In
    </div>
    <div class="login_content">
		<tmpl_if name=login_error>
				<p class="login_warning"><tmpl_var name=login_error><br />
				<tmpl_if name=login_attempt>
					(login attempt <tmpl_var name=login_attempt>)
				</tmpl_if>
				</p>
		</tmpl_if>
      <fieldset>
        <label for="authen_username">User Name</label>

        <input id="authen_loginfield" tabindex="1" type="text" name="authen_username" size="20" value="user01" /><br />
        <label for="authen_password">Password</label>
        <input id="authen_passwordfield" tabindex="2" type="password" name="authen_password" size="20" /><br />
        <label for="authen_domain">Domain</label>
        <input id="authen_domainfield" tabindex="2" type="text" name="authen_domain" size="20" /><br />
        <input id="authen_rememberuserfield" tabindex="3" type="checkbox" name="authen_rememberuser" value="1" />Remember User Name<br />
      </fieldset>
    </div>
    <div class="login_footer">
      <div class="buttons">
        <input id="authen_loginbutton" tabindex="4" type="submit" name="authen_loginbutton" value="Sign In" class="button" />
      </div>
    </div>
  </div>
  <input type="hidden" name="destination" value="<tmpl_var name=destination>" />
  <input type="hidden" name="rm" value="authen_login" />
</form>
<script type="text/javascript" language="JavaScript">document.loginform.authen_username.select();
</script>
<tmpl_include name=../tail.tpl>
