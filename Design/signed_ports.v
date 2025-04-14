module signed_ports(
	input							clk,
	input							rst,
	input							CE,
	input							REG,
	input	signed		[47:0]		IN,
	output	signed		[47:0]		OUT
	);
	
reg	signed	[47:0]	REGOUT;

always @ (posedge clk)
	begin 
		if (rst)
			REGOUT<=0;
		else if (CE)
			REGOUT <=IN;
	end 

assign OUT = REG? REGOUT : IN;
endmodule 