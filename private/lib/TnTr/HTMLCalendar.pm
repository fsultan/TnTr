package TnTr::HTMLCalendar;

use strict;
#use base 'TnTr';
use HTML::AsSubs;
use HTML::Element;
use HTML::CalendarMonth;
use DateTime::Format::RFC3339;
use Data::Dumper;

sub new {
    my $class = shift;
    my $self = {};
    bless( $self, $class );
    #$self->_init(@_);
	
    return $self;
}

sub create {
	my $self = shift;
	my $cal_name = shift;
	
	if (! $cal_name =~ /^\w+$/) {
		warn 'fail! no cal name!';
		return 0;
	}
	$self->{$cal_name} = HTML::CalendarMonth->new(@_);
	return $cal_name;
}
sub _customize_calendar {
	my $self = shift;
	my $cal_name = shift;
	
	if (! defined $self->{$cal_name}) {
		return 0;
	}
	my $cal = $self->{$cal_name};
	$cal->item($cal->month)->wrap_content(font({size => '+2'}));
	$cal->item_daycol('Sun','Sat')->attr(bgcolor => 'lightgray');
	
	return 1;
}

sub output {
	my $self = shift;
	my $cal_name = shift;
	if (! defined $self->{$cal_name}) {
		return 0;
	}
	return $self->{$cal_name}->as_HTML;
}

sub populate_days_with_tasks {
	my $self = shift;
	my $cal_name = shift;
	my $times = shift;
	my %args = shift;
		
	if (! defined $self->{$cal_name}) {
		return 0;
	}
	my $cal = $self->{$cal_name};
	
	while (my $time = $times->next) {
		#get the day sans leading 0
		#$task->start_datetime =~ /^\d\d\d\d-\d\d-0?(\d{1,2}).*/;
		#my $day = $1;
		
		my $start_datetime_dt = DateTime::Format::RFC3339->parse_datetime($time->start_datetime);
		#$cal->item($start_datetime_dt->day)->push_content( div({class => 'namedclass'},$task->name) );
		$cal->item($start_datetime_dt->day)->push_content( a({href => $args{app_base_url}.'/times/show/'.$time->id},$time->name) );
	}
}
#return true
1;
