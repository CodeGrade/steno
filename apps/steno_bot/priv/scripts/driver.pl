#!/usr/bin/perl
use 5.16.0;
use warnings FATAL => 'all';

if (scalar @ARGV != 1) {
    die "Usage: driver.pl [phase]\n";
}

my $PHASE = shift;

say "driver, phase: $PHASE";

sub shell {
    my ($cmd) = @_;
    say "! $cmd";
    my $rv = system($cmd);
    die "cmd ($cmd) failed: $?" if $rv;
}

shell("mkdir -p /tmp/steno");

unless (-d "/tmp/steno/defaults") {
    shell("(cd /tmp/steno && tar xvf /root/defaults.tar.gz)");
}

unless (-d "/tmp/steno/grading") {
    shell("mkdir -p /tmp/steno/grading");
    shell("perl /tmp/steno/defaults/unpack.pl /root/gra.tar.gz /tmp/steno/grading");
}

my $cmd = "perl /tmp/steno/defaults/$PHASE.pl";
shell("find /tmp/steno");
if (-f "/tmp/steno/grading/$PHASE.pl") {
    $cmd = "perl /tmp/steno/grading/$PHASE.pl";
}

if ($PHASE eq "unpack") {
    shell("cp /root/sub.tar.gz /tmp/steno/sub.tar.gz");
    $cmd = qq{$cmd "/tmp/steno/sub.tar.gz" "/home/ubuntu"};
}

if ($PHASE eq "setup") {
    shell("(cd /home/ubuntu && $cmd)");
}
else {
    shell("su -c '(cd /home/ubuntu && $cmd)' ubuntu");
}

