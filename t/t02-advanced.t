#!/bin/bash
./tsh "cd tsh_tempdir;
    init; test-commit a b c test-tick d e tt f; checkout -b new; tc q tt w tt e;
    git for-each-ref
    /aa6f396f334851a4b44990c259e9868b39c93e4b.*master/
    /48b59019bae80b5fdba313ec9b282e1d5ef1172b.*new/
";
echo 1..2
