package EPrints::Plugin::Stats::View::TableZORA;

use EPrints::Plugin::Stats::View;
@ISA = ('EPrints::Plugin::Stats::View');

use strict;

# Stats::View::Div
#
# Draws an HTML set of Divs, usually to show the Top n Objects given a context, for instance:
#
# - Top EPrints globally,
# - Top EPrints given a set (Top EPrints in ECS)
# - Top Authors (== set) globally or in a set
# - Top Referrers (== value) globally or in a set
#
# Options:
# - show_count: show the counts or not
# - show_order: show the order (1,2,3,4...)
# - human_display: formats the number for humans (e.g. 1000 -> 1,000)
# - show_more: show the bottom paging options (10,25,50,all)
# - citation_db: display links to Scopus or Web of Science

sub javascript_class
{
	return 'Table';
}

sub render_title
{
	my( $self, $context ) = @_;

	my $grouping = defined $context->{grouping} ? ":".$context->{grouping} : "";

	return $self->html_phrase( "title$grouping" );
}

sub get_data
{
	my( $self ) = @_;
	my $session = $self->{session};

	# We need to know the Top <things> we're going to display...
	if( !EPrints::Utils::is_set( $self->options->{top} ) )
	{
		$self->handler->log( __PACKAGE__.": missing option 'top'" );
		return;
	}

	# This bit of code tries to map what the user wants to view given the context
	my $options = $self->options;
	
	$options->{do_render} = ( defined $options->{export} ) ? 0 : 1;

	$options->{limit} ||= 10;
	delete $options->{limit} if( $options->{limit} eq 'all' );

	my $top = $self->options->{top};

	# Perhaps the user wants to see the top:
	# - eprints
	# - <set_name> eg top authors
	# - <value> eg top referrers / country...
	if( $top eq 'eprint' )
	{
		# we need to fetch eprint objects ie 'eprintid'
		$self->context->{grouping} = 'eprint';
		$options->{fields} = [ 'eprintid' ];
	}
	elsif( $top eq $self->context->{datatype} )
	{
		$self->context->{grouping} = 'value';
		$options->{fields} = [ 'value' ];
	}
	elsif( EPrints::Utils::is_set( $self->context->{set_name} ) && $self->context->{set_name} ne $top )
	{
		$self->context->{grouping} = $top;
		$options->{fields} = [ 'set_value' ];
	}
	else
	{
		# perhaps it's a set then... let's assume so!
		$self->context->{set_name} = $top;
		delete $self->context->{grouping};
		$options->{fields} = [ 'set_value' ];
	}

	$self->{options} = $options;

	return $self->handler->data( $self->context )->select( %$options );
}

