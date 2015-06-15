	module ALU 
	(
	 input [2:0] iALUControl,	    
	 input [7:0] A,B,
	 input iRegOutputALU,
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
			5: Out <= A<<1;
			6: Out <= A>>1;
			default: Out <= Out;
		endcase	
	
	end

	assign Z_A = (!iRegOutputALU)?(oALUOut==0):1'b0;
	assign C_A = (!iRegOutputALU)?((iALUControl!=6)?Out[8]:Out[0]):1'b0;
	assign N_A = (!iRegOutputALU)?oALUOut[7]:1'b0;
	assign Z_B = (iRegOutputALU)?(oALUOut==0):1'b0;
	assign C_B = (iRegOutputALU)?((iALUControl!=6)?Out[8]:Out[0]):1'b0;
	assign N_B = (iRegOutputALU)?oALUOut[7]:1'b0;

endmodule

