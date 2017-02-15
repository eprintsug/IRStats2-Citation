package EPrints::Plugin::Stats::Processor::EPrint::Publishers;

our @ISA = qw/ EPrints::Plugin::Stats::Processor /;

use strict;

# Processor::EPrint::Publishers
#
# Purpose:  Determines publisher name counts by ZORA
#           Provides the 'eprint_publishers' datatype.
#
# Author:   Martin Brändle, code adapted from Processor/EPrint/DocumentAccess.pm
# Place:    University of Zurich, Zentrale Informatik, Stampfenbachstr. 73, Zurich, Switzerland
# Date:     2015/01/27
# Modified: -
#

sub new
{
	my( $class, %params ) = @_;
	my $self = $class->SUPER::new( %params );

	$self->{provides} = [ "publishers" ];

	$self->{disable} = 0;

	return $self;
}


sub process_record
{
	my ($self, $eprint ) = @_;

	my $epid = $eprint->get_id;
	return unless( defined $epid );

	my $status = $eprint->get_value( "eprint_status" );
	unless( defined $status ) 
	{
##		print STDERR "IRStats2: warning - status not set for eprint=".$eprint->get_id."\n";
		return;
	}

	return unless( $status eq 'archive' );

	my $datestamp = $eprint->get_value( "datestamp" ) || $eprint->get_value( "lastmod" );

	my $date = $self->parse_datestamp( $self->{session}, $datestamp );

	my $year = $date->{year};
	my $month = $date->{month};
	my $day = $date->{day};
	
	my $publisher = $eprint->get_value( "publisher" );
	

	if (defined $publisher)
	{
		$self->{cache}->{"$year$month$day"}->{$epid}->{"$publisher"}++;
	}
}

1;
