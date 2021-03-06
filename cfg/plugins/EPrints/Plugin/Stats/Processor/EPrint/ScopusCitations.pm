package EPrints::Plugin::Stats::Processor::EPrint::ScopusCitations;

use EPrints::Plugin::Stats::Processor::EPrint::AbstractValueTracker;
our @ISA = qw/ EPrints::Plugin::Stats::Processor::EPrint::AbstractValueTracker /;

use strict;

# Processor::EPrint::ScopusCitations
#
# Purpose:  Determines citation counts by Scopus citation database. 
#           Provides the 'eprint_scopus_citations' datatype.
#
# Authors:  (1) Adam Field(1), (2) Martin Brändle, code adapted from Processor/EPrint/DocumentAccess.pm
# Places:   (1) Eprints Services, University of Southampton, Southampton, SO17 1BJ, UK 
#           (2) University of Zurich, Zentrale Informatik, Stampfenbachstr. 73, Zurich, Switzerland
# Date:     2014/11/28
# Modified: 2015/09/04
#

sub new
{
	my( $class, %params ) = @_;
	my $self = $class->SUPER::new( %params );
	my $repo = $self->repository;

	$self->{provides} = [ "scopus_citations" ];

	$self->{disable} = 0;
	
	$self->{field_id} = $repo->config('irstats2','scopus_citations','field_id');
	$self->{value_id} = 'scopus';

	return $self;
}

1;
