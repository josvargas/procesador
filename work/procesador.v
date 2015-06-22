/*
Nombre: Procesador
Proposito: Encarga de unir los módulos con pipeline incluido
Entradas: 
Salidas: 
*/

module procesador # (parameter n=8)
(
	input wire Clock, //Entrada que proviene de la señal del reloj
	input wire Reset,
	output wire [9:0] wPC_salida
);

	// Cableado para PC
	wire [9:0] wPC_entrada, /*wPC_salida,*/ wPC_suma, wPC_mux, wPC_new, wPC_mux2, wPC_memInstr;
	assign wPC_new = wPC_mux[9:0];
	assign wPC_memInstr = wPC_salida[9:0]; // se asigna a la salida del registro de PC para usarse en memoria de Instrucciones

	// Cableado para decodificador
	wire [15:0] wInstruccion;
	wire [9:0] wAditional;
	//wire [2:0] wALUControl;
	wire [3:0] wBranchOperation;
	wire wEnableA_ID, wEnableB_ID, wEnableA_WB, wEnableB_WB, wSelectMuxRegA, wSelectMuxRegB, wEnableMem,
	wMuxWriteMem; //, wMuxWriteMem;
	
	// Cableado para Registro A
	wire [7:0] wRegistroA_entrada, wRegistroA_salida;
	// Cableado para Registro B
	wire [7:0] wRegistroB_entrada, wRegistroB_salida;
	
	// Cableado para branchTaken y dirBranch
	wire wBranchTaken;
	wire [5:0] wSalto;
	
	//Cableado para muxRegistro A y B
	wire [7:0] wConstant_aux, wConstant_A, wConstant_B;
	//wire wSelectMuxRegA, wSelectMuxRegB;
	
	assign wConstant_aux = wAditional[7:0]; // se asigna para poder usarse para el mux del registro B
	assign wConstant_A = wAditional[7:0];
	assign wConstant_B = wAditional[7:0];
	assign wSalto = wAditional[5:0];
	
	//Cableado de la ALU
	wire [2:0] wALUControl;
	wire [7:0] wMuxA_salida, wMuxB_salida, wSalida_ALU, wSalida_ALU_aux, wRegistroA_salida_aux, wRegistroB_salida_aux;
	assign wRegistroA_salida_aux = wRegistroA_salida[7:0];
	assign wRegistroB_salida_aux = wRegistroB_salida[7:0];
	//wire wSalida_ALU_aux = wSalida_ALU[7:0];
	wire wN_A, wZ_A, wC_A,wN_B, wZ_B, wC_B,wRegOutputALU;

	wire [7:0] wSelectorRegistros;
	wire [7:0] wSalida_Registros_o_ALU;
	
	
	//Cableado de MEM
	wire [9:0] wReadAddress, wWriteAddress;
	wire [7:0] wSalida_RAM, wMuxAB_A, wMuxAB_B;
	assign wReadAddress = wAditional[9:0];
	assign wWriteAddress = wAditional[9:0];
	assign wMuxAB_B = wMuxAB_A[9:0];


	//////////////////////////////////////////////////////////
	// Alambrado de Fetch
	//////////////////////////////////////////////////////////
	
	// Alambrado de PC (Branches)

	FFD #(10) PC  // Se conecta lo respectivo al registro del contador de PC
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wPC_entrada),
		.Q(wPC_salida)
	);
	
	ALU_PC #(10) aluPC // se conecta la salida del contador PC al sumador para sumarle 1 y obtener la siguiente inst.
	(
		.Clock(Clock),
		.PC_entrada(wPC_salida),
		.Enable(1), // cambiar, poner una señal
		.PC_salida(wPC_suma)
	);
	
	FFD #(10) PC_nuevo  // Se conecta lo respectivo al registro del contador de PC
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wPC_suma),  
		.Q(wPC_mux) //se dirige al mux de toma o no el branch
	);
	
	// Alambrado a la Memoria de Instrucciones
	
	memory mem_instrucciones
	(
		.iAddressPC(wPC_memInstr),
		.oInstruction(wInstruccion)
	);
	
	//////////////////////////////////////////////////////////
	// Alambrado de ID
	//////////////////////////////////////////////////////////
	
	// Alambrado de Decodificador
	
	decoder decodificador
	(
		.iMemoryMicrocode(wInstruccion),
		.oAditional(wAditional),
		.oEnableA_ID(wEnableA_ID),
		.oEnableB_ID(wEnableB_ID),
		.oEnableA_WB(wEnableA_WB),
		.oEnableB_WB(wEnableB_WB),
		.oALUControl(wALUControl),
		.oBranchOperation(wBranchOperation), 
		.oSelectMuxRegA(wSelectMuxRegA),
		.oSelectMuxRegB(wSelectMuxRegB),        
		.oEnableMem(wEnableMem),            
		.oMuxWriteMem(wMuxWriteMem),   // No lo he usado
		.oRegOutputALU(wRegOutputALU),
		.oSelectInputMemData(wSelectInputMemData)  //No lo he usado
	);
	
	//Alambrado de Muxes para habilitar escritura de WB
	MUX #(8) mux_escritura_A_WB
	(
		.A(wConstant_A),
		.B(wMuxAB_A),
		.Sel(wEnableA_WB),
		.Result(wRegistroA_entrada)
	);
	
	MUX #(8) mux_escritura_B_WB
	(
		.A(wConstant_B),
		.B(wMuxAB_B),
		.Sel(wEnableB_WB),
		.Result(wRegistroB_entrada)
	);
	
	// Alambrado para registro A
	
	FFD #(8) registroA
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(wEnableA_ID), // Revisar esto
		.D(wRegistroA_entrada), //esto tambien
		.Q(wRegistroA_salida)	
	);
	
	// Alambrado para registro B
	
	FFD #(8) registroB
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(wEnableB_ID),  // Revisar esto
		.D(wRegistroB_entrada), // esto tambien
		.Q(wRegistroB_salida)	
	);
	
	// Alambrado para registro de branchTaken
	
	branchTaken branchTaken1
	(
		.iBranchOperation(wBranchOperation),
		.N_A(wN_A),
		.Z_A(wZ_A),
		.C_A(wC_A),
		.N_B(wN_B),
		.Z_B(wZ_B),
		.C_B(wC_B),
		.oBranchTaken(wBranchTaken)
	);
	
	// Alambrado para registro de DirBranch
	
	branchDir branchDirection //BranchDir
	(
		.iSalto(wSalto[5:0]),
		.iNewPC(wPC_new),
		.oDirNueva(wPC_mux2)
	);
	
	//////////////////////////////////////////////////////////////
	// Alambrado ALU
	//////////////////////////////////////////////////////////////
	
	// Alambrado de mux para registro A
	MUX #(8) muxRegistroA
	(
		.A(wAditional[7:0]),
		.B(wRegistroA_salida),
		.Sel(wSelectMuxRegA),
		.Result(wMuxA_salida)
	);
	
	// Alambrado de mux para registro B
	
	MUX #(8) muxRegistroB
	(
		.A(wConstant_aux),
		.B(wRegistroB_salida),
		.Sel(wSelectMuxRegB),
		.Result(wMuxB_salida)
	);
	
	// Alambrado de la ALU
	
	ALU aluu
	(
		.iALUControl(wALUControl),
		.A(wMuxA_salida),
		.B(wMuxB_salida),
		.iRegOutputALU(wRegOutputALU),
		.oALUOut(wSalida_ALU),
		.N_A(wN_A),
		.Z_A(wZ_A),
		.C_A(wC_A),
		.N_B(wN_B),
		.Z_B(wZ_B),
		.C_B(wC_B)
	);
	
	MUX #(8) mux_AccesoRAM_sinALU
	(
		.A(wRegistroA_salida_aux),
		.B(wRegistroB_salida_aux),
		.Sel(wMuxWriteMem),
		.Result(wSelectorRegistros)	
	);
	
	MUX #(8) mux_Selector_Registros_o_ALU
	(
		.A(wSelectorRegistros),
		.B(wSalida_ALU),
		.Sel(wALUControl),
		.Result(wSalida_Registros_o_ALU)
	);
	
	//////////////////////////////////////////////////////////////
	// Alambrado MEM
	//////////////////////////////////////////////////////////////
	
	RAM_DUAL_READ_PORT #(8, 10, 10) ram
	(
		.Clock(Clock),
		.iWriteEnable(wEnableMem),
		.iReadAddress(wReadAddress),
		.iWriteAddress(wWriteAddress),
		.iDataIn(wSalida_Registros_o_ALU),
		.oDataOut(wSalida_RAM)
	);
	
	// Alambrado de mux con salida de ALU y RAM
	
	MUX #(2) mux_ALU_RAM
	(
		.A(wSalida_ALU), //borre _aux ?¡?¡?¡???¡?
		.B(wSalida_RAM),
		.Sel(wSelectInputMemData),
		.Result(wMuxAB_A)
	);
	
endmodule
	
	
	
	
	
	




