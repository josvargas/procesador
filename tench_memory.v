`timescale 1ns / 1ps		//escala de tiempo

module probador ();


	reg Clock, Reset, val;
	reg [9:0] iAddressPC;
	wire [15:0] oInstruction;

memory memoria
(
	.iAddressPC(iAddressPC),
	.oInstruction(oInstruction)
	
);	
    
	//Condicion inicial donde se genera la señal de reloj adecuada
	initial
		begin
			$monitor(" Registro A=%b",iAddressPC,"\n Resultado :%b ",oInstruction,$time);  //Muestreo por pantalla
			Clock=0; Reset=1; val=1;
			//posibles pruebas en las entradas en presentacion binaria
			iAddressPC=10'd0;
			#10;
			iAddressPC=10'd1;
			#10;
			Reset=0;
		end
         always
		begin
			repeat(150)		
				begin
					#20 Clock=~Clock;		// se declara un ciclo de reloj cada 40 ps
				end
			$finish;
		end
	      
endmodule
