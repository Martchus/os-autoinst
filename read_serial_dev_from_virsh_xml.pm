use strict;
use XML::LibXML;

# supposed to be called like this while 'openQA-SUT-1' is running to connect to to its serial port '1':
# sudo screen "$(sudo virsh dumpxml openQA-SUT-1 | perl read_serial_dev_from_virsh_xml.pm 1)"

# read the port number we're looking for
my $arg_count = $#ARGV + 1;
if ($arg_count != 1) {
    print "Exactly one port number must be passed as CLI argument\n";
    exit -1;
}
my $port_number = $ARGV[0];

# parse XML from stdin
my @xml_lines = <STDIN>;
my $xml = XML::LibXML->load_xml(string => join("", @xml_lines));

# loop though all serial elements
my @serial_elements = $xml->getElementsByTagName('serial');
for my $serial_element (@serial_elements) {
    # skip if there's no target element with the port we're looking for
    my $has_specified_port;
    my $target_elements = $serial_element->find('target') or next;
    for my $target_element ($target_elements->get_nodelist) {
        for my $attribute ($target_element->attributes) {
            next unless $attribute->nodeName eq 'port';
            next unless $attribute->getValue eq $port_number;
            $has_specified_port = 1;
            last;
        }
    }
    next unless $has_specified_port;

    # print the path of the device
    my $source_elements = $serial_element->find('source') or next;
    for my $source_element ($source_elements->get_nodelist) {
        for my $attribute ($source_element->attributes) {
            next unless $attribute->nodeName eq 'path';
            print($attribute->getValue . "\n");
            exit 0;
        }
    }
}

exit -2;
