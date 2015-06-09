	module ALU 
	(
	 input [2:0] iALUControl,	    
	 input [7:0] A,B,
	 output wire [7:0] oALUOut,
	 output wire N,Z,C
	);

	reg [8:0] Out;

	assign oALUOut = Out[7:0];

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

	assign Z = (oALUOut==0);
	assign C = Out[8];
	assign N = oALUOut[7];

endmodule

