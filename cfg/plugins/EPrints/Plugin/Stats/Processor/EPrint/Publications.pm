package EPrints::Plugin::Stats::Processor::EPrint::Publications;

our @ISA = qw/ EPrints::Plugin::Stats::Processor /;

use strict;

# Processor::EPrint::Publications
#
# Purpose:  Determines journal or series title counts by ZORA
#           Provides the 'eprint_publications' datatype.
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

	$self->{provides} = [ "publications" ];

	$self->{disable} = 0;

	return $self;
}


sub process_record
{
	my ($self, $eprint ) = @_;

    my $publication;
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
	
	my $type = $eprint->get_value( "type" );
	
	if ($type eq 'article')
	{
		$publication = $eprint->get_value( "publication" );
	}
	else
	{
		$publication = $eprint->get_value( "series" );
	}

	if (defined $publication)
	{
		$self->{cache}->{"$year$month$day"}->{$epid}->{"$publication"}++;
	}
}

1;