sub render_content_ajax
{
	my( $self ) = @_;
	
	my $session = $self->{session};

	# UZH CHANGE 2015/02/09/mb ZORA-464 Allow a logged-in user to export all records
	my @limit_list = ( '5', '10', '25', '50', '100', '200' );
	
	my $user = $session->current_user;
	if( defined $user )
	{
		@limit_list = ( '5', '10', '25', '50', '100', '200', 'all' );
	}
    # END UZH CHANGE
	
	my $stats = $self->get_data();

	if( !defined $stats || !$stats->count )
	{
		return $session->html_phrase( 'lib/irstats2/error:no_data' );
	}

	my $options = $self->options;
	foreach( 'show_count', 'show_order', 'human_display', 'show_more' )
	{
		$options->{$_} = ( defined $options->{$_} && $options->{$_} eq '0' ) ? 0 : 1;
	}

	my $frag = $session->make_doc_fragment;

	my ( $div, $div_row, $div_element);

	$div = $frag->appendChild( $session->make_element( 'div', class => 'irstats2_table' ) );

	my $data = $stats->data;

	my $c = 0;
	my $reference = 0;
	my $ref_width = "100";
	
	# UZH CHANGE 2014/12/10/mb ZORA-376
	my $citation_db = $options->{citation_db};
	
	foreach( @$data )
	{
		my $object = $_->{$options->{fields}->[0]};
		my $count = $_->{count};
			
		# UZH CHANGE 2017/02/01/mb ZORA-376   remove et al
		my $object_string = $session->xml->text_contents_of( $object );
		next if ($object_string eq "Et Al");
		# END UZH CHANGE ZORA-376
		
		my $row_class = $c % 2 == 0 ? 'irstats2_table_row_even' : 'irstats2_table_row_odd';
		$div_row = $div->appendChild( $session->make_element( 'div', class => "$row_class" ) );


		# UZH CHANGE ZORA-507 (15) make-up - 2016/10/26/jv
		if( $options->{show_count} )
		{
			if( $c == 0 )
			{
				$reference = $count;
				$reference = 1 if( $reference == 0 );
			}

			my $cur_width = int( ($count / $reference)*$ref_width );

			# ZORA-507 (15) make-up on boxes - 2016/10/25/jv
			if ( $cur_width == $ref_width ) 
			{
				$cur_width = $cur_width -2;
			}

			$count = EPrints::Plugin::Stats::Utils::human_display( $session, $count ) if( $options->{human_display} );

			$div_element = $div_row->appendChild( $session->make_element( 'div', class => 'irstats2_table_cell_count' ) );
			my $ref_box = $div_element->appendChild( $session->make_element( 'div', class => 'irstats2_progress_wrapper', style => "width: $ref_width"."px" ) );
			my $ref_content = $ref_box->appendChild( $session->make_element( 'div', class => 'irstats2_progress', style => "width: $cur_width"."px" ) );
			my $span = $ref_content->appendChild( $session->make_element( 'span' ) );
			$span->appendChild( $session->make_text( $count ) );
		}

		$div_element = $div_row->appendChild( $session->make_element( 'div', class => 'irstats2_table_cell_object' ) );
		# END UZH CHANGE ZORA-507 (15) make-up END - 2016/10/26/jv
		
		if( $options->{show_order} )
		{
		 	$div_element->appendChild( $session->make_text( ($c + 1).". " ) );	# $c starts at 0, we want the ordering to start at 1
		}
		$div_element->appendChild( $object );
		
		# UZH CHANGE 2014/12/10/mb ZORA-376
		# this is not the recommended way via render method in Data.pm
		# since context in data loop is lost, we try to fetch the eprint id via the rendered URL for the eprint item
		if ( $citation_db )
		{		
			my $rendered_item = $session->xml->to_string($div_element);
			$rendered_item =~ s/.*uzh\.ch\/(\d+)\/.*/$1/s ;
			my $eprintid = $rendered_item;
			
			my $repo = $session->get_repository;
			my $eprint = $repo->eprint( $eprintid );
			
			# UZH CHANGE 2016/10/26/jv ZORA-507
			# make-up for ZORA2.0 statistic page
			$div_element = $div_element->appendChild( $session->make_element( 'div', class => 'irstats2_table_cell_object irstats2_table_cell_object_citation' ) );
			
			if ( $citation_db eq 'Scopus' )
			{
				my $scopus_uri = $eprint->repository->call( [ "scapi", "get_uri_for_eprint" ], $eprint );
            			my $scopus_link = $session->make_element(
            				"a",
            				href   => $scopus_uri,
            				target => "_blank"
            			);
            			$scopus_link->appendChild( $session->html_phrase( "scopus" ) );
            			$div_element->appendChild( $scopus_link );
			}
			elsif ( $citation_db eq 'WoS' )
			{
				my $wos_uri = $eprint->get_value( "woslamr_source_url" );
				my $wos_link = $session->make_element(
					"a",
					href   => $wos_uri,
					target => "_blank"
                		);
                		$wos_link->appendChild( $session->html_phrase( "wos" ) );
                		$div_element->appendChild( $wos_link );
			}
			else 
			{
			}
		}

		$c++;	
	}

	# don't show the link if we've reached the max already...	
	if( $options->{show_more} )
	{
		my $table_options = $frag->appendChild( $session->make_element( 'div', class => 'irstats2_table_options ep_noprint' ) );

		# UZH CHANGE 2014/10/09/mb changed limits
		# UZH CHANGE 2016/02/09/mb ZORA-464 Allow a logged-in user to export all records
		foreach my $limit ( @limit_list )
		{
			$options->{limit} = $limit;
			$self->{options} = $options;

			my $json_context = $self->context->to_json();
			my $view_options = $self->options_to_json();

			my $link = $table_options->appendChild( $session->make_element( 'a', 
					href => '#',
					onclick => "new EPJS_Stats_Table( { 'context': $json_context, 'options': $view_options } );return false;"
			) );
			$link->appendChild( $session->make_text( $limit ) );
		}
	}

	return $frag;
}

1;

