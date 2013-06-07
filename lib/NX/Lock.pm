package NX::Lock;

use strict;
use warnings;
use Fcntl ':flock';
use IO::File;

# ABSTRACT: OO Lock interface
# VERSION

=head1 SYNOPSIS

 do {
   my $lock = NX::Lock->new("/tmp/foo.lock");
   die 'no lock!' unless defined $lock;
   # do something which requires the lock
 };
 # lock automatically released

=head1 DESCRIPTION

OO interface to flock.  The lock is automatically 
released when the lock object falls out of scope

=head1 CONSTRUCTOR

=head2 NX::Lock->new( $filename, %options )

On success returns a lock.

Blocks until the lock is obtained if in blocking mode.

Returns undef if in non blocking mode and lock 
could not be obtained.

Options:

=over 4

=item block

Blocking mode.

=item quit_on_fail

Quit the entire program (NOT die!) if not in
blocking mode and lock can not be obtained.

=item shared

Obtain a shared lock.

=back

=cut

sub new
{
  my $obclass = shift;
  my $class = ref($obclass) || $obclass;

  my $fn = shift;
  my %arg = @_;
  die "usage: NX::Lock->new(filename)" unless defined $fn;
  my $lock = new IO::File;
  unless($lock->open(">>$fn"))
  {
    warn "unable to open lock $fn $!";
    
    if($arg{quit_on_fail})
    {
      print STDERR "unable to obtain lock\n";
      exit 1;
    }
    
    return undef;
  }
  my $flags = 0;

  if($arg{shared})
  { $flags |= LOCK_SH }
  else
  { $flags |= LOCK_EX }
  
  if(defined $arg{block} && !$arg{block})
  { $flags |= LOCK_NB }

  if(flock $lock, $flags)
  { return bless { fn => $fn, lock => $lock }, $class }
  
  if($arg{quit_on_fail})
  {
    print STDERR "unable to obtain lock\n";
    exit 1;
  }
  
  return undef;
}

=head1 METHODS

=head2 $lock-E<gt>release

Release the lock.

=cut

sub release
{
  my $self = shift;
  return unless defined $self->{lock};
  $self->{lock}->close;
  delete $self->{lock};
}

sub DESTROY
{
  my $self = shift;
  $self->release;
}

1;
