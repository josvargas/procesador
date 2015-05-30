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
///////////////////////////josuegay
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


