package EPrints::Plugin::Stats::View::GridZORA;

use EPrints::Plugin::Stats::View;
@ISA = ('EPrints::Plugin::Stats::View');

use strict;

# Stats::View::Grid
#
# Allows to draw 2 View plugins on the same row. This doesn't display any stats.
#
# Options:
# - items: an ARRAYREF of View plugins (defined the same way as for $c->{stats}->{report}->{$reportname}
#

sub can_export { return 0; }

sub has_title
{
	return 0;
}

sub render
{
	my( $self ) = @_;

	my $options = $self->options;
	my $session = $self->{session};

	return $self->{session}->make_doc_fragment unless( scalar( @{$options->{items}} ) > 0 );

	# ZORA-507(15) many changes for table2div 2016/10/25/jv
	my $cell_width = int( 100 / scalar( @{$options->{items}} ) ) -1;
        my $div = $session->make_element( 'div', class => 'irstats2_view_Grid');

	my $handler = $self->handler;

	my $done_any = 0;
        foreach my $item ( @{$options->{items} || []} )
        {
                # only exception style vs. CSS-file: inline calculation and setting of width
                my $div_element = $session->make_element( 'div', class => 'irstats2_view_GridElement', style => "width:$cell_width%;" );

                my $pluginid = delete $item->{plugin};
                next unless( defined $pluginid );

                my $options = delete $item->{options};
                $options ||= {};

                my $local_context = $self->context->clone();

                # local context
                my $done_any = 0;
                foreach( keys %$item )
                {
                        $local_context->{$_} = $item->{$_};
                        $done_any = 1;
                }
                $local_context->parse_context() if( $done_any );

                my $plugin = $session->plugin( "Stats::View::$pluginid", 
			handler => $handler, 
			options => $options, 
			context => $local_context 
		);
                next unless( defined $plugin ); # an error / warning would be nice...
		$div_element->appendChild( $plugin->render );
		$div->appendChild( $div_element );
        }

	return $div;
}

1;
