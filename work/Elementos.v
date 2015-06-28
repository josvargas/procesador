/*
Nombre: Multiplexor de 2 entradas
Proposito: Multiplexar registros A y B
Entradas: Registros A y B
Salidas: Los registros o los datos de informacion de la decodificacion
*/
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

//----------------------------------------------------

/*
Nombre: Registro de flip flops
Proposito: Guardar informacion de los registros A y B
Entradas: Linea que viene de la Alu y la memoria de datos
Salidas: Linea almacenada en los registros A o B 
*/
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

//----------------------------------------------------

/*
Nombre: Sumador para contador de PC
Proposito: Aumenta en 1 el valor del registro de PC para la nueva instruccion
Entradas: PC_entrada, almacena el numero actual del contador del programa
Salidas: PC_salida, almacena el valor del proximo valor del contador del programa
*/

module ALU_PC # (parameter SIZE=6)
(
	input wire Clock,
	input wire [SIZE-1:0] PC_entrada,
	input wire Enable,
	output reg [SIZE-1:0] PC_salida
);
	always @(posedge Clock)
	begin
		if (Enable)
			PC_salida = PC_entrada + 1;		
	end

endmodule

//----------------------------------------------------

/*
Nombre: Sumador para contador de PC
Proposito: Aumenta en 1 el valor del registro de PC para la nueva instruccion
Entradas: PC_entrada, almacena el numero actual del contador del programa
Salidas: PC_salida, almacena el valor del proximo valor del contador del programa
*/

module branchDir
(
		input wire [5:0] iSalto,
		input wire [9:0] iPC,
		output reg [9:0] oDirNueva
);

	always @(*)
	begin
		
		if (iSalto[5] == 1) begin
			oDirNueva = iPC - {5'b0,iSalto[4:0]};
		end
		else begin
			oDirNueva = iPC + {5'b0,iSalto[4:0]};
		end
	end
endmodule

/*
Nombre: Demux
Proposito: Demultiplexar la entrada en dos posibles salidas
Entradas: 
Salidas: 
*/

module DEMUX ( 
		input wire [7:0] din,
		input wire sel,
		output reg [7:0] dout1,
		output reg [7:0] dout2 
);

	always @ (din or sel) begin
	 case (sel)
	  0 : dout1 = din;
	  1 : dout2 = din;
	  default : dout1 = din;
	 endcase
	end

endmodule

module Branch_Counter 
(
	input wire Reset,
	input wire wBranchTaken,
	input wire [9:0] wPC_salida,
	output reg oflush
);

	reg [1:0] oflushCounter;

	always @(wPC_salida or Reset or wBranchTaken)
	begin

		if(Reset) begin
			oflushCounter = 0;
			oflush = 0;		
		end

		else begin
			if (wBranchTaken) begin
				oflushCounter = 1;
				oflush = 0;
			end 
			else begin

				if(oflushCounter==2) begin
					oflushCounter = 0;
					oflush = 0;
				end

				else if(oflushCounter==1) begin
					oflushCounter = oflushCounter+1;
					oflush = 1;
				end 

				else begin
					oflushCounter = 0;
					oflush = 0;
				end
			end 
		end 
	end

endmodule

module branchEnabler 
(
	input wire Reset,
	input wire [5:0] wInstruction,
	output reg rEnableBranch
);

	always @(wInstruction or Reset)
	begin

		if(Reset) begin
			rEnableBranch = 0;		
		end

		else begin
			if (wInstruction>6'd24) begin
				rEnableBranch = 1;
			end 
			else begin
				rEnableBranch = 0;			
			end
		end 
	end

endmodule

//Detecta el caso del hazard provocado entre una load y una operacion aritmetica o un store
module hazardDetection
(
	input wire Clock,
	input wire Reset,
	input wire wSelectInputMemData_ALU,
	output reg rHazardClear
);

	reg [3:0] wHazardCounter;

	always @(posedge Clock)
	begin

		if(Reset) begin
			rHazardClear = 0;
			wHazardCounter=0;		
		end

		else begin
			if(wSelectInputMemData_ALU == 1) begin
				rHazardClear = 1;
				wHazardCounter=1;				 	
			end
			else begin
				if((wHazardCounter>0)&&(wHazardCounter<5)) begin
					rHazardClear = 1;
					wHazardCounter=wHazardCounter+1;
				end
				else begin
					rHazardClear = 0;
					wHazardCounter=0;
				end			
			end
		end
	end

endmodule
