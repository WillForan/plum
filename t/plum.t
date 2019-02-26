#!/usr/bin/env perl
use strict; use warnings;

# run as t/plumb.t so ./plum is in the right place
require './plum';
use Test::Simple tests => 4;

our $DEBUG=0;
my $textInfo = {};
my $cmd_out = "";

## full config 
open(CONFIG,'<','t/simple.conf');
$textInfo = {'text' => 'http://foo'};
$cmd_out = read_config(*CONFIG, $textInfo) ;
ok($cmd_out eq "xdg-open http://foo", "simple: less specific");
#
seek CONFIG,0,0;
$textInfo = {'text' => 'https://hangouts.google.com'};
$cmd_out = read_config(*CONFIG, $textInfo) ;
ok($cmd_out eq "chromium https://hangouts.google.com", "simple: found more specific");
# 
seek CONFIG,0,0;
$textInfo = {'text' => 'ftp://foo'};
$cmd_out = read_config(*CONFIG, $textInfo) ;
ok($cmd_out eq "filezilla ftp://foo", "simple: found second");
#
seek CONFIG,0,0;
$textInfo = {'text' => 'no url here'};
$cmd_out = read_config(*CONFIG, $textInfo) ;
print $cmd_out, "\n";
ok($cmd_out eq "", "simple: nothing to find");

close CONFIG;
open(CONFIG,'<','t/withcwd.conf');
$textInfo = {text=>'plum.t', app=>'urxvt',title=>"u\@h: $ENV{PWD}/t/"};
$cmd_out = read_config(*CONFIG, $textInfo) ;
ok($cmd_out eq "ls $ENV{PWD}/t/plum.t", "cwd in testdir");
