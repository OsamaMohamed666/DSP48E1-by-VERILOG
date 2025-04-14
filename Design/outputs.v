module outputs(
	
	input								clk,
	input								rst,
	input								CEP,
	input								PREG,
	input								cout,
	input	signed		[47:0]			res,
	output	signed		[47:0]			P,
	output	signed		[47:0]			PCOUT,
	output								CARRYOUT,
	output								CARRYCASCOUT
	);

wire signed [47:0]	p_tmp;
wire				cout_tmp;
// P Port AND CASCADED
signed_ports Pport(clk,rst,CEP,PREG,res,p_tmp);
assign P = p_tmp;
assign PCOUT = p_tmp;

// CARRY OUT AND CASCADED
logic_ports #(1) carry_out(clk,rst,CEP,PREG,cout,cout_tmp);
assign CARRYOUT = cout_tmp;
assign CARRYCASCOUT = cout_tmp;

endmodule 
