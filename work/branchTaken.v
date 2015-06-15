`timescale 1ns / 1ps
`include "DefinitionsBranches.v"
/*
Nombre: branchTaken
Proposito: Decir si hay o no hay que tomar una instruccion de salto
Entradas: la seleccion del tipo de salto y los registros de estado
Salidas: el bit de branch taken
*/

	module branchTaken
	(
	 input wire [3:0] iBranchOperation,  
	 input wire N_A,Z_A,C_A,N_B,Z_B,C_B, 
	 output reg oBranchTaken,             
	);


always @ ( * )
begin
	case (iBranchOperation)
	//-------------------------------------
	`JMP:
	begin
		oBranchTaken  <= 1'b1;
	end
	//-------------------------------------
	`BAEQ:
	begin
		oBranchTaken  <= Z_A;
	end
	//-------------------------------------
	`BANE:
	begin
		oBranchTaken  <= !Z_A;
	end
	//-------------------------------------
	`BACS:
	begin
		oBranchTaken  <= C_A;
	end
	//-------------------------------------
	`BACC:
	begin
		oBranchTaken  <= !C_A;
	end
	//-------------------------------------
	`BAMI:
	begin
		oBranchTaken  <= N_A;
	end
	//-------------------------------------
	`BAPL:
	begin
		oBranchTaken  <= !N_A;
	end
	//-------------------------------------
	`BBEQ:
	begin
		oBranchTaken  <= Z_B;
	end
	//-------------------------------------
	`BBNE:
	begin
		oBranchTaken  <= !Z_B;
	end
	//-------------------------------------
	`BBCS:
	begin
		oBranchTaken  <= C_B;
	end
	//-------------------------------------
	`BBCC:
	begin
		oBranchTaken  <= !C_B;
	end
	//-------------------------------------
	`BBMI:
	begin
		oBranchTaken  <= N_B;
	end
	//-------------------------------------
	`BBPL:
	begin
		oBranchTaken  <= !N_B;
	end
	//-------------------------------------
	default:
	begin
		oBranchTaken  <= 1'b0;
	end
	endcase	
end



endmodule
