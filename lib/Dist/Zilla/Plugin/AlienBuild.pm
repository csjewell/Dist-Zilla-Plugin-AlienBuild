package Dist::Zilla::Plugin::AlienBuild;

use strict;
use warnings;
use Moose;
use List::Util qw( first );

# ABSTRACT: Use Alien::Build with Dist::Zilla
# VERSION

with 'Dist::Zilla::Role::FileMunger';
with 'Dist::Zilla::Role::MetaProvider';

sub munge_files
{
  my($self) = @_;
  
  if(my $file = first { $_->name eq 'Makefile.PL' } @{ $self->zilla->files })
  {
    die 'todo';
  }
  
  elsif($file = first { $_->name eq 'Makefile.PL' } @{ $self->zilla->files })
  {
    $self->log_fatal('Build.PL not (yet) supported');
  }
  
  else
  {
    $self->log_fatal('unable to find Makefile.PL or Build.PL');
  }
}

sub metadata {
  my($self) = @_;
  { dynamic_config => $self->dynamic_config };
}


1;
