#!/user/bin/perl -w -I../../lib

use TnTrDB::Schema;
use Data::Dumper;
use Digest::SHA1;
use strict;

my $schema = TnTrDB::Schema->connect('dbi:SQLite:test.db');
$schema->storage->debug(1);


#----------------------------
my %task_times = (
    'time01' => { 
        task => 'task01',
        user => 'user01',
        start_datetime => '2009-06-01T12:00:00Z',
        end_datetime => '2009-06-01T14:00:00Z',
    },
    'time02' => { 
        task => 'task02',
        user => 'user02',
        start_datetime => '2009-06-03T14:00:00Z',
        end_datetime => '2009-06-03T16:00:00Z',
    },
    'time03' => { 
        task => 'task01',
        user => 'user01',
        start_datetime => '2009-06-03T17:00:00Z',
        end_datetime => '2009-06-03T19:00:00Z',
    },
    'time04' => { 
        task => 'task02',
        user => 'user02',
        start_datetime => '2009-06-08T17:00:00Z',
        end_datetime => '2009-06-08T18:30:00Z',
    },
    'time12' => { 
        task => 'task12',
        user => 'user15',
        start_datetime => '2009-06-09T10:00:00Z',
        end_datetime => '2009-06-09T11:00:00Z',
    },
    'time13' => { 
        task => 'task12',
        user => 'user15',
        start_datetime => '2009-06-12T17:00:00Z',
        end_datetime => '2009-06-12T18:00:00Z',
    },
);

my @times;

foreach my $time ( keys %task_times ) {
    my $task =
      $schema->resultset('Tasks')
      ->search( { name => $task_times{$time}->{'task'} } );
    my $user = $schema->resultset('Users')->search( {username=> $task_times{$time}->{'user'} } );

    my $description = $time . ' for ' . $task->first->name;

    push @times, [ $time, $task->first->id, $user->first->id, $description, $task_times{$time}->{'start_datetime'}, $task_times{$time}->{'end_datetime'} ];
}

$schema->populate( 'Times', [ [qw/name task user description start_datetime end_datetime/], @times, ] );
