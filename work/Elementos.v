module MUX # ( parameter SIZE = 2)
(
	output reg [SIZE-1:0] Result,
	input wire [SIZE-1:0] A, B, 
	input wire Sel
);
	always @ (Sel or A or B)
	begin
		case(Sel)
			//-------------------------------------
			1'b0: Result <= A;
			1'b1: Result <= B;
			default: Result <= 0;
		endcase
	end
endmodule
///////////////////////////josuegay
//----------------------------------------------------
module FFD # ( parameter SIZE=8 )
(
	input wire				Clock,
	input wire				Reset,
	input wire				Enable,
	input wire [SIZE-1:0]	D,
	output reg [SIZE-1:0]	Q
);
	

always @ (posedge Clock) 
begin
	if ( Reset )
		Q <= 0;
	else
	begin	
		if (Enable) 
			Q <= D; 
	end	
 
end//always

endmodule


