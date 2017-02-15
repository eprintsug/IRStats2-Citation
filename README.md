#IRStats2-Citation
##Citation count Processor and Report for IRStats2

This extension to IRStats2 provides processor modules and reports for aggregation of
citation counts from Web of Science and Scopus. Also, a processor and report for journals
and publishers is provided.

See http://www.zora.uzh.ch/cgi/stats/report for a live demo.


##Requirements

IRStats 2.0 (http://bazaar.eprints.org/365/) installed and working.

Scopus citation counts: Can be imported using the Citation count and dataset plugin 
developed by the Queensland University of Technology (http://files.eprints.org/815/)

Web of Science counts: Depending on your WoS license, citation counts can be imported 
either using the Citation count and dataset plugin 
developed by the Queensland University of Technology (http://files.eprints.org/815/), or 
the WoS LAMR script developed by University of Zurich 
(https://github.com/eprintsug/WoSLAMR-Import)


##General setup

The setup procedure consists of the following steps

- Installation
- Configuration
- Recalculation of the complete IRStats2 statistics



##Installation

Copy the content of cfg directory to the respective 
{eprints_root}/archives/{yourarchive}/cfg directory


##Configuration

###Edit your configuration for IRStats2

In cfg.d/z_stats_example.pl we provide an example configuration as it is used for the
University of Zurich.

From this file, copy the configurations that are between \# UZH CHANGE ... and \# END 
UZH CHANGE into your configuration file for IRStats2 (cfg.d/z_stats.pl or similar). 

Edit the line that starts with $c->{irstats2}->{wos_citations}->{field_id} and insert the
field name according to your setup ('wos_impact' or 'woslamr_times_cited').

To enable the reports, copy the lines in cfg.d/plugins_snippet.pl into your 
cfg.d/plugins.pl at the section for your plugin mappings (starting with \# Plugin Mapping).


###Restart the web server

After you have edited the configuration files, restart the web server.


###Recalculation of the complete IRStats2 statistics

Rerun 

bin/stats/process_stats {yourrepo} --setup









