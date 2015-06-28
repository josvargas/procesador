	module ALU 
	(
	 input wire Clock,
	 input wire Reset,
	 input wire [2:0] iALUControl,	    
	 input wire [7:0] A,B,
	 input wire iRegOutputALU,
	 output wire [7:0] oALUOut,
	 output wire N_A,Z_A,C_A,N_B,Z_B,C_B
	);

	reg [8:0] Out;

	assign oALUOut = (iALUControl!=6)?Out[7:0]:Out[8:1];

	always @(iALUControl,A,B) begin
		case(iALUControl)
			0: Out <= A + B;		
			1: Out <= A - B;
			2: Out <= B - A;
			3: Out <= A & B;
			4: Out <= A | B;
			5: Out <= (A[7]==1)?{1'b1,A<<1}:{1'b0,A<<1};
			6: Out <= (A[0]==1)?{A>>1,1'b1}:{A>>1,1'b0};
			default: Out <= Out;
		endcase	

	end

	wire Z_0, C_0, N_0;

	assign Z_0 = (oALUOut==0);
	assign C_0 = (iALUControl!=6)?(Out[8]==1):(Out[0]==1);
	assign N_0 = (oALUOut[7]==1);

	FFD #(1) reg_Z_A
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable((!iRegOutputALU)&&(iALUControl!=7)),
		.D(Z_0),  
		.Q(Z_A) 
	);

	FFD #(1) reg_C_A
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable((!iRegOutputALU)&&(iALUControl!=7)),
		.D(C_0),  
		.Q(C_A) 
	);

	FFD #(1) reg_N_A
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable((!iRegOutputALU)&&(iALUControl!=7)),
		.D(N_0),  
		.Q(N_A) 
	);

	FFD #(1) reg_Z_B
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable((iRegOutputALU)&&(iALUControl!=7)),
		.D(Z_0),  
		.Q(Z_B) 
	);

	FFD #(1) reg_C_B
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable((iRegOutputALU)&&(iALUControl!=7)),
		.D(C_0),  
		.Q(C_B) 
	);

	FFD #(1) reg_N_B
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable((iRegOutputALU)&&(iALUControl!=7)),
		.D(N_0),  
		.Q(N_B) 
	);

endmodule

