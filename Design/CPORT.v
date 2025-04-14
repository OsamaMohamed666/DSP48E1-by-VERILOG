module CPORT(
	input							clk,
	input							rst,
	input							CEC,
	input							CREG,
	input	signed		[47:0]		C,
	output	signed		[47:0]		COUT
	);
	
signed_ports Cport(clk,rst,CEC,CREG,C,COUT);
endmodule 