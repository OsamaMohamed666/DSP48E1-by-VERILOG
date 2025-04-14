module DSP (
	
	input						clk,
	input						rst,
//-------------Clock enables-------------
	input						CEA1,
	input						CEA2,
	input						CEB1,
	input						CEB2,
	input						CEC,
	input						CED,
	input						CEM,
	input						CEP,
	input						CEAD,
	input						CEALU_MODE,
	input						CECTRL,
	input						CECARRYIN,
	input						CEIN_MODE,
//-------------Attributes-------------
	input		[1:0]			AREG,
	input		[1:0]			BREG,
	input						CREG,
	input						DREG,
	input						ADREG,
	input						IN_MODE_REG,
	input						ALU_MODE_REG,
	input						CARRYINSEL_REG,
	input						OP_MODE_REG,
	input						CARRY_IN_REG,
	input						MREG,
	input						PREG,
	input						A_INPUT,
	input						B_INPUT,
	input						USE_DPORT,
	input						USE_MULT,
//-------------INPUT PORTS-------------
	input			[6:0]		OP_MODE_i,
	input			[3:0]		ALU_MODE_i,
	input						CARRYIN,
	input						CARRYCASCIN,
	input			[1:0]		CARRYINSEL_i,
	input			[4:0]		INMODE_i,
	input	signed	[29:0]		A,	
	input	signed	[29:0]		ACIN,	
	input	signed	[17:0]		B,	
	input	signed	[17:0]		BCIN,	
	input	signed	[24:0]		D,	
	input	signed	[47:0]		C,	
	input	signed	[47:0]		PCIN,	
//-------------OUTPUT PORTS-------------
	output	signed	[47:0]		P,
	output	signed	[47:0]		PCOUT,	
	output	signed	[29:0]		ACOUT,	
	output	signed	[17:0]		BCOUT,
	output						CARRYOUT,
	output						CARRYCASCOUT
	);

//INSTANTIATION OF DUAL AD AND PREADDER
wire	signed	[29:0]		AMUX;
wire	signed	[24:0]		A_MULT;
wire			[4:0]		IN_MODE;
dualA_D U1(
.clk(clk),
.rst(rst),
.CEA1(CEA1),
.CEA2(CEA2),
.CED(CED),
.CEAD(CEAD),
.USE_DPORT(USE_DPORT),
.A_INPUT(A_INPUT),
.A(A),
.ACIN(ACIN),
.D(D),
.IN_MODE(IN_MODE[3:0]),
.AREG(AREG),
.DREG(DREG),
.AD_reg(ADREG),
.ACOUT(ACOUT),
.AMUX(AMUX),
.A_MULT(A_MULT)
);

//INSTANTIATION OF DUAL B
wire	signed	[17:0]		BMUX;
wire	signed	[17:0]		B_MULT;

dualB U2(
.clk(clk),
.rst(rst),
.CEB1(CEB1),
.CEB2(CEB2),
.B_INPUT(B_INPUT),
.B(B),
.BCIN(BCIN),
.IN_MODE(IN_MODE[4]),
.BREG(BREG),
.BCOUT(BCOUT),
.BMUX(BMUX),
.B_MULT(B_MULT)
);

// INSTANTIATION OF C PORT 
wire	signed	[47:0]	COUT;

CPORT U3(
.clk(clk),
.rst(rst),
.CEC(CEC),
.CREG(CREG),
.C(C),
.COUT(COUT)
);

// INSTANTIATION OF MULTIPLIER 
wire	signed	[47:0]	M;

Mult U4(
.clk(clk),
.rst(rst),
.CEM(CEM),
.USE_MULT(USE_MULT),
.MREG(MREG),
.AMULT(A_MULT),
.BMULT(B_MULT),
.M(M)
);

// INSTANTIATION OF OPMODE, CARRY IN SELECT, ALU MODE, IN MODE. (MODES)
wire	[6:0]	OP_MODE;
wire	[3:0]	ALU_MODE;
wire	[1:0]	CARRYINSEL;

modes U5(
.clk(clk),
.rst(rst),
.CECTRL(CECTRL),
.CEALU_MODE(CEALU_MODE),
.CEIN_MODE(CEIN_MODE),
.IN_MODE_REG(IN_MODE_REG),
.ALU_MODE_REG(ALU_MODE_REG),
.CARRYINSEL_REG(CARRYINSEL_REG),
.OP_MODE_REG(OP_MODE_REG),
.OP_MODE_i(OP_MODE_i),
.IN_MODE_i(INMODE_i),
.ALU_MODE_i(ALU_MODE_i),
.CARRYINSEL_i(CARRYINSEL_i),
.OP_MODE(OP_MODE),
.IN_MODE(IN_MODE),
.ALU_MODE(ALU_MODE),
.CARRYINSEL(CARRYINSEL)
);

//INSTANTIATION OF CARRY IN DECODER 
wire 	CIN;

CIN_DEC U6(
.clk(clk),
.rst(rst),
.PREG(PREG),
.CECARRYIN(CECARRYIN),
.CARRYINREG(CARRY_IN_REG),
.CARRYIN(CARRYIN),
.CARRYCASCIN(CARRYCASCIN),
.CARRYCASCOUT(CARRYCASCOUT),
.CARRYINSEL(CARRYINSEL),
.CIN(CIN)
);

//INSTANTIATION OF X Y Z MULTIPLIXERS 
wire	signed	[47:0]	x,y,z;

XYZ U7(
.OPMODE(OP_MODE),
.PREG(PREG),
.M(M),
.C(COUT),
.AMUX(AMUX),
.BMUX(BMUX),
.PCIN(PCIN),
.P(P),
.x(x),
.y(y),
.z(z)
);

//INSTANTIATION OF ALU & LOGIC UNIT 
wire	signed	[47:0]	res;
wire					cout;

ALU_LOGICUNIT U8(
.alu_ctrl(ALU_MODE),
.OP_MODE(OP_MODE[3:2]),
.CIN(CIN),
.x(x),
.y(y),
.z(z),
.res(res),
.cout(cout)
);

// INSTANTIATION OF OUTPUT PORTS P & P CASCADED & CARRY OUT & CARRY OUT CASCADED
outputs U9(
.clk(clk),
.rst(rst),
.CEP(CEP),
.PREG(PREG),
.cout(cout),
.res(res),
.P(P),
.PCOUT(PCOUT),
.CARRYOUT(CARRYOUT),
.CARRYCASCOUT(CARRYCASCOUT)
);

endmodule






