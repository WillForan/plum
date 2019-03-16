#!/usr/bin/env perl
use strict; use warnings;

# run as t/plumb.t so ./plum is in the right place
require './plum';
use Test::Simple tests => 16;
use Inline::Files;

#our $DEBUG=0;
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

# match over newline
$textInfo = {'text' => '~/path [junk]
   ls he*
   here.txt'};
$cmd_out = cmd_from_section(*NEWLINE,$textInfo) ;
ok($cmd_out eq "~/path/here.txt", "section: match over newline ($cmd_out)");


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


# not pattern
seek NOTPATTERN,0,0;
$textInfo = {'text' => '/path/to/img.gif','app'=>'bin/inkscape'};
$cmd_out = cmd_from_section(*NOTPATTERN, $textInfo) ;
ok($cmd_out eq "convert /path/to/img.gif /path/to/img.png", "section: !matches");

# fail b/c !matches
seek NOTPATTERN,0,0;
$textInfo = {'text' => '/path/to/img_converted.gif','app'=>'bin/inkscape'};
$cmd_out = cmd_from_section(*NOTPATTERN, $textInfo) ;
ok($cmd_out eq "", "section: !matches");



# check isfile
$textInfo = {'text' => 't/plum.t'};
$cmd_out = cmd_from_section(*ISFILE, $textInfo) ;
ok($cmd_out eq "vimit t/plum.t", "section: isfile");

seek ISFILE,0,0;
$textInfo = {'text' => 't/DNE'};
$cmd_out = cmd_from_section(*ISFILE, $textInfo) ;
ok($cmd_out eq "", "section: not isfile");

# notisfile
# check isfile
$textInfo = {'text' => 't/plum.t'};
$cmd_out = cmd_from_section(*NOTISFILE, $textInfo) ;
ok($cmd_out eq "", "section: not notisfile");

seek NOTISFILE,0,0;
$textInfo = {'text' => 't/DNE'};
$cmd_out = cmd_from_section(*NOTISFILE, $textInfo) ;
ok($cmd_out eq "notfile t/DNE", "section: notisfile");



# check isdir
$textInfo = {'text' => 't/'};
$cmd_out = cmd_from_section(*ISDIR, $textInfo) ;
ok($cmd_out eq "pcmanfm t/", "section: isdir");
seek ISDIR,0,0;
$textInfo = {'text' => 'DNE'};
$cmd_out = cmd_from_section(*ISDIR, $textInfo) ;
ok($cmd_out eq "", "section: not isdir");

# !isdir
$textInfo = {'text' => 'DNE'};
$cmd_out = cmd_from_section(*NOTISDIR, $textInfo) ;
ok($cmd_out eq "notdir DNE", "section: notisdir");
seek NOTISDIR,0,0;
$textInfo = {'text' => 't/'};
$cmd_out = cmd_from_section(*NOTISDIR, $textInfo) ;
ok($cmd_out eq "", "section: fail notisdir");



__SIMPLE__
text matches ^https?://.*
start xdg-open $text

__NEWLINE__
text matches ([~/]\S+).*?(\S+)\s*$
start $1/$2

__PATTERN__
# use ctrl+c clipboard to convert images when in inkscape
text matches ^(\S+).(jpe?g|gif|ppm)$
add base=$1 ext=$2
app matches inkscape
start convert $text $base.png

__NOTPATTERN__
# use ctrl+c clipboard to convert images when in inkscape
text matches ^(\S+).(jpe?g|gif|ppm)$
add base=$1 ext=$2
base !matches (converted)
app matches inkscape
start convert $text $base.png

__ISFILE__
text matches (\S+)
arg isfile $1
start vimit $file

__NOTISFILE__
text matches (\S+)
arg !isfile $1
start notfile $text

__ISDIR__
text matches (\S+)
arg isdir $1
start pcmanfm $dir

__NOTISDIR__
text matches (\S+)
arg !isdir $1
start notdir $1

__CLIPBOARD__
from secondary

