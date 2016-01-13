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

Development
-----------

This project uses [Bundler](http://bundler.io/).

If you have a brand-new Debian machine, do this as root:

    apt-get install ruby-dev rubygems git
    gem install bundler

As your regular user:

    git clone https://github.com/tenable/pedant
    cd pedant
    bundle install --path vendor/bundle
    bundle exec rake tests

All the tests should pass!

To run the Pedant command line, do `bundle exec ./bin/pedant`, which should give
a help message.

If you get an error like this, try prefixing your command with `bundle exec`:

    /usr/lib/ruby/2.x.x/rubygems/core_ext/kernel_require.rb:NN:in `require': cannot load such file -- libname (LoadError)

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
