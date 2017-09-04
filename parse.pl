use warnings;
use strict;
use IO::Socket::INET;



my @route_table = (
	["catalog", "s_catalog", "v_name"],
	["book", "s_book", "v_isbn"],
	["booker", "s_book", "v_isbn", "v_isbn"],
	["huy", "s_gandon", "v_vstavit", "v_vagina", "s_orgazm"]
);

sub route_exec{
	my ($url) = @_;
	
	my $error;
	my $name_func_to_run;
	my @params_to_func;
	my @array_path = split /\//, $url;
	my $array_path_size = @array_path;
	
	my $route_table_size = @route_table;

	for (my $i = 0; $i < $route_table_size; $i++){
		$error = 0;
		@params_to_func = ();
		my $route_link = $route_table[$i];
		my @tmp_array = @$route_link;
		

		my $route_size = @tmp_array;

		if($route_size == $array_path_size){
			
			for (my $j = 1; $j < $route_size; $j++) {

				my $prefix = substr($tmp_array[$j], 0, 2);
				
				my $route_param = $tmp_array[$j];
				substr($route_param, 0, 2) = "";				

				if($prefix eq "s_"){
					if($route_param ne $array_path[$j]){
						$error = 1;
						last;
					}
				}
				else{
					push(@params_to_func, $array_path[$j]);
				}
			}

			if(!$error){
				$name_func_to_run = $tmp_array[0];
				last;
			}
		}
	}

	if (!$error) {
		#run_fun($name_func_to_run, @params_to_func);
		#print "reter $name_func_to_run \n";
		return $name_func_to_run;
	}
	else{
		return 0;
	}

}

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
    my $trash = "";
    $client_socket->recv($data, 1024);
    print "received data: $data\n";

	
	my $header = $data;
	
	

	my @header_array = split /\s/, $header;
	my $header_url = $header_array[1];
	my $lgf = length $header_url;
	print "Header url - :$header_url: \n";   
 	my $data_text;
 	if($header_url ne ""){
 		$data_text = route_exec($header_url);
 		$data = "HTTP/1.0 200 OK\n $data_text \n";
 		print "Ответ от route_exec: $data_text";
 	}
    else{
    	$data = "HTTP/1.0 200 OK\n ERRoR\n\n";
    }# write response data to the connected client 
    
    $client_socket->send($data);
 
    # notify client that response has been sent
    shutdown($client_socket, 1);
}
 
$socket->close();
