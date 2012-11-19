#!/bin/bash
./tsh "cd tsh_tempdir;
    init; test-commit a b c test-tick d e tt f; checkout -b new; tc q tt w tt e;
    git for-each-ref
    /c64d5a826595c8313610f7cb8cac9c797b83154a.*master/
    /031004533fe9bc5e4b5fd2f28578aba1d71b7433.*new/
";
echo 1..2
