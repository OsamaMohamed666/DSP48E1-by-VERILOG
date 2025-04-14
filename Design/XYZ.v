module XYZ (

	input				[6:0]		OPMODE,
	input							PREG,
	input		signed 	[47:0]		M,
	input		signed 	[47:0]		C,
	input		signed 	[29:0]		AMUX,
	input		signed 	[17:0]		BMUX,
	input		signed 	[47:0]		PCIN,
	input		signed 	[47:0]		P,
	output	reg	signed 	[47:0]		x,
	output	reg	signed 	[47:0]		y,
	output	reg	signed 	[47:0]		z
	);

wire	[1:0]	x_sel,y_sel;
wire	[2:0]	z_sel;

assign x_sel = OPMODE[1:0];
assign y_sel = OPMODE[3:2];
assign z_sel = OPMODE[6:4];

always @(*)
	begin 
	//-------- X MUX --------
		case (x_sel)
		2'b00	:	x = 0;
		2'b01	:	x = M;
		2'b10	:	begin
						if(PREG) //REGISTERED TO AVOID combinational loop
							x = P;
						else
							x = 0;
					end 
					
		2'b11	:	x = {AMUX,BMUX};
		default	:	x = 0;
		endcase 	
	//-------- Y MUX --------
		case (y_sel)
		2'b00	:	y = 0;
		2'b10	:	y = 48'hffffffffffff;
		2'b11	:	y = C;
		default	:	y = 0;
		endcase
	//-------- Z MUX --------
		case (z_sel)
		3'b000	:	z = 0;
		3'b001	:	z = PCIN;
		3'b010	:	begin
						if(PREG)
							z = P;
						else
							z = 0;
					end 
					
		3'b011	:	z = C;
		3'b101	:	begin
						if(PREG) //REGISTERED TOop combinational loop
							z = P >> 17;  // for wider multiplication
						else
							z = 0;
					end 
		
		3'b110	:	z = PCIN >> 17; 
		default :	z = 0;
		endcase
	end

endmodule

