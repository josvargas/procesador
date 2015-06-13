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
	 output reg [3:0] oALUControl,       //Lineas que seleccionan las operaciones de ALU
	 output reg oBranchTaken,           //Linea que habilita las operaciones de salto (branches) en 1
	 output reg oSelectMuxRegA,          //Linea que habilita el mux para elegir el Registro A o la informacion adicional en la ALU 
	 output reg oSelectMuxesRegB,        //Linea que habilita el mux para elegir el Registro B o la informacion adicional en la ALU
	 output reg oEnableMem,              //Linea que habilita las escrituras en la memoria en 1
	 output reg oMuxWriteMem,            //Selecciona la entrada del registro (A o B) que va a la entrada de Datos de la memoria RAM 
	 output reg oSelectInputMemData      //Linea que habilita el mux para elegir la salida de la ALU (0) o la salida de la RAM de  						     //datos (1) para seleccionar la escritura en los registros 
	);

	wire [5:0] instruction wCodeInstruction;

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
		oALUControl  <= 4'd7;         //Opcion default en la ALU 
		oBranchTaken <= 1'b0;
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
		oALUControl  <= 4'd7;         //Opcion default en la ALU
		oBranchTaken <= 1'b0;
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
		oALUControl  <= 4'd7;         //Opcion default en la ALU
		oBranchTaken <= 1'b0;
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
		oALUControl  <= 4'd7;         //Opcion default en la ALU
		oBranchTaken <= 1'b0;
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
		oALUControl  <= 4'd7;         //Opcion default en la ALU
		oBranchTaken <= 1'b0;
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
		oALUControl  <= 4'd7;         //Opcion default en la ALU
		oBranchTaken <= 1'b0;
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
		oALUControl  <= 4'd0;         //Opcion suma en la ALU
		oBranchTaken <= 1'b0;
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
		oALUControl  <= 4'd0;         //Opcion suma en la ALU
		oBranchTaken <= 1'b0;
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
		oALUControl  <= 4'd0;         //Opcion suma en la ALU
		oBranchTaken <= 1'b0;
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
		oALUControl  <= 4'd0;         //Opcion suma en la ALU
		oBranchTaken <= 1'b0;
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
		oALUControl  <= 4'd1;         //Opcion resta A - B en la ALU
		oBranchTaken <= 1'b0;
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
		oALUControl  <= 4'd2;         //Opcion resta B - A en la ALU
		oBranchTaken <= 1'b0;
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
		oALUControl  <= 4'd1;         //Opcion resta A - B en la ALU
		oBranchTaken <= 1'b0;
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
		oALUControl  <= 4'd2;         //Opcion resta B - A en la ALU  
		oBranchTaken <= 1'b0;
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
		oALUControl  <= 4'd3;         //Opcion resta A & B en la ALU
		oBranchTaken <= 1'b0;
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
		oALUControl  <= 4'd3;         //Opcion resta A & B en la ALU
		oBranchTaken <= 1'b0;
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
		oALUControl  <= 4'd3;         //Opcion resta A & B en la ALU
		oBranchTaken <= 1'b0;
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
		oALUControl  <= 4'd3;         //Opcion resta A & B en la ALU
		oBranchTaken <= 1'b0;
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
		oALUControl  <= 4'd4;         //Opcion resta A | B en la ALU
		oBranchTaken <= 1'b0;
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
		oEnableB_WB  <= 1'b1;         //Se escribe en el Registro A en el ciclo WB         
		oALUControl  <= 4'd4;         //Opcion resta A | B en la ALU
		oBranchTaken <= 1'b0;
		oSelectMuxRegA   <= 1'b0;     
		oSelectMuxRegB   <= 1'b0;
	        oEnableMem   	 <= 1'b0;     
		oMuxWriteMem     <= 1'b0;     
	        oSelectInputMemData <= 1'b0;  //Se selecciona la opcion de escribir el resultado de la ALU
	end
	//-------------------------------------
	default:
	begin
		oEnableA_ID  <= 1'b0;
		oEnableB_ID  <= 1'b0;
		oEnableA_WB  <= 1'b0;
		oEnableB_WB  <= 1'b0;
		oALUControl  <= 4'd7;         //default option number
		oBranchTaken <= 1'b0;
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
