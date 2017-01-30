package Dist::Zilla::Plugin::AlienBuild;

use strict;
use warnings;
use Moose;
use List::Util qw( first );
use Path::Tiny qw( path );

# ABSTRACT: Use Alien::Build with Dist::Zilla
# VERSION

with 'Dist::Zilla::Role::FileMunger';
with 'Dist::Zilla::Role::MetaProvider';
with 'Dist::Zilla::Role::PrereqSource';

sub register_prereqs
{
  my($self) = @_;

  if(my $file = first { $_->name eq 'alienfile' } @{ $self->zilla->files })
  {
    require Alien::Build;
    my $alienfile = Path::Tiny->tempfile;
    $alienfile->spew($file->content);
    my $build = Alien::Build->load($alienfile);

    # Configure requires...
    $self->zilla->register_prereqs(
      { phase => 'configure' },
      'Alien::Build::MM' => '0.01',
      'ExtUtils::MakeMaker' => '6.52',
      %{ $build->requires('configure') },
    );
    
    # Build requires...
    $self->zilla->register_prereqs(
      { phase => 'build' },
      'Alien::Build::MM' => '0.01',
      %{ $build->requires('any') },
    );
  }
  else
  {
    $self->log_fatal('No alienfile!');
  }
  
}

my $mm_code_prereqs = <<'EOF1';
use Alien::Build::MM;
my $abmm = Alien::Build::MM->new;
%WriteMakefileArgs = $abmm->mm_args(%WriteMakefileArgs);
EOF1

my $mm_code_postamble = <<'EOF2';
sub MY::postamble {
  $abmm->mm_postamble;
}
EOF2

my $comment_begin  = "# BEGIN code inserted by Dist::Zilla::Plugin::AlienBuild\n";
my $comment_end    = "# END code inserted by Dist::Zilla::Plugin::AlienBuild\n";

sub munge_files
{
  my($self) = @_;

  if(my $file = first { $_->name eq 'Makefile.PL' } @{ $self->zilla->files })
  {
    my $content = $file->content;
 
    my $ok = $content =~ s/(unless \( eval \{ ExtUtils::MakeMaker)/"$comment_begin$mm_code_prereqs$comment_end\n\n$1"/e;
    $self->log_fatal('unable to find the correct location to insert prereqs')
      unless $ok;
    
    $content .= "\n\n$comment_begin$mm_code_postamble$comment_end\n";
    
    $file->content($content);
  }
  
  elsif($file = first { $_->name eq 'Makefile.PL' } @{ $self->zilla->files })
  {
    # TODO: support MB
    $self->log_fatal('Build.PL not (yet) supported');
  }
  
  else
  {
    $self->log_fatal('unable to find Makefile.PL or Build.PL');
  }
}

sub metadata {
  my($self) = @_;
  { dynamic_config => 1 };
}


1;
