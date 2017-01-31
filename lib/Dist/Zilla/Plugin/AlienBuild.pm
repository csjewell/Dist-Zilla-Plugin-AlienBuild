package Dist::Zilla::Plugin::AlienBuild;

use strict;
use warnings;
use 5.014;
use Moose;
use List::Util qw( first );
use Path::Tiny qw( path );

# ABSTRACT: Use Alien::Build with Dist::Zilla
# VERSION

=head1 SYNOPSIS

 [AlienBuild]

=head1 DESCRIPTION

This L<Dist::Zilla> plugin is designed to help create L<Alien> modules using
the L<alienfile> and L<Alien::Build> recipe system with L<Alien::Base>.  The
intent is that you will maintain your L<alienfile> as you normally would,
and this plugin will ensure the right prereqs are specified in the C<META.json>
and other things that are easy to get not quite right.

Specifically, this plugin:

=over 4

=item adds prereqs

Adds the C<configure> requirements to your dist C<configure> requires.  It
adds the C<any> requirements from your L<alienfile> to your dist C<build>
requires.

=item adjusts Makefile.PL

Adjusts your C<Makefile.Pl> to use L<Alien::Build::MM>.  In the future C<Build.PL>
may be supported.

=item turn on dynamic prereqs

Which are used by most L<Alien::Build> based L<Alien> distributions.

=back

=head1 SEE ALSO

L<Alien::Build>, L<alienfile>, L<Alien::Base>, L<Alien::Build::MM>

=cut

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
