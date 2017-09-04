#use Modern::Perl;
use warnings;
use strict;
use IO::Socket::INET;
 
# auto-flush on socket
$| = 1;
 
# creating a listening socket
my $socket = new IO::Socket::INET (
    LocalHost => '0.0.0.0',
    LocalPort => '8085',
    Proto => 'tcp',
    Listen => 5,
    Reuse => 1
);
die "cannot create socket $!\n" unless $socket;
print "server waiting for client connection on port 7777\n";
 
while(1)
{
    # waiting for a new client connection
    my $client_socket = $socket->accept();
 
    # get information about a newly connected client
    my $client_address = $client_socket->peerhost();
    my $client_port = $client_socket->peerport();
    print "connection from $client_address:$client_port\n";
 
    # read up to 1024 characters from the connected client
    my $data = "";
    my $lgdata;
    $client_socket->recv($data, 1024);
    $lgdata = length($data);
    print "received data length: $lgdata : $data\n";
 #   $client_socket->recv($trash, 16);
#    print "recev data: $trash\n"; 
    # write response data to the connected client
    $data = "HTTP/1.0 200 OK\n\nHi!\n";
    $client_socket->send($data);
 
    # notify client that response has been sent
    shutdown($client_socket, 1);
}
 
$socket->close();
