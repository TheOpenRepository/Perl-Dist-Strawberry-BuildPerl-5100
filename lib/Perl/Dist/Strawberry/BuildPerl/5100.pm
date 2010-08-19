package Perl::Dist::Strawberry::BuildPerl::5100;

=pod

=begin readme text

Perl::Dist::Strawberry::BuildPerl::5100 version 2.11_10

=end readme

=for readme stop

=head1 NAME

Perl::Dist::Strawberry::BuildPerl::5100 - Files and code for building perl 5.10.0

=head1 VERSION

This document describes Perl::Dist::Strawberry::BuildPerl::5100 version 2.11_10.

=head1 DESCRIPTION

This module provides the routines that Perl::Dist::Strawberry uses in order to
build Perl itself.  

=begin readme

=head1 INSTALLATION

To install this module, run the following commands:

	perl Build.PL
	./Build
	./Build test
	./Build install

=end readme

=for readme stop

=head1 SYNOPSIS

	# This module is not to be used independently.
	# It provides methods to be called on a Perl::Dist::WiX object.

=head1 INTERFACE

=cut

use 5.010;
use Moose::Role;
use Perl::Dist::WiX::Asset::Perl qw();
use File::ShareDir qw();

our $VERSION = '2.11_10';
$VERSION =~ s/_//sm;




#####################################################################
# Perl installation support

=head2 install_perl_plugin

This routine is called by the 
C<install_perl|Perl::Dist::WiX::BuildPerl/install_perl> task, and installs
perl 5.10.0.

=cut



sub install_perl_plugin {
	my $self = shift;

	# Check for an error in the object.
	if ( not $self->bin_make() ) {
		PDWiX->throw('Cannot build Perl yet, no bin_make defined');
	}

	# Get the information required for Perl's toolchain.
	my $toolchain = $self->_create_perl_toolchain();

	# Install perl.
	my $perl = Perl::Dist::WiX::Asset::Perl->new(
		parent    => $self,
		url       => 'http://strawberryperl.com/package/perl-5.10.0.tar.gz',
		toolchain => $toolchain,
		patch     => [ qw{
			  lib/CPAN/Config.pm
			  win32/config.gc
			  win32/config_sh.PL
			  win32/config_H.gc
			  win32/FindExt.pm
			  ext/GDBM_File/GDBM_File.xs
			  ext/GDBM_File/GDBM_File.pm
			  }
		],
		license => {
			'perl-5.10.0/Readme'   => 'perl/Readme',
			'perl-5.10.0/Artistic' => 'perl/Artistic',
			'perl-5.10.0/Copying'  => 'perl/Copying',
		},
	);
	$perl->install();

	# Should have a perl to use now.
	$self->_set_bin_perl( $self->file(qw/perl bin perl.exe/) );

	# Create the site/bin path so we can add it to the PATH.
	$self->make_path( $self->dir( qw(perl site bin) ) );

	# Add to the environment variables
	$self->add_path( qw(perl site bin) );
	$self->add_path( qw(perl bin) );

	return 1;
} ## end sub install_perl_plugin



around '_find_perl_file' => sub {
	my $orig = shift;
	my $self = shift;
	my $file = shift;
	
	my $location = undef;
	
	$location = eval { 
		File::ShareDir::module_file('Perl::Dist::Strawberry::BuildPerl::5100', $file);
	};
	
	if ($location) {
		return $location;
	} else {
		return $self->$orig($file);
	}
};

no Moose::Role;

1;

__END__

=pod

=head1 DIAGNOSTICS

See L<Perl::Dist::WiX::Diagnostics|Perl::Dist::WiX::Diagnostics> for a list of
exceptions that this module can throw.

=head1 BUGS AND LIMITATIONS (SUPPORT)

Bugs should be reported via: 

1) The CPAN bug tracker at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Perl-Dist-WiX>
if you have an account there.

2) Email to E<lt>bug-Perl-Dist-WiX@rt.cpan.orgE<gt> if you do not.

For other issues, contact the topmost author.

=head1 AUTHORS

Curtis Jewell E<lt>csjewell@cpan.orgE<gt>

Adam Kennedy E<lt>adamk@cpan.orgE<gt>

=head1 SEE ALSO

L<Perl::Dist::WiX|Perl::Dist::WiX>, 
L<http://ali.as/>, L<http://csjewell.comyr.com/perl/>

=for readme continue

=head1 COPYRIGHT AND LICENSE

Copyright 2009 - 2010 Curtis Jewell.

Copyright 2008 - 2009 Adam Kennedy.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this distribution.

=for readme stop

=cut
