package TnTr::CAPDevPopUp_Extra;

use strict;
use base qw/Exporter/;

sub import {
    my $c = scalar caller;
    $c->add_callback( 'devpopup_report', \&_header_report );
    goto &Exporter::import;
}

sub _header_report {
	my $self = shift;
	
	my $qparams = _query_params($self);
	
	
	$self->devpopup->add_report(
		title => 'Extras',
		summary => 'Extra stuff',
		report => qq(
			<style type="text/css">
        	tr.even{background-color:#eee}
        	</style>
        	<table><thead><th colspan="2">Query Params</th></thead><tbody> $qparams </tbody></table> 	
        ));
}

sub _query_params {
	my $self = shift;
	my @_params = $self->query->param; 
	#Vars called in list context to avoid accidental changes
	my $r=0;
	my $report = join $/, map {
					$r=1-$r;
					qq{<tr class="@{[$r?'odd':'even']}"><td valign="top"> $_ </td><td> @{[$self->query->param($_)]} </td></tr>}
				}
				sort @_params;
	return $report;
}


#return true!
1;
			
