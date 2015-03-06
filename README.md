Pedant, a static analysis tool for NASL
=======================================

Installing
----------
If you have Ruby 1.9.3+ and Rubygems installed, you can simply do:
`gem install nasl-pedant`

Using
-----
To check a script, run this: `pedant check scriptname.nasl`.  You can check
`.inc` files the same way. Multiple files can be checked at the same time.

See a `[WARN]` but there's no explanation of the problem? Try adding `-v`.

Bugs
----

1. Only works for up to 5.2 code (will not fix, the `nasl`
   interpreter can now export an AST)
1. Some of the checks have inconsistent titles in terms of "truthiness"

Todo
----

1. Iron out some of the semantics:
   - Currently files are all checked independently: what should be done when
     we're given `.inc` and `.nasl` files in one invocation?
1. Add a control-flow graph?
1. Add some kind of taint tracking?
