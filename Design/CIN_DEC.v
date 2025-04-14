module CIN_DEC(
	
	input					clk,				
	input					rst,								
	input					PREG,								
	input					CECARRYIN,
	input					CARRYINREG,
	input					CARRYIN,
	input					CARRYCASCIN,
	input					CARRYCASCOUT,
	input		[1:0]		CARRYINSEL,
	output	reg				CIN
	);
	
wire	CARRYIN_MUX; // output of muxed pipline or direct

logic_ports #(1) cin (clk,rst,CECARRYIN,CARRYINREG,CARRYIN,CARRYIN_MUX);

always @(*)
	begin 
		case(CARRYINSEL)
		2'b00	:	CIN = CARRYIN_MUX;
		2'b01	:	CIN = CARRYCASCIN;
		2'b10	:	begin
						if (PREG) //PIPELINE TO combinational loop
							CIN = CARRYCASCOUT;
						else
							CIN = 0;
					end 
					
		default :	CIN = 0;
		endcase 
	end
endmodule