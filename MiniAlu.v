
`timescale 1ns / 1ps
`include "Defintions.v"


module MiniAlu
(
 input wire Clock,
 input wire Reset,
 output wire [7:0] oLed,
 output wire [2:0] oRGB,
 output wire horizontal_sync,
 output wire vertical_sync,
 input wire PS2_CLK,
 input wire PS2_DATA
);

wire [15:0]  wIP,wIP_temp;
reg         rWriteEnable,rBranchTaken;
wire [27:0] wInstruction;
wire [3:0]  wOperation;
reg [31:0]   rResult;
wire [7:0]  wSourceAddr0,wSourceAddr1,wDestination,wDestination_Old,wIPInitialValue;
wire [15:0] wImmediateValue;
wire [31:0] wSourceData0,wSourceData1,wSourceData0_raw,wSourceData1_raw,wResult,wResult_Old;
wire signed [15:0] wsSourceData0,wsSourceData1,wsSourceData0_raw,wsSourceData1_raw,wsResult,wsResult_Old;
wire slow_clock;
reg rVGAWriteEnable;
wire [23:0] wVideoRamAddress;
wire [2:0] wSaveColor;
reg rCallEn, rRetEn;
wire[7:0] wCallAddr, wRetAddr;
wire writeEnable_kb;
wire [2:0] oRGB_kb;
assign wRetAddr = (rRetEn)? wCallAddr : wDestination;

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FF_RET
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable( rCallEn ),
	.D(wIP_temp), //Asi se guarda la dirección de retorno
	.Q( wCallAddr )
);

assign wIPInitialValue = (Reset) ? 8'b0 : wRetAddr;
assign wIP = (rBranchTaken) ? wIPInitialValue : wIP_temp;


FFD_POSEDGE_SYNCRONOUS_RESET # ( 3 ) Color
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable( 1'b1),
	.D( wInstruction[23:21] ),
	.Q( wSaveColor)
);

ROM InstructionRom 
(
	.iAddress(     wIP          ),
	.oInstruction( wInstruction )
);
UPCOUNTER_POSEDGE #(1) S_CLOCK
(
.Clock(   Clock                ), 
.Reset(   Reset                ),
.Initial( 1'b1                    ),
.Enable(  1'b1                 ),
.Q(       slow_clock            )
);
RAM_DUAL_READ_PORT DataRam
(
	.Clock(         Clock        ),
	.iWriteEnable(  rWriteEnable ),
	.iReadAddress0( wInstruction[7:0] ),
	.iReadAddress1( wInstruction[15:8] ),
	.iWriteAddress( wDestination ),
	.iDataIn(       rResult      ),
	.oDataOut0(     wSourceData0 ),
	.oDataOut1(     wSourceData1 )
);
wire oVGA_R,oVGA_G,oVGA_B;
RAM_SINGLE_READ_PORT # (3,16,256*156) VideoMemory
(
.Clock( Clock ),
.iWriteEnable( rVGAWriteEnable | writeEnable_kb),
.iReadAddress( wVideoRamAddress ),
.iWriteAddress( {wSourceData1_raw[7:0],wSourceData0_raw[7:0]} ),
.iDataIn(wSaveColor),
.oDataOut( {oVGA_R,oVGA_G,oVGA_B} )
);

VGA vgacontroller(
.Clock(slow_clock),
.Reset(Reset),
.iRGB({oVGA_R,oVGA_G,oVGA_B}),
.horizontal_sync(horizontal_sync),
.vertical_sync(vertical_sync),
.oRGB(oRGB),
.oReadAddressVGA(wVideoRamAddress)
);

PS2_KB keyboard (
	.Clock(Clock),
	.PS2_CLK(PS2_CLK),
	.PS2_DATA(PS2_DATA),
	.Reset (Reset),
	.iRGB ({oVGA_R,oVGA_G,oVGA_B}),
	.oReadWriteAddressVGA(wVideoRamAddress),
	.oRGB(oRGB_kb),
	.writeEnable_kb(writeEnable_kb)
);

assign wIPInitialValue = (Reset) ? 8'b0 : wRetAddr;
UPCOUNTER_POSEDGE IP
(
.Clock(   Clock                ), 
.Reset(   Reset | rBranchTaken ),
.Initial( wIPInitialValue + 1  ),
.Enable(  1'b1                 ),
.Q(       wIP_temp             )
);
assign wIP = (rBranchTaken) ? wIPInitialValue : wIP_temp;

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFD1 
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wInstruction[27:24]),
	.Q(wOperation)
);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFD2
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wInstruction[7:0]),
	.Q(wSourceAddr0)
);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFD3
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wInstruction[15:8]),
	.Q(wSourceAddr1)
);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFD4
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wInstruction[23:16]),
	.Q(wDestination)
);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFDRAW0
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wDestination),
	.Q(wDestination_Old)
);
assign wResult = rResult;
FFD_POSEDGE_SYNCRONOUS_RESET # ( 32 ) FFDRAW1
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wResult),
	.Q(wResult_Old)
);

