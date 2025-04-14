module Mult(

	input							clk,
	input							rst,
	input							CEM,
	input							USE_MULT,
	input							MREG,
	input		signed	[24:0]		AMULT,
	input		signed	[17:0]		BMULT,
	output		signed	[47:0]		M
	);

reg	signed	[47:0]	m1;
always@(*)
	begin
		if(USE_MULT)      
			 m1 = AMULT*BMULT;
		else                 
			 m1 =0; //TO SAVE POWER
	end

signed_ports MULT(clk,rst,CEM,MREG,m1,M);
endmodule