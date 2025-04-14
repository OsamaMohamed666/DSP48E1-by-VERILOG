module dualA_D(
	input						clk,
	input						rst,
	input						CEA1,
	input						CEA2,
	input						CED,
	input						CEAD,
	input						USE_DPORT, // control signal of D 
	input						A_INPUT, //chooses between cascade or direct input
	input	signed	[29:0]		A,
	input	signed	[29:0]		ACIN, 
	input	signed	[24:0]		D,
	input			[3:0]		IN_MODE,
	input			[1:0]		AREG, //control signal
	input						DREG, //control signal
	input						AD_reg, //control signal
	output	signed	[29:0]		ACOUT, //CASCADING OUTPUT
	output	signed	[29:0]		AMUX, // OUTPUT FOR CONCATENATION WITH B.(UPPER BITS)
	output	signed	[24:0]		A_MULT // OUTPUT FOR MULTPLICATION PROCESS
	);
// *****************all internal signals of AD DUAL register**************
reg		signed	[29:0]	A1,A2; //REGISTERS A1 and A2
reg		signed	[24:0]	D1,AD; //REGISTER D AND AD
reg		signed	[24:0]	d_mux,d_preadd,out_preadd,AD_mux; // Signals for D
wire	signed	[29:0]	tmp1,tmp2;
wire	signed	[29:0]	a_sel; //selected A
wire	signed	[24:0]	a_mux,a_preadd; // Signals for A

// *****************internal signals of A assignment**************
assign	a_sel = A_INPUT? A : ACIN; 
assign	tmp1 = AREG[1]? A1 : a_sel;  //AREG = 2, A1 register is used
assign	tmp2 = AREG[0]? A2 : tmp1; // AREG = 1 , A2 regisert is used

// *****************AD DUAL REGISTERS**************
//A1 
always @(posedge clk)
	begin 
		if(rst)
			A1 <= 0;  
		else if (CEA1) 
			A1 <= a_sel;
	end 	
//A2 
always @(posedge clk)
	begin 
		if(rst)
			A2 <= 0;  
		else if (CEA2)
			A2 <= tmp1;
	end 	
//D1
always @(posedge clk)
	begin 
		if(rst)
			D1 <= 0;  
		else if (CED)
			D1 <= D;
	end 	
//AD
always @(posedge clk)
	begin 
		if(rst)
			AD <= 0;  
		else if (CEAD)
			AD <= out_preadd;
	end 	
//*************************AD PREADDER*************************	
assign	a_mux 	= IN_MODE[0]? A1[24:0] : tmp2[24:0]; // least 25 bit
assign	a_preadd = IN_MODE[1]? 25'b0 : a_mux  ;

//USING DPORT OR NOT
always @(*)
	begin
		if (!USE_DPORT)
			begin 
				d_mux=0;
				d_preadd=0;
				out_preadd=0;
				AD_mux=0;
			end
		else 
			begin 
				d_mux = DREG? D1 : D;
				d_preadd = IN_MODE[2]? d_mux : 25'b0;
				out_preadd = IN_MODE[3]? d_preadd - a_preadd : d_preadd + a_preadd;
				AD_mux = AD_reg? AD : out_preadd;
			end
	end
//*************************OUTPUTS*************************	
assign 	AMUX 	= tmp2;
assign 	ACOUT 	= AREG[1]? A1 : tmp2;
assign 	A_MULT 	= USE_DPORT? AD_mux : a_preadd; 
endmodule	

