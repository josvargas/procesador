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
	wire [9:0] wPC_entrada, wPC_suma, wPC_new, wPC_Branch, wPC_memInstr;
	//assign wPC_new = wPC_mux[9:0];
	//assign wPC_memInstr = wPC_salida[9:0]; // se asigna a la salida del registro de PC para usarse en memoria de Instrucciones

	// Cableado para decodificador
	wire [15:0] wInstruccion;
	wire [9:0] wAditional;
	//wire [2:0] wALUControl;
	wire [3:0] wBranchOperation;
	wire wEnableA_ID, wEnableB_ID, wEnableA_WB, wEnableB_WB, wSelectMuxRegA, wSelectMuxRegB, wEnableMem,wMuxWriteMem; //,wMuxWriteMem;
	
	//Cableado para pasar datos de mux_escritura_ID a mux_escritura_WB

	wire [7:0] wSalida_Demux_A_WB, wSalida_Demux_B_WB;


	// Cableado para Registro A
	wire [7:0] wRegistroA_entrada, wRegistroA_salida;
	// Cableado para Registro B
	wire [7:0] wRegistroB_entrada, wRegistroB_salida;
	
	// Cableado para branchTaken y dirBranch
	wire wBranchTaken;
	//wire [5:0] wSalto;
	
	//Cableado para muxRegistro A y B
	//wire [7:0] wConstant_A, wConstant_B; //wConstant_aux, 
	//wire wSelectMuxRegA, wSelectMuxRegB;
	
	//assign wConstant_aux = wAditional[7:0]; // se asigna para poder usarse para el mux del registro B
	//assign wConstant_A = wAditional[7:0];
	//assign wConstant_B = wAditional[7:0];
	//assign wSalto = wAditional[5:0];
	
	//Cableado de la ALU
	wire [2:0] wALUControl;
	wire [7:0] wMuxA_salida, wMuxB_salida, wSalida_ALU; //wRegistroA_salida_aux, wRegistroB_salida_aux, wSalida_ALU_aux;
	//assign wRegistroA_salida_aux = wRegistroA_salida[7:0];
	//assign wRegistroB_salida_aux = wRegistroB_salida[7:0];
	//wire wSalida_ALU_aux = wSalida_ALU[7:0];
	wire wN_A, wZ_A, wC_A,wN_B, wZ_B, wC_B,wRegOutputALU,wSelectInputMemData;

	wire [7:0] wDatos_Registros;
	//wire [7:0] wSalida_Registros_o_ALU;
	
	
	//Cableado de MEM
	//wire [9:0] wReadAddress, wWriteAddress;
	wire [7:0] wSalida_RAM, wMuxOutWB; //wMuxAB_A, wMuxAB_B;
	//assign wReadAddress = wAditional[9:0];
	//assign wWriteAddress = wAditional[9:0];
	//assign wMuxAB_B = wMuxAB_A[9:0];


	//////////////////////////////////////////////////////////
	// Alambrado de IF (Fetch)
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
		.Q(wPC_new) //se dirige al mux de toma o no el branch
	);
	
	// Alambrado a la Memoria de Instrucciones
	
	memory mem_instrucciones
	(
		.iAddressPC(wPC_salida),
		.oInstruction(wInstruccion)
	);

	//*********************************
	//Bloque intermedio de registros entre IF - ID
	//*********************************

	wire [9:0] wPC_new_ID, wPC_salida_ID;
	wire [15:0] wInstruccion_ID;

	FFD #(10) reg_PC_new_IF  
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wPC_new),  
		.Q(wPC_new_ID) 
	);

	FFD #(10) reg_PC_salida_IF  
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wPC_salida),  
		.Q(wPC_salida_ID) 
	);

	FFD #(16) reg_Instruccion_IF  
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wInstruccion),  
		.Q(wInstruccion_ID) 
	);

	//////////////////////////////////////////////////////////
	// Alambrado de ID
	//////////////////////////////////////////////////////////
	
	// Alambrado de Decodificador
	
	decoder decodificador
	(
		.iMemoryMicrocode(wInstruccion_ID),
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
		.oMuxWriteMem(wMuxWriteMem),   
		.oRegOutputALU(wRegOutputALU),
		.oSelectInputMemData(wSelectInputMemData)  
	);
	
	//Alambrado de Muxes para habilitar escritura de ID
	MUX #(8) mux_escritura_A_ID
	(
		.A(wSalida_Demux_A_WB),
		.B(wAditional[7:0]),
		.Sel(wEnableA_ID),
		.Result(wRegistroA_entrada)
	);
	
	MUX #(8) mux_escritura_B_ID
	(
		.A(wSalida_Demux_B_WB),
		.B(wAditional[7:0]),
		.Sel(wEnableB_ID),
		.Result(wRegistroB_entrada)
	);

	
	// Alambrado para registro A
	
	FFD #(8) registroA
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(wEnableA_ID|wEnableA_WB_WB), 
		.D(wRegistroA_entrada), 
		.Q(wRegistroA_salida)	
	);
	
	// Alambrado para registro B
	
	FFD #(8) registroB
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(wEnableB_ID|wEnableB_WB_WB), 
		.D(wRegistroB_entrada), 
		.Q(wRegistroB_salida)	
	);
	
	// Alambrado para registro de DirBranch
	
	branchDir branchDirection //BranchDir
	(
		.iSalto(wAditional[5:0]),
		.iPC(wPC_salida_ID),
		.oDirNueva(wPC_Branch)
	);

	//***************************************************************************************************
	//Bloque intermedio de registros entre ID - ALU
	//***************************************************************************************************

	wire [7:0] wRegistroA_salida_ALU, wRegistroB_salida_ALU;
	wire [9:0] wAditional_ALU, wPC_new_ALU, wPC_Branch_ALU;
	wire wEnableA_WB_ALU, wEnableB_WB_ALU, wSelectMuxRegA_ALU, wSelectMuxRegB_ALU, wEnableMem_ALU, wMuxWriteMem_ALU;
	wire wRegOutputALU_ALU, wSelectInputMemData_ALU;
	wire [2:0] wALUControl_ALU;
	wire [3:0] wBranchOperation_ALU;

	FFD #(8) reg_RegistroA_salida_ID
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wRegistroA_salida),  
		.Q(wRegistroA_salida_ALU) 
	);

	FFD #(8) reg_RegistroB_salida_ID  
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wRegistroB_salida_ALU),  
		.Q(wRegistroB_salida_ALU) 
	);

	FFD #(10) reg_Aditional_ID  
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wAditional),  
		.Q(wAditional_ALU) 
	);

	FFD #(1) reg_EnableA_WB_ID
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wEnableA_WB),  
		.Q(wEnableA_WB_ALU) 
	);
	
	FFD #(1) reg_EnableB_WB_ID
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wEnableB_WB),  
		.Q(wEnableB_WB_ALU) 
	);

	FFD #(3) reg_ALUControl_ID
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wALUControl),  
		.Q(wALUControl_ALU) 
	);

	FFD #(4) reg_BranchOperation_ID
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wBranchOperation),  
		.Q(wBranchOperation_ALU) 
	);

	FFD #(1) reg_SelectMuxRegA_ID
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wSelectMuxRegA),  
		.Q(wSelectMuxRegA_ALU) 
	);  

	FFD #(1) reg_SelectMuxRegB_ID
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wSelectMuxRegB),  
		.Q(wSelectMuxRegB_ALU) 
	); 

	FFD #(1) reg_EnableMem_ID
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wEnableMem),  
		.Q(wEnableMem_ALU) 
	); 

	FFD #(1) reg_MuxWriteMem_ID
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wMuxWriteMem),  
		.Q(wMuxWriteMem_ALU) 
	); 

	FFD #(1) reg_RegOutputALU_ID
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wRegOutputALU),  
		.Q(wRegOutputALU_ALU) 
	); 

	FFD #(1) reg_SelectInputMemData_ID
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wSelectInputMemData),  
		.Q(wSelectInputMemData_ALU) 
	); 

	FFD #(10) reg_PC_new_ID
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wPC_new_ID),  
		.Q(wPC_new_ALU) 
	); 

	FFD #(10) reg_PC_Branch_ID
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wPC_Branch),  
		.Q(wPC_Branch_ALU) 
	);

	//////////////////////////////////////////////////////////////
	// Alambrado ALU
	//////////////////////////////////////////////////////////////
	
	// Alambrado para registro de branchTaken
	
	branchTaken branchTaken1
	(
		.iBranchOperation(wBranchOperation_ALU),
		.N_A(wN_A),
		.Z_A(wZ_A),
		.C_A(wC_A),
		.N_B(wN_B),
		.Z_B(wZ_B),
		.C_B(wC_B),
		.oBranchTaken(wBranchTaken)
	);

	MUX #(10) mux_PC_ID
	(
		.A(wPC_new_ALU),
		.B(wPC_Branch_ALU),
		.Sel(wBranchTaken),
		.Result(wPC_entrada)
	);

	// Alambrado de mux para registro A
	MUX #(8) muxRegistroA
	(
		.A(wAditional_ALU[7:0]),
		.B(wRegistroA_salida_ALU),
		.Sel(wSelectMuxRegA_ALU),
		.Result(wMuxA_salida)
	);
	
	// Alambrado de mux para registro B
	
	MUX #(8) muxRegistroB
	(
		.A(wAditional_ALU[7:0]),
		.B(wRegistroB_salida_ALU),
		.Sel(wSelectMuxRegB_ALU),
		.Result(wMuxB_salida)
	);
	
	// Alambrado de la ALU
	
	ALU aluu
	(
		.iALUControl(wALUControl_ALU),
		.A(wMuxA_salida),
		.B(wMuxB_salida),
		.iRegOutputALU(wRegOutputALU_ALU),
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
		.A(wRegistroA_salida_ALU),
		.B(wRegistroB_salida_ALU),
		.Sel(wMuxWriteMem_ALU),
		.Result(wDatos_Registros)	
	);
	
	//***************************************************************************************************
	//Bloque intermedio de registros entre ALU - MEM
	//***************************************************************************************************

	wire [7:0] wSalida_ALU_MEM, wDatos_Registros_MEM;
	wire [9:0] wAditional_MEM;
	wire wEnableA_WB_MEM, wEnableB_WB_MEM, wEnableMem_MEM, wRegOutputALU_MEM, wSelectInputMemData_MEM;

	FFD #(8) reg_Salida_ALU_ALU
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wSalida_ALU),  
		.Q(wSalida_ALU_MEM) 
	);

	FFD #(8) reg_Datos_Registros_ALU
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wDatos_Registros),  
		.Q(wDatos_Registros_MEM) 
	);

	FFD #(10) reg_Aditional_ALU  
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wAditional_ALU),  
		.Q(wAditional_MEM) 
	);

	FFD #(1) reg_EnableA_WB_ALU
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wEnableA_WB_ALU),  
		.Q(wEnableA_WB_MEM) 
	);
	
	FFD #(1) reg_EnableB_WB_ALU
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wEnableB_WB_ALU),  
		.Q(wEnableB_WB_MEM) 
	);

	FFD #(1) reg_EnableMem_ALU
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wEnableMem_ALU),  
		.Q(wEnableMem_MEM) 
	); 

	FFD #(1) reg_RegOutputALU_ALU
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wRegOutputALU_ALU),  
		.Q(wRegOutputALU_MEM) 
	); 

	FFD #(1) reg_SelectInputMemData_ALU
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wSelectInputMemData_ALU),  
		.Q(wSelectInputMemData_MEM) 
	); 

	//////////////////////////////////////////////////////////////
	// Alambrado MEM
	//////////////////////////////////////////////////////////////
	
	RAM_DUAL_READ_PORT #(8, 10, 1023) ram
	(
		.Clock(Clock),
		.iWriteEnable(wEnableMem_MEM),
		.iReadAddress(wAditional_MEM[9:0]),
		.iWriteAddress(wAditional_MEM[9:0]),
		.iDataIn(wDatos_Registros_MEM),
		.oDataOut(wSalida_RAM)
	);
	
	//***************************************************************************************************
	//Bloque intermedio de registros entre MEM-WB
	//***************************************************************************************************

	wire [7:0] wSalida_RAM_WB, wSalida_ALU_WB;
	wire wEnableA_WB_WB, wEnableB_WB_WB, wRegOutputALU_WB, wSelectInputMemData_WB;

	FFD #(8) reg_Salida_RAM_MEM
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wSalida_RAM),  
		.Q(wSalida_RAM_WB) 
	);

	FFD #(8) reg_Salida_ALU_MEM
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wSalida_ALU_MEM),  
		.Q(wSalida_ALU_WB) 
	);

	FFD #(1) reg_EnableA_WB_MEM
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wEnableA_WB_MEM),  
		.Q(wEnableA_WB_WB) 
	);
	
	FFD #(1) reg_EnableB_WB_MEM
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wEnableB_WB_MEM),  
		.Q(wEnableB_WB_WB) 
	);

	FFD #(1) reg_RegOutputALU_MEM
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wRegOutputALU_MEM),  
		.Q(wRegOutputALU_WB) 
	); 

	FFD #(1) reg_SelectInputMemData_MEM
	(
		.Clock(Clock),
		.Reset(Reset),
		.Enable(1),
		.D(wSelectInputMemData_MEM),  
		.Q(wSelectInputMemData_WB) 
	); 
	//////////////////////////////////////////////////////////////
	// Alambrado WB
	//////////////////////////////////////////////////////////////
	// Alambrado de mux con salida de ALU y RAM
	
	MUX #(8) mux_ALU_RAM
	(
		.A(wSalida_ALU_WB), 
		.B(wSalida_RAM_WB),
		.Sel(wSelectInputMemData_WB),
		.Result(wMuxOutWB)
	);

	DEMUX #(8) demux_WB
	(
		.din(wMuxOutWB),
		.sel(wRegOutputALU_WB),
		.dout1(wSalida_Demux_A_WB),
		.dout2(wSalida_Demux_B_WB)
	);
	
endmodule
	
	
	
	
	
	




