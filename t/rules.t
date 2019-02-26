#!/usr/bin/env perl
use strict; use warnings;

# run as t/plumb.t so ./plum is in the right place
require './plum';
use Test::Simple tests => 9;
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


# check isfile
$textInfo = {'text' => 't/plum.t'};
$cmd_out = cmd_from_section(*ISFILE, $textInfo) ;
ok($cmd_out eq "vimit t/plum.t", "section: isfile");

seek ISFILE,0,0;
$textInfo = {'text' => 't/DNE'};
$cmd_out = cmd_from_section(*ISFILE, $textInfo) ;
ok($cmd_out eq "", "section: not isfile");



# check isdir
$textInfo = {'text' => 't/'};
$cmd_out = cmd_from_section(*ISDIR, $textInfo) ;
ok($cmd_out eq "pcmanfm t/", "section: isdir");
seek ISDIR,0,0;
$textInfo = {'text' => 'DNE'};
$cmd_out = cmd_from_section(*ISFILE, $textInfo) ;
ok($cmd_out eq "", "section: not isdir");



__SIMPLE__
text matches ^https?://.*
start xdg-open $text

__PATTERN__
# use ctrl+c clipboard to convert images when in inkscape
text matches ^(\S+).(jpe?g|gif|ppm)$
add base=$1 ext=$2
app matches inkscape
start convert $text $base.png

__ISFILE__
text matches (\S+)
arg isfile $1
start vimit $file

__ISDIR__
text matches (\S+)
add mdir=$1
arg isdir $mdir
start pcmanfm $dir

__CLIPBOARD__
from secondary

