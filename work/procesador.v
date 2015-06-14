/*
Nombre: Procesador
Proposito: Encarga de unir los módulos con pipeline incluido
Entradas: 
Salidas: 
*/

module procesador # (parameter n=8)
(
	input wire Clock, //Entrada que proviene de la señal del reloj
	
);

	// Cableado para PC
	wire [9:0] wPC_entrada, wPC_salida, wPC_suma, wPC_mux, wPC_memInstr;
	
	assign wPC_memInstr = wPC_salida[9:0]; // se asigna a la salida del registro de PC para usarse en memoria de Instrucciones

	// Cableado para decodificador
	wire [15:0] wInstruccion;
	wire [9:0] wAditional;
	wire [2:0] wALUControl;
	wire [3:0] wBranchOperation;
	wire wEnableA_ID, wEnableB_ID, wEnableA_WB, wEnableB_WB, wSelectMuxRegA, wSelectMuxRegB, wEnableMem,
	wMuxWriteMem, wMuxWriteMem;
	
	// Cableado para Registro A
	wire [7:0] wRegistroA_entrada, wRegistroA_salida;
	// Cableado para Registro B
	wire [7:0] wRegistroB_entrada, wRegistroB_salida;
	
	// Cableado para branchTaken y dirBranch
	wire wBranchTaken, wBranchTaken_salida;
	wire [9:0] wBranchOperation, wBranchOperation_salida;
	
	//Cableado para muxRegistro A y B
	wire [7:0] wMuxA_salida, wMuxB_salida, wConstant_aux;
	wire wSelectMuxRegA, wSelectMuxRegB;
	
	assign wConstant_aux = wAditional[7:0]; // se asigna para poder usarse para el mux del registro B
	assign wRegistroA_entrada = wRegistrosAB [7:0];
	assign wRegistroB_entrada = wRegistrosAB [7:0];  // Ojo aca que los registros tienen que ser diferentes
	
	//Cableado de la ALU
	wire [2:0] wALUControl;
	wire [7:0] wMuxA_salida, wMuxB_salida, wSalida_ALU;
	wire wN, wZ, wC;
	
	//Cableado de MEM
	wire [9:0] wReadAddress, wWriteAddress;
	assign wReadAddress = wAditional [9:0];
	assign wWriteAddress = wAditional [9:0];

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
		.iAddressPC(wPC_memInstr);
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
		.oSelectInputMemData(wSelectInputMemData)  //No lo he usado
	);
	
	// Alambrado para registro A
	
	FFD #(8) registroA
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(wEnableA_WB), // Revisar esto
		.D(wRegistroB_entrada), //esto tambien
		.Q(wRegistroA_salida)	
	);
	
	// Alambrado para registro B
	
	FFD #(8) registroB
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(wEnableB_WB),  // Revisar esto
		.D(wRegistroB_entrada), // esto tambien
		.Q(wRegistroB_salida)	
	);
	
	// Alambrado para registro de branchTaken
	
	FFD #(1) branchTaken
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wBranchTaken), // esto tambien
		.Q(wBranchTaken_salida)	// esto tambien
	);
	
	// Alambrado para registro de DirBranch
	
	FFD #(10) dirBranch
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wBranchOperation), // Cambiar esto por el calculo de la direccion del branch
		.Q(wBranchOperation_salida)	
	);
	
	//////////////////////////////////////////////////////////////
	// Alambrado ALU
	//////////////////////////////////////////////////////////////
	
	// Alambrado de mux para registro A
	
	mux #(8) muxRegistroA
	(
		.A(wAditional[7:0]),
		.B(wRegistroA_salida),
		.Sel(wSelectMuxRegA),
		.Result(wMuxA_salida)
	);
	
	// Alambrado de mux para registro B
	
	mux #(8) muxRegistroB
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
		.oALUOut(wSalida_ALU),
		.N(wN),
		.Z(wZ),
		.C(wC)
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
		.iDataIn(wSalida_ALU),
		.oDataOut(wRegistrosAB)
	);
	
endmodule
	
	
	
	
	
	




