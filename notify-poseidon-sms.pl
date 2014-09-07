#!/usr/bin/perl -w
# $Id$

=pod

=head1 COPYRIGHT

 
This software is Copyright (c) 2011 NETWAYS GmbH, Thomas Gelf
                               <support@netways.de>

(Except where explicitly superseded by other copyright notices)

=head1 LICENSE

This work is made available to you under the terms of Version 2 of
the GNU General Public License. A copy of that license should have
been provided with this software, but in any event can be snarfed
from http://www.fsf.org.

This work is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
02110-1301 or visit their web page on the internet at
http://www.fsf.org.


CONTRIBUTION SUBMISSION POLICY:

(The following paragraph is not intended to limit the rights granted
to you to modify and distribute this software under the terms of
the GNU General Public License and is only of importance to you if
you choose to contribute your changes and enhancements to the
community by submitting them to NETWAYS GmbH.)

By intentionally submitting any modifications, corrections or
derivatives to this work, or any other work intended for use with
this Software, to NETWAYS GmbH, you confirm that
you are the copyright holder for those contributions and you grant
NETWAYS GmbH a nonexclusive, worldwide, irrevocable,
royalty-free, perpetual, license to use, copy, create derivative
works based on those contributions, and sublicense and distribute
those contributions and any derivatives thereof.


=head1 NAME

notify_poseidon_soap.pl

=head1 SYNOPSIS

./notify_poseidon_soap.pl -H 192.0.2.10 -M "Test message" -D 555555555

date | ./notify_poseidon_soap.pl -H 192.0.2.10 -M -D 555555555 -q

./notify_poseidon_soap.pl -H 192.0.2.10 -M -D 555555555 -q < /tmp/file

=head1 OPTIONS

notify_poseidon_soap.pl [options] -H <hostname> -D <destination> -M <message>

=over

=item   B<-H>

Hostname - Poseidon hostname or IP address

=item   B<-D>

Destination number, shall be in a format supported by your mobile
provider

=item   B<-M>

Message - shall be quoted and/or escaped correctly. Strings
longer than 160 chars will be truncated silenty.

=item   B<-h|--help>

Show help page

=item   B<-v|--verbose>

Be verbose, show XML messages

=item   B<-q|--quiet>

Be quiet - no output unless error occurs

=back

=head1 DESCRIPTION

This plugin can be used to send SMS through poseidon sensor
devices equipped with SOAP interface and SIM card.

=cut

use LWP;
use Getopt::Long;
use Pod::Usage;
use File::Basename;

# predeclared subs
use subs qw/help/;

# predeclared vars
use vars qw (
  $PROGNAME
  $VERSION

  $queue_id

  $opt_host
  $opt_help
  $opt_message
  $opt_destination
  $opt_silent
  $opt_verbose
);

# Main values
$PROGNAME = basename($0);
$VERSION  = '1.0';

# Retrieve commandline options
Getopt::Long::Configure('bundling');
GetOptions(
	'h|help'    => \$opt_help,
	'H=s'       => \$opt_host,
	'D=s'       => \$opt_destination,
	'M=s',      => \$opt_message,
	'v|verbose' => \$opt_verbose,
	'q|quiet'   => \$opt_silent,
	'V'		    => \$opt_version
) || help( 1, 'Please check your options!' );

# Any help needed?
help(99) if $opt_help;
help(-1) if $opt_version;
help(1, 'Not enough options specified!') unless ($opt_host && $opt_destination);

if (! $opt_message) {
    $opt_message .= $_ while (<>);
}

$opt_message = substr($opt_message, 0, 160);
$url = 'http://' . $opt_host . '/service.xml';

$xml = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:pos="poseidonService.xsd">
<soapenv:Header/>
	<soapenv:Body>
	<pos:QueueAdd>
	<Queue>GsmOut</Queue>
	<Gsm>
		<Cmd>SMS</Cmd>
		<Nmr>[DESTINATION]</Nmr>
		<Text>[MESSAGE]</Text>
	</Gsm>
    </pos:QueueAdd>
	</soapenv:Body>
</soapenv:Envelope>
';

$xml =~ s/\[DESTINATION\]/$opt_destination/;
$xml =~ s/\[MESSAGE\]/$opt_message/;

my $ua = new LWP::UserAgent;
$ua->agent("PoseidonSMSNotification/1.0 " . $ua->agent);

my $request = new HTTP::Request POST => $url;
$request->content_type('text/xml');
$request->content($xml);
print "Sent:\n" . $xml if ($opt_verbose);
my $response = $ua->request($request);

if (! $response->is_success()) {
    die("Notification failed, got " . $response->status_line());
}
$data = $response->content();
if ($data =~ m/>(\d+)</) {
    $queue_id = $1;
} else {
    $queue_id = 'UNKNOWN';
}

print "Received:\n" . $data if $opt_verbose;
printf "OK, message sent with ID %s to '%s'\n", $queue_id, $opt_destination unless $opt_silent;
exit 0;

# help($level, $msg);
# prints some message and the POD DOC
sub help {
	my ($level, $msg) = @_;
	$level = 0 unless ($level);
	if ($level == -1) {
		print "$PROGNAME - Version: $VERSION\n";
		exit $states{UNKNOWN};
	}
	pod2usage({
		-message => $msg,
		-verbose => $level
	});
	exit $states{'UNKNOWN'};
}

1;

