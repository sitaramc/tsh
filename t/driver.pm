#!/usr/bin/perl -s
use 5.10.0;
use strict;
use warnings;

our($rc, $t1, $t2, $grv, $testnum);
    # grv == generic return value;
$testnum = 0;

# too bad we can't it with itself but that would break some cosmic law
# somewhere, not to mention make the results unreliable :-)

sub tv {
    delete $ENV{TSH_VERBOSE};
    $ENV{TSH_VERBOSE} = $_[0] if defined($_[0]) and $_[0] ~~ [0, 1, 2, 3, 4];
}

sub build_cmd {
    # build a command to pass to test()
    my $cmd = "perl -I.. -MTsh -e 'Tsh::tsh()'";
    for (@_) {
        # we'll assume no double quotes *within* the arguments for now
        $cmd .= " \"$_\"";
    }
    return $cmd;
}

sub test {
    my $tmp = "$ENV{HOME}/tmp";

    my $cmd = build_cmd(@_);

    my ($text1, $text2);
    my $rc = `( $cmd ) >$tmp-1 2>$tmp-2; echo -n RC=\$?`;

    if ($rc =~ /RC=(\d+)$/) {
        $rc = $1;
    } else {
        die "couldnt find RC= in result; this should not happen:\n$t1\n\n$t2\n\n";
    }
    $t1 = slurp("$tmp-1");
    $t2 = slurp("$tmp-2");

    return($rc, $t1, $t2);
}

sub _try {
    local %ENV = %ENV;
    delete $ENV{TSH_VERBOSE};
    delete $ENV{HARNESS_ACTIVE};
    try(@_);
}

sub slurp {
    my $file = shift;
    local $/=undef;
    open(my $fh, "<", $file) or die "open $file failed: $!\n";
    return <$fh>;
}

sub Eq {
    return 1 if true($_[0] eq $_[1]);
    dbg("Eq fail",   $_[0],   $_[1]);
}

sub Ne {
    return 1 if true($_[0] ne $_[1]);
    dbg("Eq fail",   $_[0],   $_[1]);
}

sub true {
    $testnum++;
    if ($_[0]) {
        say "ok ($testnum)";
        return 1;
    } else {
        say "not ok ($testnum)";
        _caller();
    }
    return 0;
}

sub false {
    $testnum++;
    if ($_[0]) {
        say "not ok ($testnum)";
        _caller();
    } else {
        say "ok ($testnum)";
        return 1;
    }
    return 0;
}

sub _caller {
    return unless $ENV{D};
    my @c=(0,0);
    my $i = 0;
    while ($c[1] !~ /t\d\d-/) {
        $i++;
        @c = caller($i);
    }
    say STDERR "vim +$c[2] $c[1] # $testnum";
    return unless $ENV{D} > 1;
    say STDERR "rc=$rc," if defined $rc;
    say STDERR "grv=$grv," if defined $grv;
    say STDERR "t1=$t1," if defined $t1;
    say STDERR "t2=$t2," if defined $t2;
}


sub clean {
    system("rm -f tt-*");
    delete $ENV{TSH_VERBOSE};
    delete $ENV{HARNESS_ACTIVE};
    try("echo hi"); # has the effect of resetting $rc and such
}

sub dbg {
    return unless $ENV{D};
    use Data::Dumper;
    for my $i (@_) {
        print STDERR "DBG: " .  Dumper($i);
    }
}

1;
