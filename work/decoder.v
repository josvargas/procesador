`timescale 1ns / 1ps
`include "Definitions.v"

/*
Nombre: Decodificador
Proposito: Decodificar las instrucciones que provienen de la memoria ROM
Entradas: Microcodigo de la salida de la memoria de Instrucciones
Salidas: Contenido de los registros y lineas de control
*/

	module decoder 
	(
	 input wire [15:0] iMemoryMicrocode, //Entrada que proviende de la memoria de instrucciones  
	 output wire [9:0] oAditional,       //Informacion adicional que proviene del microcodigo
	 output reg oEnableA_ID,             //Linea que habilita escribir en el registro A en el ciclo ID
   	 output reg oEnableB_ID,             //Linea que habilita escribir en el registro B en el ciclo ID
	 output reg oEnableA_WB,             //Linea que habilita escribir en el registro A en el ciclo WB
	 output reg oEnableB_WB,             //Linea que habilita escribir en el registro B en el ciclo WB
	 output reg [2:0] oALUControl,       //Lineas que seleccionan las operaciones de ALU
	 output reg [3:0] oBranchOperation,  //Linea que habilita y elige las operaciones de salto (branches) 
	 output reg oSelectMuxRegA,          //Linea que habilita el mux para elegir el Registro A o la informacion adicional en la ALU 
	 output reg oSelectMuxRegB,        //Linea que habilita el mux para elegir el Registro B o la informacion adicional en la ALU
	 output reg oEnableMem,              //Linea que habilita las escrituras en la memoria en 1
	 output reg oMuxWriteMem,            //Selecciona la entrada del registro (A o B) que va a la entrada de Datos de la memoria RAM 
	 output reg oSelectInputMemData      //Linea que habilita el mux para elegir la salida de la ALU (0) o la salida de la RAM de//datos (1) para seleccionar la escritura en los registros 
	);

	wire [5:0] wCodeInstruction;

	assign wCodeInstruction = iMemoryMicrocode[15:10];  //Se selecciona el codigo de la instruccion a partir del microcodigo

	assign oAditional = iMemoryMicrocode[9:0];          //Se selecciona la info adicional de la instruccion a partir del microcodigo

