module dualB(
	input							clk,
	input							rst,
	input							CEB1,
	input							CEB2,
	input							B_INPUT, //chooses between cascade or direct input
	input	signed		 [17:0]		B,
	input	signed		 [17:0]		BCIN,
	input							IN_MODE,
	input				 [1:0]		BREG, //control signal
	output	signed		 [17:0]		BCOUT, // CASCADING OUTPUT
	output	signed	 	 [17:0]		BMUX, //OUTPUT FOR CONCATENATION WITH A.(LOWER BITS)
	output	signed		 [17:0]		B_MULT //OUTPUT FOR MULTPLICATION PROCESS
	);

reg		signed	[17:0]	B1,B2;
wire	signed	[17:0]	tmp1,tmp2;
wire	signed	[17:0]	b_sel; //selected A

assign	b_sel = B_INPUT? B : BCIN; 
assign	tmp1 = BREG[1]? B1 : b_sel;
assign	tmp2 = BREG[0]? B2 : tmp1;
// *****************B DUAL REGISTERS**************
//B1 
always @(posedge clk)
	begin 
		if(rst)
			B1 <= 0;  
		else if (CEB1) 
			B1 <= b_sel;
	end 	
//B2 
always @(posedge clk)
	begin 
		if(rst)
			B2 <= 0;  
		else if (CEB2)
			B2 <= tmp1;
	end 	
// *****************OUTPUTS**************
assign BCOUT = BREG[1]? B1 : tmp2;
assign BMUX = tmp2;
assign B_MULT = IN_MODE? B1 : tmp2;

endmodule