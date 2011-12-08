#!/bin/sh

# This is just some code snippets collected in one file, not an actual shell
# script you can run, so:
exit 1

# NOTE: some examples assume a "die" function is already defined, like:
#     die() { echo "$@" >&2; exit 1; }

# ----------------------------------------------------------------------

# here's a simple tsh snippet that can go into some longer shell script

    tsh "rpm -qa
        ok           or not an RPM system?
        /git-daemon/ or need git-daemon
        /git-gui/    or need git-gui
    " || exit 1

# ----------------------------------------------------------------------

# so the basic idea is:

#   - run any external command
#   - save its exit status and output for later
#   - allow multiple tests on them, with suitable "fail" messages
#   - return exit codes appropriately to the caller

# ----------------------------------------------------------------------

# readability/writability

# shell is pretty noisy (even more so than perl)!  Since tsh is *not* a
# general purpose language, it makes much less noise.

# original code

    pubkey_file=$1

    if [ -n "$pubkey_file" ]
    then
        echo $pubkey_file | grep '.pub$' >/dev/null || die "$pubkey_file must end in .pub"
        echo $pubkey_file | grep '@' >/dev/null && die "$pubkey_file must not contain '@'"
        [ -f $pubkey_file ] || die "cant find $pubkey_file"
    else
        echo pubkey_file name needed
    fi

# code using tsh

    tsh "
        echo $1
            /./      or die pubkey_file name needed
            /\.pub$/ or die $1 must end in .pub
            !/\@/    or die $1 must not contain '@'
        test -f $1
            ok       or die cant find $1
    " || die


# ----------------------------------------------------------------------

# complexity

# how do you say "exit if gcc 4 is missing or gcc 3 is installed"?

    tsh "rpm -qa
        /gcc-4/     or please install gcc 4
        !/gcc-3/    or please remove  gcc 3
    " || exit 1

# the only way I know of to do this in shell, without using at least a
# temp file, is this:

    cat ~/rpm-qa |
        tee >(grep gcc-3 >/dev/null && echo please remove gcc 3 >&2) |
        grep gcc-4 >/dev/null || echo please install gcc 4

# Yuck!
