//////////////////////////////////////////////////////////////////////////////////
// Author:			Brandon Franzke, Gandhi Puvvada, Bilal Zafar
// Create Date:   	02/13/2008, 
// Revised: Gandhi 2/6/2012 replaced `define with localparam
// File Name:		ee354_detour_sm.v 
// Description: 
//
//
// Revision: 		1.1
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module ee354_numlock_sm(clk, reset, U, Z,
						q_I, q_Opening, q_G1011, q_G1011get, q_G101, q_G101get, 
						q_G10, q_G10get, q_G1, q_G1get, q_Bad, Unlock);
	/*  INPUTS */
	// Clock & Reset
	input clk,reset,U,Z;
	
	/*  OUTPUTS */
	// store current state
	output q_I, q_Opening, q_G1011, q_G1011get, q_G101, q_G101get, q_G10, q_G10get, q_G1, q_G1get, q_Bad, Unlock;
	reg [10:0] state;
	
	assign {q_Bad, q_Opening, q_G1011, q_G1011get, q_G101, q_G101get, q_G10, q_G10get, q_G1, q_G1get, q_I} = state;
	// lets make accessing the state information easier within the state machine code
	// each line aliases the appropriate state bits and sets up a 1-hot code
	localparam 
		QI			=11'b00000000001,
		QG1GET		=11'b00000000010,
		QG1			=11'b00000000100,
		QG10get		=11'b00000001000,
		QG10		=11'b00000010000,
		QG101get	=11'b00000100000,
		QG101		=11'b00001000000,
		QG1011get	=11'b00010000000,
		QG1011		=11'b00100000000,
		QOpening	=11'b01000000000,
		QBad		=11'b10000000000,
		UNK			=11'bXXXXXXXXXXX;
	
	assign Unlock=q_Opening;

	reg [3:0] Timerout_count;
	wire Timerout;
	assign Timerout = (Timerout_count[3]) & (Timerout_count[2]) & (Timerout_count[1]) & (Timerout_count[0]);

	// Counter Design
	always @ (posedge clk, posedge reset)
	begin : TIMEROUT_COUNT
		if(reset)
			Timerout_count <= 0;
		else 
			if(state == QOpening)
				Timerout_count <= Timerout_count + 1;
			else
				Timerout_count <= 0;
	end
	
	// NSL AND SM (Case Statements)
	always @ (posedge clk, posedge reset)
	begin
		if(reset)
			state<=QI;
		else
		begin
			case(state)
				QI:
					if(U==1 && Z==0)
						state<=QG1get;
				QG1get:
					if(U==0)
						state<=QG1;
				QG1:
					if(U==0 && Z==1)
						state<=QG1get;
					else if(U==1)
						state<=QBad;
				QG10get:
					if(Z==0)
						state<=QG10;
				QG10:
					if(U==1 && Z==0)
						state<=QG101get;
					else if(Z==1)
						state<=QBad;
				QG101get:
					if(U==0)
						state<=QG1011;
					
				QG1011:
					state<=QOpening;
				QOpening:
					if(Timerout)
						state<=QI;
				QBad:
					if(U==0 && Z==0)
						state<=QI;
				default:	state <= UNK;

			endcase
		end
	end
	
endmodule
