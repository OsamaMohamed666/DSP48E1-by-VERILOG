module DSP_tb();
reg clk_tb,rst_tb,
	CEA1_tb,CEA2_tb,CEAD_tb,CED_tb,CEB1_tb,CEB2_tb,CECTRL_tb,
	CEC_tb,CEM_tb,CEP_tb,CEALU_MODE_tb,CECARRYIN_tb,CEIN_MODE_tb,
	CREG_tb,IN_MODE_REG_tb,ALU_MODE_REG_tb,CARRYINSEL_REG_tb,
	OP_MODE_REG_tb,CARRY_IN_REG_tb,MREG_tb,PREG_tb,B_INPUT_tb,
	USE_MULT_tb,CARRYIN_tb,CARRYCASCIN_tb,USE_DPORT_tb,A_INPUT_tb,
	DREG_tb,ADREG_tb;

reg				[1:0]	AREG_tb,BREG_tb,CARRYINSEL_i_tb;
reg				[3:0]	ALU_MODE_i_tb;
reg				[4:0]	INMODE_i_tb;
reg				[6:0]	OP_MODE_i_tb; 


reg		signed	[17:0]	B_tb,BCIN_tb;		
reg		signed	[24:0]	D_tb;		
reg		signed	[29:0]	A_tb,ACIN_tb;
reg		signed	[47:0]	C_tb,PCIN_tb;



wire					CARRYCASCOUT_tb,CARRYOUT_tb;
wire	signed	[17:0]	BCOUT_tb;
wire	signed	[29:0]	ACOUT_tb;
wire	signed	[47:0]	PCOUT_tb,P_tb;

