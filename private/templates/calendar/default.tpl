<tmpl_include name=../head.tpl>
   <h1>Calendar View</h1>

<div id='main_calendar'>
   <a href="<tmpl_var name=link_for_previous_month>" alt="Previous Month"> < Previous Month</a> | 
   <a href="<tmpl_var name=link_for_next_month>" alt="Next Month">Next Month > </a><br/>
	 <tmpl_var name=html_calendar>
</div>
<tmpl_include name=../tail.tpl>
