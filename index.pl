#!/usr/bin/perl
use strict;
use warnings;
use LWP::UserAgent;
use File::Path qw(make_path);
use File::Basename;
$|++;

## Configuration goes here:
my $mirror_base = "http://mirror.aarnet.edu.au/pub/fedora/";	## Base URL to map to - change this to your local mirror
my $local_base = "https://your.web.server/fedora/";		## Where the URL on your server syncs up
my $cache_path = "/var/www/html/fedora/";			## Where to save the actual files. The web server will need write access to this directory.
my $logfile = "/var/log/httpd/mirror_log";			## Where to log mirror details

## Translate the local path to the remote path.
my $url = $ENV{"REQUEST_SCHEME"} . "://" . $ENV{"SERVER_NAME"} . $ENV{"REQUEST_URI"};
$url =~ s/$local_base/$mirror_base/g;

## Translate to the local file cache path
my $localfile = $ENV{"REQUEST_SCHEME"} . "://" . $ENV{"SERVER_NAME"} . $ENV{"REQUEST_URI"};
$localfile =~ s/$local_base/$cache_path/g;
my $localdir = dirname($localfile);
make_path($localdir);

## See if we have to send the local file...
my $send_local_file = 0;

## Start up the UserAgent...
my $ua = LWP::UserAgent->new(timeout => 10);
$ua->add_handler(response_header => \&process_header);
$ua->add_handler(response_data => \&process_data);
my $result = $ua->mirror($url, $localfile) or die "Error downloading: $!";

if ( $send_local_file ) {
	open my $fh, '<', $localfile or die "Error opening '$localfile': $!";
	binmode $fh;
	print <$fh>;
	close $fh;
}

sub process_header {
	my ($response, $ua, $handler) = @_;

	if ( $response->header("content-length") ) {
		print "Content-Length: " . $response->header("content-length") . "\n";
		print "X-Cache: miss\n";
		logline($ENV{"REMOTE_ADDR"} . " - MISS - " . $response->header("content-length") . " - $url\n");
	} else {
		$send_local_file = 1;
		my $filesize = -s $localfile;
		print "Content-Length: " . $filesize . "\n";
		print "X-Cache: hit\n";
		logline($ENV{"REMOTE_ADDR"} . " - HIT - $filesize - $url\n");
	}
	print "Content-Type:\n";
	print "X-Remote-Status: " . $response->status_line . "\n\n";

	return 1;
}

sub process_data {
	my($response, $ua, $handler, $data) = @_;
	print $data;
	return 1;
}

sub logline {
	my $log = shift;
	open(my $fh, '>>', $logfile) or die "Unable to open log: $!\n";
	print $fh $log;
	close $fh;
}
