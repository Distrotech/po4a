#! /usr/bin/perl
# Man module tester.

#########################

use strict;
use warnings;

my @tests;

mkdir "t/tmp" unless -e "t/tmp";

my $diff_tex_flags= " -I 'This file was generated by po4a' ";

# Simple document (3 tests)
push @tests, {
  'run'  => "LC_ALL=C COLUMNS=80 perl ../po4a-gettextize -f latex -m data-24/simple.tex -p tmp/simple.pot > tmp/simple-gettextize.out 2>&1",
  'test' => "diff -u data-24/simple-gettextize.out tmp/simple-gettextize.out".
        " && perl compare-po.pl data-24/simple.pot tmp/simple.pot",
  'doc'  => "gettextize well a simple tex document",
}, {
  'run'  => "cp data-24/simple.fr.po tmp/ && chmod u+w tmp/simple.fr.po".
        " && LC_ALL=C COLUMNS=80 perl ../po4a-updatepo -f latex -m data-24/simple.tex -p tmp/simple.fr.po > tmp/simple-updatepo.out 2>&1",
  'test' => "diff -u -I '^\.* done\.' data-24/simple-updatepo.out tmp/simple-updatepo.out".
        " && perl compare-po.pl data-24/simple.fr.po tmp/simple.fr.po",
  'doc'  => "updatepo for this document",
}, {
  'run'  => "LC_ALL=C COLUMNS=80 perl ../po4a-translate -f latex -m data-24/simple.tex -p data-24/simple.fr.po -l tmp/simple.fr.tex > tmp/simple-translate.out 2>&1",
  'test' => "diff -u data-24/simple-translate.out tmp/simple-translate.out".
        " && diff -u $diff_tex_flags data-24/simple.fr.tex tmp/simple.fr.tex",
  'doc'  => "translate this document",
};

use Test::More tests => 6;

for (my $i=0; $i<scalar @tests; $i++) {
    chdir "t" || die "Can't chdir to my test directory";

    my ($val,$name);

    my $cmd=$tests[$i]{'run'};
    $val=system($cmd);

    $name=$tests[$i]{'doc'}.' runs';
    ok($val == 0,$name);
    diag($cmd) unless ($val == 0);
    
    SKIP: {
        skip ("Command don't run, can't test the validity of its return",1)
          if $val;
        my $testcmd=$tests[$i]{'test'};    
        
        $val=system($testcmd);
        $name=$tests[$i]{'doc'}.' returns what is expected';
        ok($val == 0,$name);
        unless ($val == 0) {
            diag ("Failed (retval=$val) on:");
            diag ($testcmd);
            diag ("Was created with:");
            diag ("perl -I../lib $cmd");
        }
    }
    
#    system("rm -f tmp/* 2>&1");
    
    chdir ".." || die "Can't chdir back to my root";
}

0;
    
