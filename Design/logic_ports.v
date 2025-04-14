module logic_ports #(parameter width = 4)
	(
	input								clk,
	input								rst,
	input								CE,
	input								REG,
	input				[width-1:0]		IN,
	output				[width-1:0]		OUT
	);
	
reg		[width-1:0]	REGOUT;

always @ (posedge clk)
	begin 
		if (rst)
			REGOUT<=0;
		else if (CE)
			REGOUT <=IN;
	end 

assign OUT = REG? REGOUT : IN;
endmodule 