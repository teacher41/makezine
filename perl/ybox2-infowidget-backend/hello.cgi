#!/usr/bin/perl -w

use strict;
use CGI qw(:standard);
use YBoxDash;

# NOTE: Change these!
#
#my $FLICKR_KEY = "YOUR FLICKR KEY HERE";
#my $TECHNORATI_KEY = "YOUR TECHNORATI KEY HERE";

print header(); # Display a CGI header

my $dash = new YBoxDash(); # Create a YBoxDash object

my $q = param("q"); # Fetch the query string

# Display the title
$dash->title("$q Dashboard");

# Display a tag count
$dash->display_tag_count($q, $FLICKR_KEY);
$dash->blankline();

# Display a recent tweet
$dash->display_last_tweet($q);

# Display a recent blog post
$dash->display_last_post($q, $TECHNORATI_KEY);

$dash->finish();
