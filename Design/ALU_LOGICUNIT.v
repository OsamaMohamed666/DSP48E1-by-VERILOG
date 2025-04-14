module ALU_LOGICUNIT(
	input				[3:0]		alu_ctrl,
	input				[1:0]		OP_MODE, //bits select logic unit output (OPMODE[3:2])
	input							CIN,
	input		signed	[47:0]		x,
	input		signed	[47:0]		y,
	input		signed	[47:0]		z,
	output	reg	signed	[47:0]		res,
	output	reg						cout
	);
wire inv;
assign inv = (OP_MODE == 2'b10);


always @(*)
	begin
		cout=0;
		case(alu_ctrl)
//********************First different operation of ALU********************
			4'b0000 : 	{cout,res} = z+x+y+CIN; 
			4'b0001	: 	{cout,res} = ~(z)+x+y+CIN;
			4'b0010	: 	{cout,res} = ~(z+x+y+CIN);
			4'b0011 : 	{cout,res} = z-(x+y+CIN);
//********************Second different operation of LOGIC UNIT********************
			4'b0100 : 	begin 
						if(inv)
							res = ~(x ^ z);
						else 
							res = x ^ z;
						end
			4'b0101 : 	begin 
						if(inv)
							res = (x ^ z);
						else 
							res = ~(x ^ z);
						end
			4'b0110 : 	begin 
						if(inv)
							res = (x ^ z);
						else 
							res = ~(x ^ z);
						end
			4'b0111 : 	begin 
						if(inv)
							res = ~(x ^ z);
						else 
							res = x ^ z;
						end
			4'b1100 : 	begin 
						if(inv)
							res = x | z;
						else 
							res = x & z;
						end
			4'b1101 : 	begin 
						if(inv)
							res = x | (~z);
						else 
							res = x & (~z);
						end
			4'b1110 : 	begin 
						if(inv)
							res = ~(x | z);
						else 
							res = ~(x & z);
						end
			4'b1111 : 	begin 
						if(inv)
							res = (~x) & z;
						else 
							res = (~x) | z;
						end
			default	:	{cout,res} = 49'b0;
		endcase						
				
	end				
endmodule					