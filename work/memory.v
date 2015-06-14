`timescale 1ns / 1ps
//===================================================
// Modulo: Memoria de Intrucciones
// Descripción : Memoria ROM contiene las instrucciones a ejecutar
//===================================================



//=============================
/****
Se define el modulo ROM donde 

Entrada: "iAddressPC"
Descripción Entrada: 10 bits para indexar 

Salida:  "oInstruction"
Descripción Salida: Instrucción de 16 bits compuesta por 
 [ Codigo instrucción-->6 bits][ Info adicional --> 10 bits]
15                           10 9                          0  
****/
//==============================================================
module  memory(

	input  wire[9:0]  		iAddressPC, 	//Entrada
	output reg [15:0] 		oInstruction	//Salida

);
	reg [15:0] my_memory [0:1024]; //Crea un registro donde se van a tener las 1024 posiciones de memoria


	initial begin
		$readmemb("intru_rom", my_memory); //Carga la memoria con los datos de memory
	end

	always @ ( iAddressPC )
		oInstruction = my_memory[iAddressPC]; //La salida en bits de la intrucción+adicional
endmodule
