#!/usr/bin/env perl
use strict;

my $cycle = $ARGV[0];
my $PACS_THREADS  = $ARGV[1];

system "source /lustre/gi58/i58005/apps/gmx2016_3/bin/GMXRC.bash";
system "module load anaconda3";

my @high_rankers = `sort -k3n,3 cyc${cycle}/ranking | head -$PACS_THREADS`;
foreach (@high_rankers){
    my ($c, $t, $s, @o) = split /[\-\s]+/;
    my $gro_file = sprintf "%s-%s-%d", $c, $t, $s;
    system "gmx trjconv -f cyc$c/${c}-${t}.xtc ".
                       "-s cyc$c/${c}-${t}.tpr ".
                       "-o cyc$c/$gro_file.gro ". 
                       "-b $s -e $s << zzz\n".
                           "0\n".
                       "zzz";
}

