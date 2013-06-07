package NX::Lock;

use strict;
use warnings;
use Fcntl ':flock';
use IO::File;

# ABSTRACT: OO Lock interface
# VERSION

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
