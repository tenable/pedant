Pedant, a static analysis tool for NASL
=======================================

Installing
----------
If you have Ruby 1.9.3+ and Rubygems installed, you can simply do:
`gem install nasl-pedant`

Using
-----
To check a script, run this: `pedant check scriptname.nasl`.

To check an include, run this: `pedant check includename.inc`.

Checking multiple files together is not currently supported (and has some
semantics questions to be sorted out first). Currently, using xargs is the best
way to check multiple files. For example, for checking all the plugins in a
directory:

    find . -maxdepth 1 -name '*.nasl' | while read fname; do
      echo $fname
      pedant check $fname
      echo
    done > pedant_results_$(date +%s)

Bugs
----

1. Choosing which checks to run does not currently work (`-c` flag)
1. Checking multiple files together does not currently work
1. Only works for up to 5.2 code (will not fix, the `nasl`
  interpreter can now export an AST)
1. Some of the checks have inconsistent titles in terms of "truthiness"
1. No filename is output per-file, which makes checking multiple files difficult

Todo
----

1. Iron out some of the semantics:
   - What is `test mode` used for?
   - Currently files are all checked independently: what should be done when
     we're given `.inc` and `.nasl` files in one invocation?
1. Add a control-flow graph?
1. Add some kind of taint tracking?
