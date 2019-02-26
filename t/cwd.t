#!/usr/bin/env perl
use strict; use warnings;

# run as t/plumb.t so ./plum is in the right place
require './plum';
use Test::Simple tests => 2;
use Inline::Files -backup;

our $DEBUG=0;

my $rules =  cwd_rules(*SIMPLE);
my $cwd   =  get_cwd($rules, "/path/to/urxvt", 'user@host: /path/to');
ok($cwd eq "/path/to", "simple path from urxvt");
$cwd   =  get_cwd($rules, "/path/to/urxvt", 'bad string no cwd');
ok($cwd eq "", "simple path missing");

__SIMPLE__
parse cwd urxvt \w+@\S+?:\s?(/\S*?)(\s|$) $1