//*******************MULTIPLICATION OR CONCATENATION*******************
function signed [47:0] mult_conc (  signed[24:0] y,signed [17:0] x , [6:0] op_tmp);
    if(op_tmp[1:0]==2'b01)
      mult_conc =(x*y);
    else if (op_tmp[1:0]==2'b11)
      mult_conc =({y,x});
  endfunction

//*******************SUMMATION AND SUBTRACTION*******************
task sum_sub (  [47:0] a1,  [47:0]c1, [47:0] b1, cin1, [3:0] alu_ctrl, 
		output  [47:0] res, output cout1);
	//SUMMATION
	if (alu_ctrl==4'b0000)
		{cout1,res} = (a1+b1+c1+cin1);
	//SUBTRACTION
    else if (alu_ctrl==4'b0001)
        {cout1,res} = ~(c1)+a1+b1+cin1;
	endtask

//*******************XOR XNOR AND NAND (LOGIC UNIT)*******************
function [47:0] logic_unit (  [47:0] a1 ,[47:0] b1, [3:0] alu_ctrl, [6:0]op_tmp);
	//XOR
	if (alu_ctrl==4'b0100 && op_tmp[3:2]==2'b00 )
		logic_unit = (a1^b1);
	//XNOR
	else if (alu_ctrl==4'b0100 && op_tmp[3:2]==2'b10 )
		logic_unit = (~(a1^b1));
	//AND
	else if (alu_ctrl==4'b1100 && op_tmp[3:2]==2'b00 )
		logic_unit = (a1&b1);
	//NAND
	else if (alu_ctrl==4'b1110 && op_tmp[3:2]==2'b00 )
		logic_unit = (~(a1&b1));
	endfunction
  
//*******************Generator for inputs: A B C D*******************
task generator (  signed[29:0] a,signed [17:0] b, signed [47:0]c,signed [24:0] d);
	begin
    A_tb=a;
    B_tb=b;
    C_tb=c;
	D_tb =d;
	end
  endtask
  
//*******************Checking expected output versus DUT output*******************
  task check(signed [47:0]calc_out,calc_cout, signed [47:0]dut_out, cout_dut);
	begin
    #1;
    if(calc_out == dut_out && calc_cout == cout_dut)
      $display("SUCCESSFULL TEST : The expected outputs is %0d , %0d  and the DUT outputs is %0d , %0d @ %0t ns"
				,calc_out,calc_cout,dut_out,cout_dut,$time);
    else
      $display("FAILED TEST : The expected outputs is %0d , %0d  and the DUT outputs is %0d , %0d @ %0t ns"
				,calc_out,calc_cout,dut_out,cout_dut,$time);
	 end
  endtask
  
  
//TEMP SIGNALS USED TO HELP IN TESTBENCH 
reg	signed	[47:0]	tmp1,tmp2,tmp3,tmp4;
reg 				cout3 , cout4;	 

initial 
begin
clk_tb=0;
rst_tb=1;

//CLOCK ENABLES
CEA1_tb=0;  CEA2_tb=1;	CED_tb=0;	CEAD_tb=0;	CEB2_tb=1; CECTRL_tb=1;
CEC_tb =1;	CEM_tb =1;	CEP_tb=1;	CEALU_MODE_tb=1;	CECARRYIN_tb=1;	CEIN_MODE_tb=1;

//PARAMTER ATTRIBUTES TO USE PIPELINING
CREG_tb=1;	IN_MODE_REG_tb=1;	ALU_MODE_REG_tb=1;	CARRYINSEL_REG_tb=1;
OP_MODE_REG_tb=1;	CARRY_IN_REG_tb=1;	MREG_tb=1;	PREG_tb=1;
AREG_tb=2'b01;	BREG_tb=2'b01;

// TURN OFF D PORT
USE_DPORT_tb=0;	DREG_tb=0; ADREG_tb=0; CEAD_tb=0;

// TURN ON MULTIPLICATION 
USE_MULT_tb=1;

//NO CASCADING
A_INPUT_tb =1; B_INPUT_tb = 1; 

//CARRY IN VALUES
CARRYCASCIN_tb=0;	CARRYIN_tb=0;

//MODES & CARRY IN MUXES
ALU_MODE_i_tb=4'b0;	OP_MODE_i_tb = 7'b0001101; 
CARRYINSEL_i_tb = 2'b00;	INMODE_i_tb=5'b00000;

//VALUES OF INPUT OPERANDS
ACIN_tb=0; BCIN_tb=0; PCIN_tb=0;
generator(30'h7,18'h3,48'h4,25'h6); //for second case
tmp1 = mult_conc(A_tb[24:0],B_tb,OP_MODE_i_tb);
sum_sub (tmp1,C_tb,48'b0,CARRYIN_tb,ALU_MODE_i_tb,tmp3[47:0],cout3);

#7
//*******************Case 1 OF RESET*******************
$display("Case 1 of RESET");
check(48'b0,1'b0,P_tb,CARRYOUT_tb);

rst_tb=0;

#13 
generator(30'h4,18'h4,48'h4,25'h6); // new input values 3rd case

#10
OP_MODE_i_tb = 7'b0100001; //using of pipelining P = P + M
tmp2 = mult_conc(A_tb[24:0],B_tb,OP_MODE_i_tb);
sum_sub (tmp2,tmp3,48'b0,CARRYIN_tb,ALU_MODE_i_tb,tmp4[47:0],cout4);

#5
//*******************Case 2 USING ADDITION*******************
$display("\nCase 2 USING ADDITION");
check(tmp3[47:0],cout3,P_tb,CARRYOUT_tb);

#5
//for fourth case Subtraction
ALU_MODE_i_tb = 4'b0001; 
OP_MODE_i_tb = 7'b0110001;


generator(30'h00ffffff,18'hfffff,48'h4,25'h6);// big values FOR CASE 5
#5 

//*******************Case 3 TRYING PIPELINING*******************
$display("\nCase 3 TRYING PIPELINING");
check(tmp4[47:0],cout4,P_tb,CARRYOUT_tb);

sum_sub(tmp2,C_tb,48'b0,CARRYIN_tb,ALU_MODE_i_tb,tmp3[47:0],cout3); // FOR CASE 4

//FOR CASE 5
ALU_MODE_i_tb = 4'b0000;
C_tb=48'hffff2fffffff;

#10
//*******************Case 4 of Subtraction*******************
$display("\nCase 4 of using SUBTRACTION");
check (tmp3[47:0],cout3 , P_tb,CARRYOUT_tb);

// FOR CASE 5
tmp1 = mult_conc (A_tb[24:0],B_tb,OP_MODE_i_tb);
sum_sub (tmp1,C_tb,48'b0,CARRYIN_tb,ALU_MODE_i_tb,tmp3[47:0],cout3);

#5
// FOR CASE 6 CLOSING MULTIPLICATION TO TEST ITS LOGIC EXPECTING OUTPUT EQUALS C 
USE_MULT_tb = 1'b0;

// FOR CASE 7  TURN ON D PORT
USE_DPORT_tb=1;	DREG_tb=1; CEAD_tb=1; CED_tb=1;
INMODE_i_tb [3:2] = 2'b01; // for A + D (preadd)
generator(30'h6,18'h9,48'h7,25'h4);

#5 
//*******************Case 5 of big numbers and testing C OUT*******************
$display("\nCase 5 USING BIGGER NUMBERS AND TESTING COUT");
check (tmp3[47:0],cout3, P_tb,CARRYOUT_tb);


// FOR CASE 7
tmp1 = A_tb[24:0] + D_tb;
tmp2 = mult_conc (tmp1,B_tb,OP_MODE_i_tb);
sum_sub (tmp2,C_tb,48'b0,CARRYIN_tb,ALU_MODE_i_tb,tmp3[47:0],cout3);
USE_MULT_tb = 1'b1; // Turning on Multiplication

#2
INMODE_i_tb[3] = 1'b1; // FOR CASE 8 PREADDER Subtraction
 
#10
//*******************Case 6 OF CLOSING MULTIPLICATION*******************
$display("\nCase 6 CLOSING MULTIPLICATION PORT EXPECTING OUTPUT EQUALS C");
check (C_tb,1'b0, P_tb,CARRYOUT_tb);

#8
//*******************Case 7 USING PREADDER ADDITION*******************
$display("\nCase 7 of PREADDER ADDITION");
check (tmp3[47:0],cout3, P_tb,CARRYOUT_tb);

// FOR CASE 8
tmp1 = D_tb - A_tb[24:0];
tmp2 = mult_conc (tmp1,B_tb,OP_MODE_i_tb);
sum_sub (tmp2,C_tb,48'b0,CARRYIN_tb,ALU_MODE_i_tb,tmp3[47:0],cout3);

// FOR CASE 9 USING CONCATENATION INSTEAD OF MULTPLICATION
USE_MULT_tb =1'b0;	CEM_tb=0; // TURN OF Multiplication;
USE_DPORT_tb = 0;	CED_tb=0; // TURN OF DPORT
OP_MODE_i_tb = 7'b0101111; // {A,B} + P + C

#10
//*******************Case 8 USING PREADDER SUBTRACTION*******************
$display("\nCase 8 of PREADDER SUBTRACTION");
check (tmp3[47:0],cout3, P_tb,CARRYOUT_tb);

// FOR CASE 9
tmp1 = mult_conc(A_tb,B_tb,OP_MODE_i_tb);
sum_sub(tmp1,C_tb,P_tb,CARRYIN_tb,ALU_MODE_i_tb,tmp3,cout3);

#10
//*******************Case 9 USING CONCATENATION AND ADDITION*******************
$display("\nCase 9 of CONCATENATION AND ADDITION");
check (tmp3[47:0],cout3, P_tb,CARRYOUT_tb);

//*******************Cases TO CHECK CASCADED OUTPUT PORTS*******************
$display("\nCase 10 of P & CARRY OUT CASCADED PORTS");
check (PCOUT_tb,CARRYCASCOUT_tb, P_tb,CARRYOUT_tb);
$display("\nCase 11 of A CASCADED PORT");
check (A_tb,1'b0, ACOUT_tb,1'b0);
$display("\nCase 12 of B CASCADED PORT");
check (B_tb,1'b0, BCOUT_tb,1'b0);



//ENOUGH OF PIPELINING , WE WILL SWITCH TO DIRECT OUTPUT TO CHECK LOGIC UNIT
//CLOCK ENABLES
CEA1_tb=0;  CEA2_tb=0;	CED_tb=0;	CEAD_tb=0;	CEB2_tb=0; CECTRL_tb=0;
CEC_tb =0;	CEM_tb =0;	CEP_tb=0;	CEALU_MODE_tb=0;	CECARRYIN_tb=0;	CEIN_MODE_tb=0;

//PARAMTER ATTRIBUTES TO USE PIPELINING "CLOSING THEM"
CREG_tb=0;	IN_MODE_REG_tb=0;	ALU_MODE_REG_tb=0;	CARRYINSEL_REG_tb=0;
OP_MODE_REG_tb=0;	CARRY_IN_REG_tb=0;	MREG_tb=0;	PREG_tb=0;
AREG_tb=2'b00;	BREG_tb=2'b00;

//*******************CASES OF LOGIC UNIT*******************

#10
//*******************Case 13 (XOR)*******************
OP_MODE_i_tb = 7'b0110011; 
ALU_MODE_i_tb = 4'b0100; 
generator(25'b0,18'hf,48'hff,25'h0); 
tmp1= mult_conc(A_tb,B_tb,OP_MODE_i_tb);
tmp3= logic_unit(tmp1,C_tb,ALU_MODE_i_tb,OP_MODE_i_tb);
#2
$display("\nCase 13 OF XORING {A,B} WITH C");
check (tmp3,1'b0, P_tb,CARRYOUT_tb);

#2
//*******************Case 14 (XNOR)*******************
OP_MODE_i_tb[3:2] = 2'b10; 
tmp1= mult_conc(A_tb,B_tb,OP_MODE_i_tb);
tmp3= logic_unit(tmp1,C_tb,ALU_MODE_i_tb,OP_MODE_i_tb);
#2
$display("\nCase 14 OF XNORING {A,B} WITH C");
check (tmp3,1'b0, P_tb,CARRYOUT_tb);

#2
//*******************Case 15 (AND)*******************
OP_MODE_i_tb[3:2] = 2'b00; 
ALU_MODE_i_tb = 4'b1100;
tmp1= mult_conc(A_tb,B_tb,OP_MODE_i_tb);
tmp3= logic_unit(tmp1,C_tb,ALU_MODE_i_tb,OP_MODE_i_tb);
#2
$display("\nCase 15 OF ANDING {A,B} WITH C");
check (tmp3,1'b0, P_tb,CARRYOUT_tb);

#2
//*******************Case 16 (NAND)******************* 
ALU_MODE_i_tb = 4'b1110;
tmp1= mult_conc(A_tb,B_tb,OP_MODE_i_tb);
tmp3= logic_unit(tmp1,C_tb,ALU_MODE_i_tb,OP_MODE_i_tb);
#2
PREG_tb=1; // to use P as input for muxes to avoid combinational loop
CEP_tb=1;

$display("\nCase 16 OF NANDING {A,B} WITH C");
check (tmp3,1'b0, P_tb,CARRYOUT_tb);

#5
//*******************Case 17 USING P REGISTERED TO BE ANDED WITH C*******************
OP_MODE_i_tb = 7'b0110010; 
ALU_MODE_i_tb = 4'b1100;
tmp3= logic_unit(P_tb,C_tb,ALU_MODE_i_tb,OP_MODE_i_tb);

#10
$display("\nCase 17 USING P REGISTERED TO BE ANDED WITH C");
check (tmp3,1'b0, P_tb,CARRYOUT_tb);


#200
$finish;
end


//CLOCK GENERATOR OF CLOCK PERIOD 10ns
always #5 clk_tb=!clk_tb;


//INSTANTIATION OF THE TOP MODULE DSP
DSP DUT(
.clk(clk_tb),
.rst(rst_tb),
.CEA1(CEA1_tb),
.CEA2(CEA2_tb),
.CED(CED_tb),
.CEAD(CEAD_tb),
.USE_DPORT(USE_DPORT_tb),
.A_INPUT(A_INPUT_tb),
.A(A_tb),
.ACIN(ACIN_tb),
.D(D_tb),
.AREG(AREG_tb),
.DREG(DREG_tb),
.ADREG(ADREG_tb),
.ACOUT(ACOUT_tb),
.CEB1(CEB1_tb),
.CEB2(CEB2_tb),
.B_INPUT(B_INPUT_tb),
.B(B_tb),
.BCIN(BCIN_tb),
.BREG(BREG_tb),
.BCOUT(BCOUT_tb),
.CEC(CEC_tb),
.CREG(CREG_tb),
.C(C_tb),
.CEM(CEM_tb),
.USE_MULT(USE_MULT_tb),
.MREG(MREG_tb),
.CECTRL(CECTRL_tb),
.CEALU_MODE(CEALU_MODE_tb),
.CEIN_MODE(CEIN_MODE_tb),
.IN_MODE_REG(IN_MODE_REG_tb),
.ALU_MODE_REG(ALU_MODE_REG_tb),
.CARRYINSEL_REG(CARRYINSEL_REG_tb),
.OP_MODE_REG(OP_MODE_REG_tb),
.OP_MODE_i(OP_MODE_i_tb),
.INMODE_i(INMODE_i_tb),
.ALU_MODE_i(ALU_MODE_i_tb),
.CARRYINSEL_i(CARRYINSEL_i_tb),
.CECARRYIN(CECARRYIN_tb),
.CARRYCASCIN(CARRYCASCIN_tb),
.CARRY_IN_REG(CARRY_IN_REG_tb),
.CARRYIN(CARRYIN_tb),
.PCIN(PCIN_tb),
.CEP(CEP_tb),
.PREG(PREG_tb),
.P(P_tb),
.PCOUT(PCOUT_tb),
.CARRYOUT(CARRYOUT_tb),
.CARRYCASCOUT(CARRYCASCOUT_tb)
);

endmodule