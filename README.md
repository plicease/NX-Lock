# NX::Lock

OO Lock interface

# SYNOPSIS

    do {
      my $lock = NX::Lock->new("/tmp/foo.lock");
      die 'no lock!' unless defined $lock;
      # do something which requires the lock
    };
    # lock automatically released

# DESCRIPTION

OO interface to flock.  The lock is automatically 
released when the lock object falls out of scope

# CONSTRUCTOR

## NX::Lock->new( $filename, %options )

On success returns a lock.

Blocks until the lock is obtained if in blocking mode.

Returns undef if in non blocking mode and lock 
could not be obtained.

Options:

- block

    Blocking mode.

- quit\_on\_fail

    Quit the entire program (NOT die!) if not in
    blocking mode and lock can not be obtained.

- shared

    Obtain a shared lock.

# METHODS

## $lock->release

Release the lock.

# AUTHOR

Graham Ollis &lt;plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
