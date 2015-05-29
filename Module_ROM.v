`timescale 1ns / 1ps
`include "Defintions.v"

`define LOOP1 8'd12
`define LOOP2 8'd8
`define WHITE 8'd29
`define WHITE1 8'd33
`define WHITE2 8'd37
`define WHITE3 8'd41
`define WHITE4 8'd45
`define WHITE5 8'd49
`define WHITE6 8'd53
`define WHITE7 8'd57
`define BLACK 8'd80
`define BLACK1 8'd82
`define BLACK2 8'd86
`define BLACK3 8'd90
`define BLACK4 8'd94
`define BLACK5 8'd98
`define BLACK6 8'd102
`define BLACK7 8'd106

module ROM
(
	input  wire[15:0]  		iAddress,
	output reg [27:0] 		oInstruction
);	
always @ ( iAddress )
begin
	case (iAddress)

	0: oInstruction = { `NOP ,24'd4000      };   //NOP
	1: oInstruction = { `NOP ,24'd4000      };   //NOP
	2: oInstruction = { `NOP ,24'd4000      };   //NOP
	3: oInstruction = { `NOP ,24'd4000      };   //NOP
	4: oInstruction = { `STO ,`R1,16'd0     };
	5: oInstruction = { `STO ,`R2,16'd0     }; //Numero de columnas
	6: oInstruction = { `STO ,`R3,16'd1		}; 
	7: oInstruction = { `STO ,`R4,16'h0024	}; 
	8: oInstruction = { `STO ,`R5,16'h0016	}; 
	9: oInstruction = { `STO ,`R6,16'h01	};
	10: oInstruction = { `STO ,`R7,16'h08	}; 
	11: oInstruction = { `STO ,`R8,16'h01	};

//LOOP1

	12: oInstruction = { `CALL ,`WHITE ,`R1,`R3   };   //NOP
	13: oInstruction = { `STO ,`R5,16'h002C	}; 	
	14: oInstruction = { `CALL ,`BLACK ,`R1,`R3   };   //NOP
	15: oInstruction = { `STO ,`R5,16'h0042	}; 
	16: oInstruction = { `CALL ,`WHITE ,`R1,`R3   };   //NOP
	17: oInstruction = { `STO ,`R5,16'h0058	}; 	
	18: oInstruction = { `CALL ,`BLACK ,`R1,`R3   };   //NOP
	19: oInstruction = { `STO ,`R5,16'h006E	};
	20: oInstruction = { `CALL ,`WHITE ,`R1,`R3   };   //NOP
	21: oInstruction = { `STO ,`R5,16'h0084	}; 	
	22: oInstruction = { `CALL ,`BLACK ,`R1,`R3   };   //NOP
	23: oInstruction = { `STO ,`R5,16'h009A	};
	24: oInstruction = { `CALL ,`WHITE ,`R1,`R3   };   //NOP


	25: oInstruction = { `NOP ,24'd4000    };   //NOP
	26: oInstruction = { `NOP ,24'd4000    };   //NOP
	27: oInstruction = { `JMP , 8'd25, 16'd0000    };
	default:
		oInstruction = { `LED ,  24'b10101010 };		//NOP


		
//WHITE	
	31: oInstruction = { `STO ,`R1,16'd0     };
	32: oInstruction = { `STO ,`R4,16'h0024};

//WHITE1
	33: oInstruction = { `VGA, `COLOR_WHITE, 5'd0, `R2, `R1  };
	34: oInstruction = { `ADD, `R1, `R1, `R3 };
	35: oInstruction = { `BLE ,`WHITE1,`R1,`R4 };
	36: oInstruction = { `STO ,`R4,16'h0048};

//WHITE2
	37: oInstruction = { `VGA, `COLOR_BLACK, 5'd0, `R2, `R1  };
	38: oInstruction = { `ADD, `R1, `R1, `R3 };
	39: oInstruction = { `BLE ,`WHITE2,`R1,`R4 };
	40: oInstruction = { `STO ,`R4,16'h006C };

//WHITE3
	41: oInstruction = { `VGA, `COLOR_WHITE, 5'd0, `R2, `R1  };
	42: oInstruction = { `ADD, `R1, `R1, `R3 };
	43: oInstruction = { `BLE ,`WHITE3,`R1,`R4 };
	44: oInstruction = { `STO ,`R4,16'h0090 };

//WHITE4
	45: oInstruction = { `VGA, `COLOR_BLACK, 5'd0, `R2, `R1  };
	46: oInstruction = { `ADD, `R1, `R1, `R3 };
	47: oInstruction = { `BLE ,`WHITE4,`R1,`R4 };
	48: oInstruction = { `STO ,`R4,16'h00B4 };

//WHITE5
	49: oInstruction = { `VGA, `COLOR_WHITE, 5'd0, `R2, `R1  };
	50: oInstruction = { `ADD, `R1, `R1, `R3 };
	51: oInstruction = { `BLE ,`WHITE5,`R1,`R4 };
	52: oInstruction = { `STO ,`R4,16'h00D8 };

//WHITE6
	53: oInstruction = { `VGA, `COLOR_BLACK, 5'd0, `R2, `R1  };
	54: oInstruction = { `ADD, `R1, `R1, `R3 };
	55: oInstruction = { `BLE ,`WHITE6,`R1,`R4 };
	56: oInstruction = { `STO ,`R4,16'h00FC };

//WHITE7
	57: oInstruction = { `VGA, `COLOR_WHITE, 5'd0, `R2, `R1  };
	58: oInstruction = { `ADD, `R1, `R1, `R3 };
	59: oInstruction = { `BLE ,`WHITE7,`R1,`R4 };

//linea 
	60: oInstruction = { `ADD, `R2, `R2, `R3 };
	61: oInstruction = { `BLE ,`WHITE,`R2,`R5 };
	62: oInstruction = { `RTS ,24'd0   };



//BLACK	
	80: oInstruction = { `STO ,`R1,16'd0     };
	81: oInstruction = { `STO ,`R4,16'h0024};

//BLACK1
	82: oInstruction = { `VGA, `COLOR_BLACK, 5'd0, `R2, `R1  };
	83: oInstruction = { `ADD, `R1, `R1, `R3 };
	84: oInstruction = { `BLE ,`BLACK1,`R1,`R4 };
	85: oInstruction = { `STO ,`R4,16'h0048};

//BLACK2
	86: oInstruction = { `VGA, `COLOR_WHITE, 5'd0, `R2, `R1  };
	87: oInstruction = { `ADD, `R1, `R1, `R3 };
	88: oInstruction = { `BLE ,`BLACK2,`R1,`R4 };
	89: oInstruction = { `STO ,`R4,16'h006C };

//BLACK3
	90: oInstruction = { `VGA, `COLOR_BLACK, 5'd0, `R2, `R1  };
	91: oInstruction = { `ADD, `R1, `R1, `R3 };
	92: oInstruction = { `BLE ,`BLACK3,`R1,`R4 };
	93: oInstruction = { `STO ,`R4,16'h0090 };

//BLACK4
	94: oInstruction = { `VGA, `COLOR_WHITE, 5'd0, `R2, `R1  };
	95: oInstruction = { `ADD, `R1, `R1, `R3 };
	96: oInstruction = { `BLE ,`BLACK4,`R1,`R4 };
	97: oInstruction = { `STO ,`R4,16'h00B4 };

//BLACK5
	98: oInstruction = { `VGA, `COLOR_BLACK, 5'd0, `R2, `R1  };
	99: oInstruction = { `ADD, `R1, `R1, `R3 };
	100: oInstruction = { `BLE ,`BLACK5,`R1,`R4 };
	101: oInstruction = { `STO ,`R4,16'h00D8 };

//BLACK6
	102: oInstruction = { `VGA, `COLOR_WHITE, 5'd0, `R2, `R1  };
	103: oInstruction = { `ADD, `R1, `R1, `R3 };
	104: oInstruction = { `BLE ,`BLACK6,`R1,`R4 };
	105: oInstruction = { `STO ,`R4,16'h00FC };

//BLACK7
	106: oInstruction = { `VGA, `COLOR_BLACK, 5'd0, `R2, `R1  };
	107: oInstruction = { `ADD, `R1, `R1, `R3 };
	108: oInstruction = { `BLE ,`BLACK7,`R1,`R4 };

//linea 
	109: oInstruction = { `ADD, `R2, `R2, `R3 };
	110: oInstruction = { `BLE ,`BLACK,`R2,`R5 };
	111: oInstruction = { `RTS ,24'd0   };


	endcase	
end
	
endmodule
