package YBoxDash;

# Required modules
use LWP::Simple;
use POSIX qw(ceil);

# Optimal screen size for YBox2 InfoWidget
my $WIDTH = 40;
my $LINES = 12;

# Class constructor
sub new {
  my $class = shift;
  my $self = {};
  mkdir "cache";        # Working directory
  $self->{chars} = 0;   # The text to display
  bless($self, $class);
  return $self;
}

# Pad a string on the left
sub str_pad($$) {
  my $self = shift;
  my $text = shift;
  my $block = " " x (($WIDTH - length $text) / 2) . $text . " " x (($WIDTH - length $text) / 2);
  return $self->str_rpad($block);
}

# Pad a string on the right
sub str_rpad($$) {
  my $self = shift;
  my $text = shift;
  my $control_count = () = ($text =~ /[\ca-\cx]/g); 
  my $width = ceil( (length($text) - $control_count) / $WIDTH) * $WIDTH;
  $width += $control_count;
  return pack("A$width",$text);
}

# Obtaine the contents of a cachefile, if it exists (-1 if not)
#   $cachefile: the file name
#   $timeout:   cache expiry time in seconds 
#
sub check_cache($$) {
  my $cachefile = shift;
  my $timeout = shift;
  my $mtime = 0;
  if (-f $cachefile) {
    $mtime = (stat($cachefile))[9] * 1;
  }
  my $timediff = time - $mtime;
  if ($timediff > $timeout) {
    return -1;
  } else {
    if (! open (CACHE, "<$cachefile")) {
      return -1;
    } else {
      my $val = <CACHE>; 
      #$val .= " (${timediff}s)";
      close CACHE;
      return $val;
    }
  }
}

# Write some data to a cache file
sub write_cache($$) {
  my $val = shift;
  my $cachefile = shift;
  if (open (CACHE, ">$cachefile")) {
    print CACHE $val;
    close CACHE;
  }
}

# Get a count of tags from flickr
sub get_tag_count($$$) {
  my $self = shift;
  my $tag = shift;
  my $key = shift;

  # Check the cache first
  my $count = check_cache("cache/tag_count-$tag.txt", 5*60);

  # If the cache is empty or expired, hit up flickr for the data
  if ($count eq "-1") {
    my $flickr = get(
      "http://api.flickr.com/services/rest/?method=flickr.photos.search&tags=$tag&api_key=$key&per_page=1");
    if ($flickr =~ /<photos[^>]*total="(\d+)/) {
      $count = $1;
      write_cache($count, "cache/tag_count-$tag.txt");
    } else {
      $count = "unknown";
    }
  }  
  return $count;
}

# fetch a single tweet matching a term (via summize)
sub get_last_tweet($) {

  my $self = shift;
  my $term = shift;

  # Check the cache first
  my $tweet = check_cache("cache/last_tweet-$term.txt", 60*5);

  # If the cache is empty or expired, hit up search.twitter.com for the data
  if ($tweet eq "-1") {
    my $twit = get("http://search.twitter.com/search.atom?q=$term");
    if ($twit =~ /<entry>.*?<title>([^<]*).*?<name>([^ ]*)/s) {
      $tweet = "$2:$1";
      write_cache($tweet, "cache/last_tweet-$term.txt");
    } else {
      $tweet = "unknown";
    }
  }  
  return $tweet;
}

# fetch the most recent blog entry with a certain tag
sub get_last_post($) {

  my $self = shift;
  my $term = shift;
  my $api_key = shift;

  # Check the cache first
  my $blog = check_cache("cache/last_blog-$term.txt", 60*15);

  # If the cache is empty or expired, hit up technorati for the data
  if ($blog eq "-1") {
    #my $tn = get("http://api.technorati.com/tag?key=$api_key&tag=$term");
    my $tn = get("http://api.technorati.com/search?key=$api_key&query=$term");
    if ($tn =~ 
        /<item>.*?<name>([^<]*).*?<title>([^<]*).*?<permalink>([^<]*)/s) {

      my $url = get("http://is.gd/api.php?longurl=$3");

      $blog = "$1:$2 ($url)";
      write_cache($blog, "cache/last_blog-$term.txt");
    } else {
      $blog = "unknown";
    }
  }  
  return $blog;
}

# draw a line
sub line($) {
  my $self = shift;
  $self->display("†" x $WIDTH);
}

# draw a blank line
sub blankline($) {
  my $self = shift;
  $self->display(" " x $WIDTH);
}

# display some text
sub display($$) {
  my $self = shift;
  my $text = shift;

  # Help out the poor folk who blogged with MS-Word
  $text =~ s/\xe2\x80\x99/'/gs;
  $text =~ s/\xe2\x80\x98/'/gs;
  $text =~ s/\xe2\x80\x9c/"/gs;
  $text =~ s/\xe2\x80\x9d/"/gs;

  return if $self->get_line_count() > $LINES;

  my $line = $self->str_rpad($text);
  my $control_count = () = ($line =~ /[\ca-\cx]/g); 
  $self->{chars} += length($line) - $control_count;
  print $line;
}

# display the last tweet matching a term
sub display_last_tweet($$) {
  my $self = shift;
  my $term = shift;
  my $last_tweet = $self->get_last_tweet($term);
  if ($last_tweet =~ /(.*?):(.*)/) {
    my $tweeter = $1;
    my $tweet = $2;
    $self->display("$tweeter\@twitter: $tweet");
  } else {  
    $self->display($last_tweet, 200);
  }  
  $self->display("(via Summize.com)");
}

# display the last blog post matching a tag
sub display_last_post($$$) {
  my $self = shift;
  my $term = shift;
  my $api_key = shift;
  my $last_post = $self->get_last_post($term, $api_key);
  $self->display($last_post);
  $self->display("(via Technorati.com)");
}

# display the count for a given tag
sub display_tag_count($$$) {
  my $self = shift;
  my $tag = shift;
  my $api_key = shift;
  my $count = $self->get_tag_count($tag, $api_key);
  $self->display("flickr photos tagged $tag: $count");
}

# Display a title
sub title($$) {
  my $self = shift;
  my $title = shift;
  my $text = $self->str_pad($title);
  $self->display("$text");
  #$self->line();
}

sub get_line_count($) {
  my $self=shift;
  return int($self->{chars}/$WIDTH);
}

# clear the screen and finish
sub finish($) {
  my $self = shift;
  my $lines = $self->get_line_count();
  for (my $i = $lines; $i < $LINES; $i++) {
    $self->blankline();
  }
  print "\n";
}

1;
