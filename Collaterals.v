`timescale 1ns / 1ps
//------------------------------------------------
module UPCOUNTER_POSEDGE # (parameter SIZE=16)
(
input wire Clock, Reset,
input wire [SIZE-1:0] Initial,
input wire Enable,
output reg [SIZE-1:0] Q
);


  always @(posedge Clock )
  begin
      if (Reset)
        Q = Initial;
      else
		begin
		if (Enable)
			Q = Q + 1;
			
		end			
  end

endmodule



//----------------------------------------------------
module FFD_POSEDGE_SYNCRONOUS_RESET # ( parameter SIZE=8 )
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


//----------------------------------------------------------------------

module ADDER # ( parameter SIZE = 1 ) 
(
	output wire [SIZE-1:0] wResult,
	output wire wCarry,
	input wire [SIZE-1:0] wInput1,
	input wire [SIZE-1:0] wInput2,
	input wire wCarryInput
);

assign {wCarry, wResult[SIZE-1:0]} = wInput1 + wInput2 + wCarryInput;
endmodule

//----------------------------------------------------

module MULTIPLIER4B # ( parameter SIZE = 4)
(
	output wire [2*SIZE - 1:0] wResult,
	input wire [SIZE-1:0] A, B
);

wire R0, R1, R2, R2_2, R3, R3_2, R3_3, R4, R4_2, R4_3, R5_2, R5_3, R6_3;
wire carryR1, carryR2, carryR3, carryR4, carryR2_2, carryR3_2, carryR4_2, carryR5_2, carryR3_3, carryR4_3 , carryR5_3, carryR6_3;



assign R0 = A[0] & B[0];
ADDER Suma1(R1, carryR1, A[1] & B[0],  A[0] & B[1], 1'b0); 
ADDER Suma2(R2, carryR2, A[2] & B[0],  A[1] & B[1], carryR1);
ADDER Suma3(R3, carryR3, A[3] & B[0],  A[2] & B[1], carryR2);
ADDER Suma4(R4, carryR4, A[3] & B[1],  1'b0, carryR3);


ADDER Suma5(R2_2, carryR2_2, A[0] & B[2], R2, 1'b0);
ADDER Suma6(R3_2, carryR3_2, R3, A[1] & B[2], carryR2_2);
ADDER Suma7(R4_2, carryR4_2, R4, A[2] & B[2], carryR3_2);
ADDER Suma8(R5_2, carryR5_2, 1'b0, A[3] & B[2], carryR4_2);


ADDER Suma9(R3_3, carryR3_3, A[0] & B[3],  R3_2, 1'b0);
ADDER Suma10(R4_3, carryR4_3, R4_2,  A[1] & B[3], carryR3_3);
ADDER Suma11(R5_3, carryR5_3, R5_2,  A[2] & B[3], carryR4_3);
ADDER Suma12(R6_3, carryR6_3, carryR5_2,  A[3] & B[3], carryR5_3);

assign wResult = {carryR6_3, R6_3, R5_3, R4_3, R3_3, R2_2, R1, R0};

endmodule

//----------------------------------------------------

module MUX4X1 # ( parameter SIZE = 32)
(
	output reg [SIZE-1:0] Result,
	input wire [SIZE-1:0] A, B, C, D,
	input wire [1:0] Sel
);
	always @ (Sel or A or B or C or D)
	begin
		case(Sel)
			//-------------------------------------
			2'b00: Result <= A;
			2'b01: Result <= B;
			2'b10: Result <= C;
			2'b11: Result <= D;
			default: Result <= 0;
		endcase
	end
endmodule

module MULTIPLIERLUT # ( parameter SIZE = 16)
(
	output wire [2*SIZE - 1:0] wResult,
	input wire [2*SIZE-1:0] A, B
);
	wire [2*SIZE - 1:0] wResultMux0, wResultMux1, wResultMux2, wResultMux3, wResultMux4, wResultMux5, wResultMux6, wResultMux7;
	wire [2*SIZE - 1:0] wResultMux0_shift, wResultMux1_shift, wResultMux2_shift, wResultMux3_shift, wResultMux4_shift, wResultMux5_shift, wResultMux6_shift, wResultMux7_shift;
	//wMult<n><m> = Multiplicacion por m en el mux n
	wire [2*SIZE - 1:0] wMult00, wMult01, wMult02, wMult03;
	wire [2*SIZE - 1:0] wMult10, wMult11, wMult12, wMult13;
	wire [2*SIZE - 1:0] wMult20, wMult21, wMult22, wMult23;
	wire [2*SIZE - 1:0] wMult30, wMult31, wMult32, wMult33;
	wire [2*SIZE - 1:0] wMult40, wMult41, wMult42, wMult43;
	wire [2*SIZE - 1:0] wMult50, wMult51, wMult52, wMult53;
	wire [2*SIZE - 1:0] wMult60, wMult61, wMult62, wMult63;
	wire [2*SIZE - 1:0] wMult70, wMult71, wMult72, wMult73;
	//MUX0
	assign wMult00 = 0;
	assign wMult01 = A;
	assign wMult02 = A << 1;
	assign wMult03 = wMult02 + wMult01; 
	MUX4X1 MUX0(wResultMux0, wMult00, wMult01, wMult02, wMult03, B[1:0]);
	assign wResultMux0_shift = wResultMux0 << 0;
	//MUX1
	assign wMult10 = 0;
	assign wMult11 = A;
	assign wMult12 = A << 1;
	assign wMult13 = wMult12 + wMult11;
	MUX4X1 MUX1(wResultMux1, wMult10, wMult11, wMult12, wMult13, B[3:2]);
	assign wResultMux1_shift = wResultMux1 << 2;
	//MUX2
	assign wMult20 = 0;
	assign wMult21 = A;
	assign wMult22 = A << 1;
	assign wMult23 = wMult22 + wMult21;
	MUX4X1 MUX2(wResultMux2, wMult20, wMult21, wMult22, wMult23, B[5:4]);
	assign wResultMux2_shift = wResultMux2 << 4;
	//MUX3
	assign wMult30 = 0;
	assign wMult31 = A;
	assign wMult32 = A << 1;
	assign wMult33 = wMult32 + wMult31;
	MUX4X1 MUX3(wResultMux3, wMult30, wMult31, wMult32, wMult33, B[7:6]);
	assign wResultMux3_shift = wResultMux3 << 6;
	//MUX4
	assign wMult40 = 0;
	assign wMult41 = A;
	assign wMult42 = A << 1;
	assign wMult43 = wMult42 + wMult41;
	MUX4X1 MUX4(wResultMux4, wMult40, wMult41, wMult42, wMult43, B[9:8]);
	assign wResultMux4_shift = wResultMux4 << 8;
	//MUX5
	assign wMult50 = 0;
	assign wMult51 = A;
	assign wMult52 = A << 1;
	assign wMult53 = wMult52 + wMult51;
	MUX4X1 MUX5(wResultMux5, wMult50, wMult51, wMult52, wMult53, B[11:10]);
	assign wResultMux5_shift = wResultMux5 << 10;
	//MUX6
	assign wMult60 = 0;
	assign wMult61 = A;
	assign wMult62 = A << 1;
	assign wMult63 = wMult62 + wMult61;
	MUX4X1 MUX6(wResultMux6, wMult60, wMult61, wMult62, wMult63, B[13:12]);
	assign wResultMux6_shift = wResultMux6 << 12;
	//MUX7
	assign wMult70 = 0;
	assign wMult71 = A;
	assign wMult72 = A << 1;
	assign wMult73 = wMult72 + wMult71;
	MUX4X1 MUX7(wResultMux7, wMult70, wMult71, wMult72, wMult73, B[15:14]);
	assign wResultMux7_shift = wResultMux7 << 14;
	//Total
	assign wResult = wResultMux0_shift + wResultMux1_shift + wResultMux2_shift + wResultMux3_shift + wResultMux4_shift + wResultMux5_shift + wResultMux6_shift + wResultMux7_shift;

endmodule
