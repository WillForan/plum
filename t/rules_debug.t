#!/usr/bin/env perl
use strict; use warnings;

# run as t/plumb.t so ./plum is in the right place
$ENV{PLUM_DEBUGID} = "simple2";
require './plum';
use Test::Simple tests => 2;
use Inline::Files;

#our $DEBUG=0;
my $textInfo = {};
my $cmd_out = "";

# basic
$textInfo = {'text' => 'https://www.google.com'};
$cmd_out = cmd_from_section(*SIMPLE,$textInfo) ;
ok($cmd_out eq "test2", "DEBUGID: match only simple2 ($cmd_out)");

# reset and fail to find -- even though there is a match for another 
$textInfo = {'text' => 'this is not a url'};
seek SIMPLE,0,0;
$cmd_out = cmd_from_section(*SIMPLE,$textInfo) ;
ok($cmd_out eq "", "DEBUGID: no url match");


__SIMPLE__
# no pattern id
text matches ^https?://.*
start test0

patternid simple1
text matches ^https?://.*
start test1

patternid simple2
text matches ^https?://.*
start test2

patternid simple3
text matches .*
start test3



