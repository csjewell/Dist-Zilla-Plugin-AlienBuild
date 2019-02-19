package Dist::Zilla::Plugin::AlienBase::Wrapper::Bundle {

  use 5.014;
  use Moose;
  use Path::Tiny ();

  # ABSTRACT: Bundle a copy of Alien::Base::Wrapper with your dist
  # VERSION

=head1 SYNOPSIS

 [AlienBase::Wrapper::Bundle]

=head1 DESCRIPTION

This module bundled L<Alien::Base::Wrapper> with your distribution, which allows for
late-binding fallback of an alien when a system probe fails.  It removes C<Alien::Base::Wrapper>
as a configure or build prerequisite if found, in case you have a plugin automatically computing
it as a prereq.  (Note that if the prereq is added after this plugin it won't be removed, so
be sure to use this plugin AFTER any auto prereqs plugin).

=head1 ATTRIBUTES

=head2 filename

This specifies the name of the bundled L<Alien::Base::Wrapper>, the default is
C<inc/Alien/Base/Wrapper.pm>.

=cut

  with 'Dist::Zilla::Role::FileGatherer',
       'Dist::Zilla::Role::PrereqSource';

  has filename => (
    is  => 'ro',
    isa => 'Str',
    default => 'inc/Alien/Base/Wrapper.pm',
  );

  sub gather_files
  {
    my($self, $arg) = @_;

    require Alien::Base::Wrapper;
    unless(Alien::Base::Wrapper->VERSION('1.28'))
    {
      $self->log_fatal("requires Alien::Base::Wrapper 1.28, but we have @{[ Alien::Base::Wrapper->VERSION ]}");
    }

    my $file = Dist::Zilla::File::InMemory->new({
      name    => $self->filename,
      content => Path::Tiny->new($INC{'Alien/Base/Wrapper.pm'})->slurp_utf8,
    });

    $self->add_file($file);
  }

  sub register_prereqs
  {
    my($self) = @_;

    $self->zilla->prereqs->requirements_for($_, 'requires')->clear_requirement('Alien::Base::Wrapper')
      for qw( configure build );
  }

  __PACKAGE__->meta->make_immutable;

}

1;