always @ ( * )
begin
	case (wCodeInstruction)
	//-------------------------------------
	`LDA:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b1;         //Se selecciona la escritura del registro A en el ciclo WB
		oEnableB_WB  <= 1'b0;
		oALUControl  <= 3'd7;         //Opcion default en la ALU 
		oBranchOperation <= 4'd0;     //Opcion de confirma que la instruccion no es un salto
		oSelectMuxRegA   <= 1'b0;
		oSelectMuxRegB   <= 1'b0;
	    oEnableMem   	 <= 1'b0;
		oMuxWriteMem     <= 1'b0;
	    oSelectInputMemData <= 1'b1;  // con 1 se selecciona la salida de la memoria para escribir en el registro
	end
	//-------------------------------------
	`LDB:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;
		oEnableB_WB  <= 1'b1;         //Se selecciona la escritura del registro B en el ciclo WB
		oALUControl  <= 3'd7;         //Opcion default en la ALU
		oBranchOperation <= 4'd0;
		oSelectMuxRegA   <= 1'b0;
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;
		oMuxWriteMem     <= 1'b0;
	        oSelectInputMemData <= 1'b1;  // con 1 se selecciona la salida de la memoria para escribir en el registro
	end
	//-------------------------------------
	`LDCA:
	begin
		oEnableA_ID  <= 1'b1;         //Se selecciona la escritura del registro A en el ciclo ID con el valor constante
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;         
		oEnableB_WB  <= 1'b0;         
		oALUControl  <= 3'd7;         //Opcion default en la ALU
		oBranchOperation <= 4'd0;
		oSelectMuxRegA   <= 1'b0;
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;
		oMuxWriteMem     <= 1'b0;
	        oSelectInputMemData <= 1'b0;   
	end
	//-------------------------------------
	`LDCB:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b1;         //Se selecciona la escritura del registro B en el ciclo ID con el valor constante
		oEnableA_WB  <= 1'b0;         
		oEnableB_WB  <= 1'b0;         
		oALUControl  <= 3'd7;         //Opcion default en la ALU
		oBranchOperation <= 4'd0;
		oSelectMuxRegA   <= 1'b0;
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;
		oMuxWriteMem     <= 1'b0;
	        oSelectInputMemData <= 1'b0;  
	end
	//-------------------------------------
	`STA:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;         
		oEnableB_WB  <= 1'b0;         
		oALUControl  <= 3'd7;         //Opcion default en la ALU
		oBranchOperation <= 4'd0;
		oSelectMuxRegA   <= 1'b0;
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b1;     //Se selecciona la opcion de escritura en la memoria RAM de datos
		oMuxWriteMem     <= 1'b0;     //Se selecciona el Registro A para escribir en RAM
	        oSelectInputMemData <= 1'b0;  
	end
	//-------------------------------------
	`STB:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;         
		oEnableB_WB  <= 1'b0;         
		oALUControl  <= 3'd7;         //Opcion default en la ALU
		oBranchOperation <= 4'd0;
		oSelectMuxRegA   <= 1'b0;
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b1;     //Se selecciona la opcion de escritura en la memoria RAM de datos 
		oMuxWriteMem     <= 1'b1;     //Se selecciona el Registro B para escribir en RAM
	        oSelectInputMemData <= 1'b1;  
	end
	//-------------------------------------
	`ADDA:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b1;         //Se escribe en el Registro A en WB
		oEnableB_WB  <= 1'b0;         
		oALUControl  <= 3'd0;         //Opcion suma en la ALU
		oBranchOperation <= 4'd0;
		oSelectMuxRegA   <= 1'b0;
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0; //Se selecciona la opcion de escribir el resultado de la ALU
	end
	//-------------------------------------
	`ADDB:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;         
		oEnableB_WB  <= 1'b1;         //Se escribe en el Registro B en WB
		oALUControl  <= 3'd0;         //Opcion suma en la ALU
		oBranchOperation <= 4'd0;
		oSelectMuxRegA   <= 1'b0;
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  //Se selecciona la opcion de escribir el resultado de la ALU
	end
	//-------------------------------------
	`ADDCA:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b1;         //Se escribe en el Registro A en WB
		oEnableB_WB  <= 1'b0;         
		oALUControl  <= 3'd0;         //Opcion suma en la ALU
		oBranchOperation <= 4'd0;
		oSelectMuxRegA   <= 1'b0;
		oSelectMuxRegB   <= 1'b1;     //Se suma la constante en vez del Registro B
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0; //Se selecciona la opcion de escribir el resultado de la ALU
	end
	//-------------------------------------
	`ADDCB:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;         
		oEnableB_WB  <= 1'b1;         //Se escribe en el Registro B en el ciclo WB
		oALUControl  <= 3'd0;         //Opcion suma en la ALU
		oBranchOperation <= 4'd0;
		oSelectMuxRegA   <= 1'b1;    //Se suma la constante en vez del Registro A
		oSelectMuxRegB   <= 1'b0;     
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0; //Se selecciona la opcion de escribir el resultado de la ALU
	end
	//-------------------------------------
	`SUBA:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b1;         //Se escribe en el Registro A en el ciclo WB
		oEnableB_WB  <= 1'b0;         
		oALUControl  <= 3'd1;         //Opcion resta A - B en la ALU
		oBranchOperation <= 4'd0;
		oSelectMuxRegA   <= 1'b0;  
		oSelectMuxRegB   <= 1'b0;     
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0; //Se selecciona la opcion de escribir el resultado de la ALU
	end
	//-------------------------------------
	`SUBB:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;
		oEnableB_WB  <= 1'b1;         //Se escribe en el Registro B en el ciclo WB         
		oALUControl  <= 3'd2;         //Opcion resta B - A en la ALU
		oBranchOperation <= 4'd0;
		oSelectMuxRegA   <= 1'b0;  
		oSelectMuxRegB   <= 1'b0;     
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0; //Se selecciona la opcion de escribir el resultado de la ALU
	end
	//-------------------------------------
	`SUBCA:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b1;         //Se escribe en el Registro A en el ciclo WB 
		oEnableB_WB  <= 1'b0;        
		oALUControl  <= 3'd1;         //Opcion resta A - B en la ALU
		oBranchOperation <= 4'd0;
		oSelectMuxRegA   <= 1'b0;  
		oSelectMuxRegB   <= 1'b1;      //Se resta la constante en vez del Registro B
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0; //Se selecciona la opcion de escribir el resultado de la ALU
	end
	//-------------------------------------
	`SUBCB:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;
		oEnableB_WB  <= 1'b1;         //Se escribe en el Registro B en el ciclo WB         
		oALUControl  <= 3'd2;         //Opcion resta B - A en la ALU  
		oBranchOperation <= 4'd0;
		oSelectMuxRegA   <= 1'b1;     //Se resta la constante en vez del Registro A  
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  //Se selecciona la opcion de escribir el resultado de la ALU
	end
	//-------------------------------------
	`ANDA:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b1;         //Se escribe en el Registro A en el ciclo WB 
		oEnableB_WB  <= 1'b0;        
		oALUControl  <= 3'd3;         //Opcion AND A & B en la ALU
		oBranchOperation <= 4'd0;
		oSelectMuxRegA   <= 1'b0;  
		oSelectMuxRegB   <= 1'b0;     
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  //Se selecciona la opcion de escribir el resultado de la ALU
	end
	//-------------------------------------
	`ANDB:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;
		oEnableB_WB  <= 1'b1;         //Se escribe en el Registro B en el ciclo WB         
		oALUControl  <= 3'd3;         //Opcion AND A & B en la ALU
		oBranchOperation <= 4'd0;
		oSelectMuxRegA   <= 1'b0;  
		oSelectMuxRegB   <= 1'b0;     
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  //Se selecciona la opcion de escribir el resultado de la ALU
	end
	//-------------------------------------
	`ANDCA:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b1;         //Se escribe en el Registro A en el ciclo WB 
		oEnableB_WB  <= 1'b0;        
		oALUControl  <= 3'd3;         //Opcion AND A & B en la ALU
		oBranchOperation <= 4'd0;
		oSelectMuxRegA   <= 1'b0;  
		oSelectMuxRegB   <= 1'b1;     //Se selecciona la constante en vez del registro B
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  //Se selecciona la opcion de escribir el resultado de la ALU
	end
	//-------------------------------------
	`ANDCB:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;
		oEnableB_WB  <= 1'b1;         //Se escribe en el Registro B en el ciclo WB         
		oALUControl  <= 3'd3;         //Opcion AND A & B en la ALU
		oBranchOperation <= 4'd0;
		oSelectMuxRegA   <= 1'b1;     //Se selecciona la constante en vez del registro A
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  //Se selecciona la opcion de escribir el resultado de la ALU
	end
	//-------------------------------------
	`ORA:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b1;         //Se escribe en el Registro A en el ciclo WB 
		oEnableB_WB  <= 1'b0;        
		oALUControl  <= 3'd4;         //Opcion OR A | B en la ALU
		oBranchOperation <= 4'd0;
		oSelectMuxRegA   <= 1'b0;     
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  //Se selecciona la opcion de escribir el resultado de la ALU
	end
	//-------------------------------------
	`ORB:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;
		oEnableB_WB  <= 1'b1;         //Se escribe en el Registro B en el ciclo WB         
		oALUControl  <= 3'd4;         //Opcion OR A | B en la ALU
		oBranchOperation <= 4'd0;
		oSelectMuxRegA   <= 1'b0;     
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  //Se selecciona la opcion de escribir el resultado de la ALU
	end
	//-------------------------------------
	`ORCA:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b1;         //Se escribe en el Registro A en el ciclo WB   
		oEnableB_WB  <= 1'b0;      
		oALUControl  <= 3'd4;         //Opcion OR A | B en la ALU
		oBranchOperation <= 4'd0;
		oSelectMuxRegA   <= 1'b0;     
		oSelectMuxRegB   <= 1'b1;     //Se selecciona la constante en vez del registro B
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  //Se selecciona la opcion de escribir el resultado de la ALU
	end
	//-------------------------------------
	`ORCB:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;  
		oEnableB_WB  <= 1'b1;         //Se escribe en el Registro B en el ciclo WB       
		oALUControl  <= 3'd4;         //Opcion OR A | B en la ALU
		oBranchOperation <= 4'd0;
		oSelectMuxRegA   <= 1'b1;     //Se selecciona la constante en vez del registro A     
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  //Se selecciona la opcion de escribir el resultado de la ALU
	end
	//-------------------------------------
	`ASLA:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b1;         //Se escribe en el Registro A en el ciclo WB  
		oEnableB_WB  <= 1'b0;       
		oALUControl  <= 3'd5;         //Opcion desplazamiento A<<1 en la ALU
		oBranchOperation <= 4'd0;
		oSelectMuxRegA   <= 1'b0;          
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  //Se selecciona la opcion de escribir el resultado de la ALU
	end
	//-------------------------------------
	`ASRA:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b1;         //Se escribe en el Registro A en el ciclo WB  
		oEnableB_WB  <= 1'b0;       
		oALUControl  <= 3'd6;         //Opcion desplazamiento A>>1 en la ALU
		oBranchOperation <= 4'd0;
		oSelectMuxRegA   <= 1'b0;          
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  //Se selecciona la opcion de escribir el resultado de la ALU
	end
	//-------------------------------------
	`JMP:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;         
		oEnableB_WB  <= 1'b0;       
		oALUControl  <= 3'd7;         
		oBranchOperation <= 4'd1;      //Se selecciona la opcion de salto JMP
		oSelectMuxRegA   <= 1'b0;          
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  
	end
	//-------------------------------------
	`BAEQ:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;         
		oEnableB_WB  <= 1'b0;       
		oALUControl  <= 3'd7;         
		oBranchOperation <= 4'd2;      //Se selecciona la opcion de salto Z_A=1
		oSelectMuxRegA   <= 1'b0;          
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  
	end
	//-------------------------------------
	`BANE:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;         
		oEnableB_WB  <= 1'b0;       
		oALUControl  <= 3'd7;         
		oBranchOperation <= 4'd3;      //Se selecciona la opcion de salto Z_A=0 
		oSelectMuxRegA   <= 1'b0;          
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  
	end
	//-------------------------------------
	`BACS:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;         
		oEnableB_WB  <= 1'b0;       
		oALUControl  <= 3'd7;         
		oBranchOperation <= 4'd4;      //Se selecciona la opcion de salto C_A=1
		oSelectMuxRegA   <= 1'b0;          
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  
	end
	//-------------------------------------
	`BACC:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;         
		oEnableB_WB  <= 1'b0;       
		oALUControl  <= 3'd7;         
		oBranchOperation <= 4'd5;      //Se selecciona la opcion de salto C_A=0
		oSelectMuxRegA   <= 1'b0;          
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  
	end
	//-------------------------------------
	`BACC:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;         
		oEnableB_WB  <= 1'b0;       
		oALUControl  <= 3'd7;         
		oBranchOperation <= 4'd5;      //Se selecciona la opcion de salto C_A=0
		oSelectMuxRegA   <= 1'b0;          
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  
	end
	//-------------------------------------
	`BAMI:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;         
		oEnableB_WB  <= 1'b0;       
		oALUControl  <= 3'd7;         
		oBranchOperation <= 4'd6;      //Se selecciona la opcion de salto N_A = 1
		oSelectMuxRegA   <= 1'b0;          
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  
	end
	//-------------------------------------
	`BAPL:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;         
		oEnableB_WB  <= 1'b0;       
		oALUControl  <= 3'd7;         
		oBranchOperation <= 4'd7;      //Se selecciona la opcion de salto N_A = 0
		oSelectMuxRegA   <= 1'b0;          
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  
	end
	//-------------------------------------
	`BBEQ:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;         
		oEnableB_WB  <= 1'b0;       
		oALUControl  <= 3'd7;         
		oBranchOperation <= 4'd8;      //Se selecciona la opcion de salto Z_B=1
		oSelectMuxRegA   <= 1'b0;          
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  
	end
	//-------------------------------------
	`BBNE:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;         
		oEnableB_WB  <= 1'b0;       
		oALUControl  <= 3'd7;         
		oBranchOperation <= 4'd9;      //Se selecciona la opcion de salto Z_B=0
		oSelectMuxRegA   <= 1'b0;          
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  
	end
	//-------------------------------------
	`BBCS:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;         
		oEnableB_WB  <= 1'b0;       
		oALUControl  <= 3'd7;         
		oBranchOperation <= 4'd10;      //Se selecciona la opcion de salto C_B=1
		oSelectMuxRegA   <= 1'b0;          
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  
	end
	//-------------------------------------
	`BBCC:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;         
		oEnableB_WB  <= 1'b0;       
		oALUControl  <= 3'd7;         
		oBranchOperation <= 4'd11;      //Se selecciona la opcion de salto C_B=0
		oSelectMuxRegA   <= 1'b0;          
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  
	end
	//-------------------------------------
	`BBMI:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;         
		oEnableB_WB  <= 1'b0;       
		oALUControl  <= 3'd7;         
		oBranchOperation <= 4'd12;      //Se selecciona la opcion de salto C_A=0
		oSelectMuxRegA   <= 1'b0;          
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  
	end
	//-------------------------------------
	`BBPL:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;         
		oEnableB_WB  <= 1'b0;       
		oALUControl  <= 3'd7;         
		oBranchOperation <= 4'd13;      //Se selecciona la opcion de salto C_A=0
		oSelectMuxRegA   <= 1'b0;          
		oSelectMuxRegB   <= 1'b0;
	    oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	    oSelectInputMemData <= 1'b0;  
	end
	//-------------------------------------
	`NOP:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;         
		oEnableB_WB  <= 1'b0;       
		oALUControl  <= 3'd7;         
		oBranchOperation <= 4'd0;      
		oSelectMuxRegA   <= 1'b0;          
		oSelectMuxRegB   <= 1'b0;
	    oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	    oSelectInputMemData <= 1'b0;  
	end
	//-------------------------------------
	default:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;
		oEnableB_WB  <= 1'b0;
		oALUControl  <= 3'd7;         //default option number
		oBranchOperation <= 4'd0;
		oSelectMuxRegA   <= 1'b0;
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;
		oMuxWriteMem     <= 1'b0;
	        oSelectInputMemData <= 1'b0;
	end	
	//-------------------------------------	
	endcase	
end


endmodule
