module modes(
	
	input						clk,
	input						rst,
	input						CECTRL,
	input						CEALU_MODE,
	input						CEIN_MODE,
	input						IN_MODE_REG,
	input						ALU_MODE_REG,
	input						CARRYINSEL_REG,
	input						OP_MODE_REG,
	input		[6:0]			OP_MODE_i,
	input		[4:0]			IN_MODE_i,
	input		[3:0]			ALU_MODE_i,
	input		[1:0]			CARRYINSEL_i,
	output		[6:0]			OP_MODE,
	output		[4:0]			IN_MODE,
	output		[3:0]			ALU_MODE,
	output		[1:0]			CARRYINSEL
	);

// OP MODE 
logic_ports #(7) opmode(clk,rst,CECTRL,OP_MODE_REG,OP_MODE_i,OP_MODE);

// CARRY IN SELECT
logic_ports #(2) cin_sel(clk,rst,CECTRL,CARRYINSEL_REG,CARRYINSEL_i,CARRYINSEL);

// ALU MODE 
logic_ports #(4) alumode(clk,rst,CEALU_MODE,ALU_MODE_REG,ALU_MODE_i,ALU_MODE);

// IN MODE 
logic_ports #(5) inmode(clk,rst,CEIN_MODE,IN_MODE_REG,IN_MODE_i,IN_MODE);

endmodule


