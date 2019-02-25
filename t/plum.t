#!/usr/bin/env perl
use strict; use warnings;

# run as t/plumb.t so ./plum is in the right place
require './plum';
use Test::Simple tests => 8;
use Inline::Files -backup;

our $DEBUG=0;
my $textInfo = {};
my $cmd_out = "";

# basic
$textInfo = {'text' => 'https://www.google.com'};
$cmd_out = cmd_from_section(*SIMPLE,$textInfo) ;
ok($cmd_out eq "xdg-open $textInfo->{text}", "section: match url");

# reset and fail to find
$textInfo = {'text' => 'this is not a url'};
seek SIMPLE,0,0;
$cmd_out = cmd_from_section(*SIMPLE,$textInfo) ;
ok($cmd_out eq "", "section: no url match");


# using a pattern
$textInfo = {'text' => '/path/to/img.gif','app'=>'bin/inkscape'};
$cmd_out = cmd_from_section(*PATTERN, $textInfo) ;
ok($cmd_out eq "convert /path/to/img.gif /path/to/img.png", "section: pattern match and replace");

# fail b/c bad app
seek PATTERN,0,0;
$textInfo = {'text' => '/path/to/img.gif','app'=>'gimp'};
$cmd_out = cmd_from_section(*PATTERN, $textInfo) ;
ok($cmd_out eq "", "section: bad app");

# fail b/c bad path
seek PATTERN,0,0;
$textInfo = {'text' => '/path/to/file.pdf','app'=>'gimp'};
$cmd_out = cmd_from_section(*PATTERN, $textInfo) ;
ok($cmd_out eq "", "section: bad path");


## full config 
open(CONFIG,'t/simple.conf');
$textInfo = {'text' => 'http://foo'};
$cmd_out = read_config(*CONFIG, $textInfo) ;
ok($cmd_out eq "xdg-open http://foo", "full: less specific");
#
seek CONFIG,0,0;
$textInfo = {'text' => 'https://hangouts.google.com'};
$cmd_out = read_config(*CONFIG, $textInfo) ;
ok($cmd_out eq "chromium https://hangouts.google.com", "full: found more specific");
# 
seek CONFIG,0,0;
$textInfo = {'text' => 'ftp://foo'};
$cmd_out = read_config(*CONFIG, $textInfo) ;
ok($cmd_out eq "filezilla ftp://foo", "full: found second");
#
seek CONFIG,0,0;
$textInfo = {'text' => 'no url here'};
$cmd_out = read_config(*CONFIG, $textInfo) ;
print $cmd_out, "\n";
ok($cmd_out eq "", "full: nothing to find");


__SIMPLE__
text matches ^https?://.*
start xdg-open $text

__PATTERN__
# use ctrl+c clipboard to convert images when in inkscape
text matches ^(\S+).(jpe?g|gif|ppm)$
add base=$1 ext=$2
app matches inkscape
start convert $text $base.png

__CLIPBOARD__
from secondary