reg rFFLedEN;
FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FF_LEDS
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable( rFFLedEN ),
	.D( wSourceData1 ),
	.Q( oLed    )
);

assign wSourceData1_raw = (wDestination_Old == wSourceAddr1) ? wResult_Old : wSourceData1;
assign wSourceData0_raw = (wDestination_Old == wSourceAddr0) ? wResult_Old : wSourceData0;

assign wImmediateValue = {wSourceAddr1,wSourceAddr0};

assign wsSourceData0 = wSourceData0;
assign wsSourceData1 = wSourceData1;
assign wsSourceData0_raw = wSourceData0_raw;
assign wsSourceData1_raw = wSourceData1_raw;
assign wsResult = wsResult;
assign wsResult_Old = wResult_Old;

always @ ( * )
begin
	case (wOperation)
	//-------------------------------------
	`NOP:
	begin
		rVGAWriteEnable <= 1'b0; 
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b0;
		rResult      <= 0;
		rCallEn <= 0;
		rRetEn <= 0;
	end
	//-------------------------------------
	`ADD:
	begin
		rVGAWriteEnable <= 1'b0; 
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b1;
		rResult      <= wSourceData1_raw + wSourceData0_raw;
		rCallEn <= 0;
		rRetEn <= 0;
	end
	//-------------------------------------
	`STO:
	begin
		rVGAWriteEnable <= 1'b0; 
		rFFLedEN     <= 1'b0;
		rWriteEnable <= 1'b1;
		rBranchTaken <= 1'b0;
		rResult      <= wImmediateValue;
		rCallEn <= 0;
		rRetEn <= 0;
	end
	//-------------------------------------
	`BLE:
	begin
		rVGAWriteEnable <= 1'b0; 
		rFFLedEN     <= 1'b0;
		rWriteEnable <= 1'b0;
		rResult      <= 0;
		rCallEn <= 0;
		rRetEn <= 0;
		if (wSourceData1_raw <= wSourceData0_raw )
			rBranchTaken <= 1'b1;
		else
			rBranchTaken <= 1'b0;
		
	end
	//-------------------------------------	
	`JMP:
	begin
		rVGAWriteEnable <= 1'b0; 
		rFFLedEN     <= 1'b0;
		rWriteEnable <= 1'b0;
		rResult      <= 0;
		rBranchTaken <= 1'b1;
		rCallEn <= 0;
		rRetEn <= 0;
	end
	//-------------------------------------	
	`LED:
	begin
		rVGAWriteEnable <= 1'b0; 
		rFFLedEN     <= 1'b1;
		rWriteEnable <= 1'b0;
		rResult      <= 0;
		rBranchTaken <= 1'b0;
		rCallEn <= 0;
		rRetEn <= 0;
	end
	//-------------------------------------
	`SUB:
	begin
		rVGAWriteEnable <= 1'b0; 
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b1;
		rResult      <= wSourceData1_raw - wSourceData0_raw;
		rCallEn <= 0;
		rRetEn <= 0;
	end
	//-------------------------------------
	`MUL:
	begin
		rVGAWriteEnable <= 1'b0; 
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b1;
		rResult      <= wSourceData1_raw * wSourceData0_raw;
		rCallEn <= 0;
		rRetEn <= 0;
	end
	//-------------------------------------
	`VGA:
	begin
	
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b0;
		rVGAWriteEnable <= 1'b1; 
		rResult <= 0;
		rCallEn <= 0;
		rRetEn <= 0;
	end
	//-------------------------------------
	`CALL:
	begin
		rFFLedEN     <= 1'b0;
		rWriteEnable <= 1'b0;
		rResult      <= 0;
		rBranchTaken <= 1'b1;
		rCallEn <= 1'b1;
		rRetEn <= 1'b0;
	end
	//-------------------------------------
	`RTS:
	begin
		rFFLedEN     <= 1'b0;
		rWriteEnable <= 1'b0;
		rResult      <= 0;
		rBranchTaken <= 1'b1;
		rCallEn <= 1'b0;
		rRetEn <= 1'b1;
	end
	//-------------------------------------
	default:
	begin
		rVGAWriteEnable <= 1'b0; 
		rFFLedEN     <= 1'b1;
		rWriteEnable <= 1'b0;
		rResult      <= 0;
		rBranchTaken <= 1'b0;
		rCallEn <= 0;
		rRetEn <= 0;
	end	
	//-------------------------------------	
	endcase	
end


endmodule
