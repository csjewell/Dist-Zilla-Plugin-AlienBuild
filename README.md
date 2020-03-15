# Dist::Zilla::Plugin::AlienBuild [![Build Status](https://secure.travis-ci.org/Perl5-Alien/Dist-Zilla-Plugin-AlienBuild.png)](http://travis-ci.org/Perl5-Alien/Dist-Zilla-Plugin-AlienBuild)

Use Alien::Build with Dist::Zilla

# SYNOPSIS

```
[AlienBuild]
```

# DESCRIPTION

This [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla) plugin is designed to help create [Alien](https://metacpan.org/pod/Alien) modules using
the [alienfile](https://metacpan.org/pod/alienfile) and [Alien::Build](https://metacpan.org/pod/Alien::Build) recipe system with [Alien::Base](https://metacpan.org/pod/Alien::Base).  The
intent is that you will maintain your [alienfile](https://metacpan.org/pod/alienfile) as you normally would,
and this plugin will ensure the right prereqs are specified in the `META.json`
and other things that are easy to get not quite right.

Specifically, this plugin:

- adds prereqs

    Adds the `configure` requirements to your dist `configure` requires.  It
    adds the `any` requirements from your [alienfile](https://metacpan.org/pod/alienfile) to your dist `build`
    requires.

- adjusts Makefile.PL

    Adjusts your `Makefile.PL` to use [Alien::Build::MM](https://metacpan.org/pod/Alien::Build::MM).  If you are using
    [ExtUtils::MakeMaker](https://metacpan.org/pod/ExtUtils::MakeMaker).

- sets the mb\_class for Build.PL

    sets mb\_class to [Alien::Build::MB](https://metacpan.org/pod/Alien::Build::MB) on the [Dist::Zilla::Plugin::ModuleBuild](https://metacpan.org/pod/Dist::Zilla::Plugin::ModuleBuild)
    plugin.  If you are using [Module::Build](https://metacpan.org/pod/Module::Build).

- turn on dynamic prereqs

    Which are used by most [Alien::Build](https://metacpan.org/pod/Alien::Build) based [Alien](https://metacpan.org/pod/Alien) distributions.

- sets x\_alienfile meta

    Unless you turn this feature off using `alienfile_meta` below.

# PROPERTIES

## alienfile\_meta

As of version 0.23, this plugin adds a special `x_alienfile` metadata to your
`META.json` or `META.yml`.  This contains the `share` and `system` prereqs
based on your alienfile.  This may be useful for one day searching for Aliens
which use another specific Alien during their build.  Note that by their nature,
`share` and `system` prereqs are dynamic, so on some platforms they may
actually be different.

This is on by default.  You can turn this off by setting this property to `0`.

## clean\_install

Sets the clean\_install property on [Alien::Build::MM](https://metacpan.org/pod/Alien::Build::MM).

# SEE ALSO

[Alien::Build](https://metacpan.org/pod/Alien::Build), [alienfile](https://metacpan.org/pod/alienfile), [Alien::Base](https://metacpan.org/pod/Alien::Base), [Alien::Build::MM](https://metacpan.org/pod/Alien::Build::MM), [Alien::Build::MB](https://metacpan.org/pod/Alien::Build::MB),
[Dist::Zilla::Plugin::AlienBase::Doc](https://metacpan.org/pod/Dist::Zilla::Plugin::AlienBase::Doc)

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
