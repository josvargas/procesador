`timescale 1ns / 1ps
`include "Definitions.v"

	module decoder 
	(
	 input wire [15:0] iMemoryMicrocode,	  
	 output wire [9:0] oAditional,
	 output reg oEnableA_ID,
	 output reg oEnableB_ID,
	 output reg oEnableA_WB,
	 output reg oEnableB_WB,
	 output reg [3:0] oALUControl,
	 output reg oAluEnable;		
	 output reg oBranchOperation,
	 output reg oSelectMuxRegA,
	 output reg oSelectMuxesRegB,
	 output reg oEnableMem,
	 output reg oSelectInputMemData
	);

	wire [5:0] instruction wCodeInstruction;

	assign wCodeInstruction = iMemoryMicrocode[15:10];

	assign oAditional = iMemoryMicrocode[9:0];

always @ ( * )
begin
	case (wCodeInstruction)
	//-------------------------------------
	`LDA:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b1;
		oEnableB_WB  <= 1'b0;
		oALUControl  <= 4'd7;  //default option number
		oBranchOperation <= 1'b0;
		oSelectMuxRegA   <= 1'b0;
		oSelectMuxRegA   <= 1'b0;
	        oEnableMem   	 <= 1'b1;
	        oSelectInputMemData <= 1'b1;  // con 1 se selecciona la info adicional y no la salida de la ALU
	end
	//-------------------------------------
	`LDB:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;
		oEnableB_WB  <= 1'b1;
		oALUControl  <= 4'd7;  //default option number
		oBranchOperation <= 1'b0;
		oSelectMuxRegA   <= 1'b0;
		oSelectMuxRegA   <= 1'b0;
	        oEnableMem   	 <= 1'b1;
	        oSelectInputMemData <= 1'b1;
	end
	//-------------------------------------
	default:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;
		oEnableB_WB  <= 1'b0;
		oALUControl  <= 4'd7;  //default option number
		oBranchOperation <= 1'b0;
		oSelectMuxRegA   <= 1'b0;
		oSelectMuxRegA   <= 1'b0;
	        oEnableMem   	 <= 1'b0;
	        oSelectInputMemData <= 1'b0;
	end	
	//-------------------------------------	
	endcase	
end


endmodule
