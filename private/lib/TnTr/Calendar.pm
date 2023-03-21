package TnTr::Calendar;

use strict;
use base 'TnTr';
use DateTime;

use TnTr::HTMLCalendar;

sub setup {    # overrides     # called after cgiapp_init()
    my $self = shift;
    $self->authen->protected_runmodes(':all');
}

sub default : StartRunmode {
	my $self = shift;
	return $self->forward('view')
}

sub get_user_rights_for {
    my $self = shift;
    my $auth_user = shift;
    my $right = shift;
    my $app_id = shift;

    my @args = @_;
    my $app_name = 'Clients';	#???
    
    $self->get_user_app_rights_for( $auth_user, $right, $app_name, $app_id, @args );
}

sub view : Runmode {
    my $self = shift;
    #my $q    = $self->query;
    my $t    = $self->load_tmpl('calendar/default.tpl');
    my $args = $self->param('dispatch_url_remainder');
    
	my $month;
	my $year;
	my $dt;
	
    #extract month and year from args if present.
    if ($args =~ /^(\d{4})\/+([01]?\d)$/) {
        $year = $1;
        $month = $2;
    }
    
    if ( $self->_is_valid_year($year) && $self->_is_valid_month($month) ){
    	$dt = DateTime->new( year => $year, month => $month);
    }
	else {
		#create datetime object for current month:
    	$dt = DateTime->now;
	}
	
    my $cal = TnTr::HTMLCalendar->new();
    
    $cal->create(
        'main_cal',
        (
            year       => $dt->year,
            month      => $dt->month,
            week_begin => 2
        )
    );

    #TODO check for failure for calendar create !
    $cal->_customize_calendar('main_cal');

    #get all tasks for current month
    my $tasks = $self->times_for_month($dt);
    $cal->populate_days_with_tasks('main_cal',$tasks, { app_base_url => $self->config_param('app_base_url') });
    
    $t->param( html_calendar => $cal->output('main_cal') );
    $t->param( link_for_previous_month => $self->_link_for_previous_month($dt));
    $t->param( link_for_next_month => $self->_link_for_next_month($dt));
    return $t->output;
}


# times_for_month just sets the start_date and end_date for times_for_date_range
# as first day and last day of the month.
sub times_for_month {
    my $self = shift;
    my $dt   = shift;

    #make sure its a datatime object!
    my $first_day_of_month_dt = DateTime->new(
        year  => $dt->year,
        month => $dt->month,
        day   => '1'
    );

    my $last_day_of_month_dt = DateTime->last_day_of_month(
        year  => $dt->year,
        month => $dt->month
    );
    my $times = $self->times_for_date_range(
        start_date => $first_day_of_month_dt,
        end_date   => $last_day_of_month_dt
    );
}

sub times_for_date_range {
    my $self = shift;
    my %args = @_;

    $self->_load_schema();
    my $times = $self->{schema}->resultset('Times')->search(
        -and => [
            { start_datetime => { '>=', $args{start_date} } },
            { end_datetime   => { '<=', $args{end_date} } },
        ],
        { columns => [qw/id name start_datetime end_datetime/], },
    );
    return $times;
}

sub _link_for_previous_month {
	my $self = shift;
	my $arg_dt = shift;
	my %args = @_;
	my $dt = $arg_dt->clone->subtract( months => 1 );
	my $link = $self->config_param('app_base_url') . '/calendar/view/' . $dt->year . '/' . $dt->month;
	return $link;
}

sub _link_for_next_month {
	my $self = shift;
	my $arg_dt = shift;
	my %args = @_;
	my $dt = $arg_dt->clone->add( months => 1);
	my $link =  $self->config_param('app_base_url') . '/calendar/view/' . $dt->year . '/' . $dt->month;
	return $link;
}

#return true
1;
