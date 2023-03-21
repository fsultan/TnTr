package MyEnv;
# Copyright M-) 2008 Mark Rajcok
# A singleton to keep stuff that must be shared between CGI::App and
# the model (i.e., business/database classes)
# A class derived from CGI::App should create the instance, passing in
# whatever shared environment references are needed, e.g.:
#  MyEnv->instance(dbh => $dbh)
$VERSION = 1.00;
use strict;
use Carp;

# -- class attributes
my $_instance_;

# -- class queries
sub instance {  # instead of 'sub new'
	my ($class, %args) = @_;
	confess "this method can not be called on an instance" if ref $class;
	if(! defined $_instance_) {
		$_instance_ = bless { %args }, $class;
	}
	return $_instance_;
}
# -- instance queries
sub dbh {
	my $self = shift;
	confess if ! defined $self->{dbh};
	return $self->{dbh};
}
1;
