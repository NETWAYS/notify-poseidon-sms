notify-poseidon-sms
===================
 
This plugin can be used to send SMS through poseidon sensor
devices equipped with SOAP interface and SIM card.

    
### Usage

    ./notify_poseidon_soap.pl -H 192.0.2.10 -M "Test message" -D 555555555

    date | ./notify_poseidon_soap.pl -H 192.0.2.10 -M -D 555555555 -q

    ./notify_poseidon_soap.pl -H 192.0.2.10 -M -D 555555555 -q < /tmp/file

Options:

    notify_poseidon_soap.pl [options] -H <hostname> -D <destination> -M
    <message>

    -H  Hostname - Poseidon hostname or IP address

    -D  Destination number, shall be in a format supported by your mobile
        provider

    -M  Message - shall be quoted and/or escaped correctly. Strings longer
        than 160 chars will be truncated silenty.

    -h|--help
        Show help page

    -v|--verbose
        Be verbose, show XML messages

    -q|--quiet
        Be quiet - no output unless error occurs
