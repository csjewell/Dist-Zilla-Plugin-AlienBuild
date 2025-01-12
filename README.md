# Dist::Zilla::Plugin::AlienBuild ![linux](https://github.com/PerlAlien/Dist-Zilla-Plugin-AlienBuild/workflows/linux/badge.svg)

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

## eumm\_hash\_var

Sets the variable name that is used in the Makefile.PL for its arguments.
Defaults to `%WriteMakefileArgs`, and is required to begin with `%` or `$`.
This is useful when defining your own Makefile template with [Dist::Zilla::Plugin::MakeMaker::Custom](https://metacpan.org/pod/Dist::Zilla::Plugin::MakeMaker::Custom).

# NOTES

When defining your own Makefile.PL template (to use with
Dist::Zilla::Plugin::MakeMaker::Custom, for example,) you can specify
where you want this module to insert its code by having this line
in the template:

```
# ALIEN BUILD MM
```

An example template to use would be this:

```perl
use ExtUtils::MakeMaker ##{ $eumm_version ##};

my %args = (
  NAME => "My::Alien::Module",
##{ $plugin->get_default(qw(ABSTRACT AUTHOR LICENSE VERSION)) ##}
##{ $plugin->get_prereqs(1) ##}
);

# ALIEN BUILD MM

WriteMakefile(%args);
```

and a dist.ini using this template would include this:

```
[MakeMaker::Custom]
# We need to manipulate %args on-the-fly if we set the version of ExtUtils::MakeMaker any lower.
eumm_version: 6.64

[AlienBuild]
eumm_hash_var: %args
```

# SEE ALSO

[Alien::Build](https://metacpan.org/pod/Alien::Build), [alienfile](https://metacpan.org/pod/alienfile), [Alien::Base](https://metacpan.org/pod/Alien::Base), [Alien::Build::MM](https://metacpan.org/pod/Alien::Build::MM), [Alien::Build::MB](https://metacpan.org/pod/Alien::Build::MB),
[Dist::Zilla::Plugin::AlienBase::Doc](https://metacpan.org/pod/Dist::Zilla::Plugin::AlienBase::Doc)

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2017-2025 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
