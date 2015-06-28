`timescale 1ns / 1ps		//escala de tiempo

module probador ();

         reg Clock, Reset;
	 wire [9:0] wPC_salida;      
 

procesador myCPU
(
	 .Clock(Clock),   
	 .Reset(Reset),      
	 .wPC_salida(wPC_salida)	
);	
    
	//Condicion inicial donde se genera la señal de reloj adecuada
	initial
		begin	$dumpfile("CPUSignals.vcd");
			$dumpvars;
			$monitor("PC_salida =%b ",wPC_salida,$time);  //Pantalla
			#10 Clock=0; Reset=1; 
			#10 Reset=0;
		end
         always
		begin
			repeat(160)		
				begin
					#10 Clock=~Clock;		// se declara un ciclo de reloj cada 40 ps
				end
			$finish;
		end
	      
endmodule

