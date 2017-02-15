package EPrints::Plugin::Stats::Processor::EPrint::AbstractValueTracker;

our @ISA = qw/ EPrints::Plugin::Stats::Processor /;

use strict;

# Processor::EPrint::AbstractValueTracker
#
# Purpose:  Provides an abstract tracker for processing of fields in IRStats2.
#			Fields to tracked must be specified in the IRStats2 configuration file as follows:
#			$c->{irstats2}->{datatype}->{field_id} = 'fieldname';
#           e.g. $c->{irstats2}->{wos_citations}->{field_id} = 'woslamr_times_cited';
#			For each field, a subclass must be defined. See, e.g., 
#			ScopusCitations.pm or WoSCitations.pm
#
# Authors:  (1) Adam Field(1), (2) Martin Brändle, code adapted from Processor/EPrint/DocumentAccess.pm
# Places:   (1) Eprints Services, University of Southampton, Southampton, SO17 1BJ, UK 
#           (2) University of Zurich, Zentrale Informatik, Stampfenbachstr. 73, Zurich, Switzerland
# Date:     2015/09/04
# Modified: -
#

sub new
{
	my( $class, %params ) = @_;
	my $self = $class->SUPER::new( %params );
	
	$self->{provides} = [ "abstract_value_tracker" ];
	$self->{disable} = 1;
	
	$self->{field_id} = 'DEFINE IN SUBCLASS';
	$self->{value_id} = 'DEFINE IN SUBCLASS';
	
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
#		print STDERR "IRStats2: warning - status not set for eprint=".$eprint->get_id."\n";
		return;
	}

	return unless( $status eq 'archive' );

	my $datestamp = $eprint->get_value( "datestamp" ) || $eprint->get_value( "lastmod" );

	my $date = $self->parse_datestamp( $self->{session}, $datestamp );

	my $year = $date->{year};
	my $month = $date->{month};
	my $day = $date->{day};

	my $value = $eprint->value($self->{field_id});

	if (defined $value)
	{
		$self->{cache}->{"$year$month$day"}->{$epid}->{$self->{value_id}} = $value;
    }
}

1;