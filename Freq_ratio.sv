//Author: Jisu
//1/7/2023

// This unit measure the frequency of the input and return as a positive integer.
//reference clock(refClk) is the input frequency, which is slower than the ring oscillator generated clock(clk)
//use average to get more accurate difference.
`timescale 1ps/1ps
module Freq_ratio(En,Reset,F_clk,F_ring,C_freq);
	input F_clk,F_ring;//F_clk: frequency of input clock; F_ring: frequency of a ring oscillator.
	input En, Reset; // Enable signal, Reset signal.
	logic combReset;//high reset
	output logic [31:0]C_freq=32'b0; 		//this is the output connected to the logic module
	logic [6:0]clkCounter=7'b0;	// this is connected to an output for debug purpose. We will change this to a internal reg later.
	logic [31:0]ringCounter=32'b0;	//this is connected to an output for debug purpose. We will change this to a internal reg later.


	parameter phaseAvg=7'd100; // this is controlling condition to measure certein numbers of slower clock. For other modules' design it should be 100.
				//if clkCounter = phaseAvg; C_freq = ringcounter;

	
	
	always_ff @(posedge F_clk or posedge combReset or negedge En) begin
		//(neg) hold when enable goes 0
		if(!En) begin	
			clkCounter <= clkCounter;
		end
		//(pos) reset the counter 
		else if(combReset) begin
			clkCounter <= 7'b0;	
		end
		//add clkCounter 1'b1.
		else begin
			if(clkCounter == 7'b1111111) begin
				clkCounter <= 7'b0;
			end
			else begin
				clkCounter <= clkCounter +7'b1;
			end
		end
		
		
	end



	always_ff @(posedge F_ring or posedge combReset or negedge En) begin
		if(!En) begin
			ringCounter <= ringCounter;
		end
		
		else if(combReset) begin
			ringCounter <= 9'b0;
		end
		
		else begin
			/*if(ringCounter == 32'hFFFFFFFF) begin
				ringCounter <= 32'b0;
			end
			else begin
				*/ringCounter <= ringCounter +9'b1;/*
			end
			*/
		end

	end

	always @(posedge F_clk or posedge Reset or negedge En) begin
		if(!En) begin
			C_freq 		<= C_freq;
			combReset 	<=combReset;
		end
		
		else if(Reset) begin
			C_freq 		<= 1'b0;
			combReset 	<=1'b1;
		end
		
		else begin
			if ( clkCounter == phaseAvg-1) begin
				C_freq 	<= ringCounter;		//save ringCounter to C_freq now
				combReset 	<= 1'b1;			//set reset to 1 now
			end 
			else begin
				C_freq 	<= C_freq;
				combReset 	<= 1'b0;
			end
		end
	end

endmodule
/*
`timescale 1ps/1ps
module Freq_Ratio_tb();
	logic clk, refClk,En,Reset; // speed: clk < refClk
	logic [31:0] freqNum;
	//logic [15:0]counter;
	//module Freq_ratio(En,Reset,F_clk,F_ring,C_freq);
	Freq_Ratio DUT (En,Reset,clk, refClk,freqNum);
	initial begin


		refClk=1;#10;
		refClk=0;#10;		
		refClk=1;#10;
		refClk=0;#10;
		clk =1;
		refClk=1;#10;
		refClk=0;#10;
		refClk=1;#10;
		clk =0;	
		refClk=0;#10;
		refClk=1;#10;
		refClk=0;#10;
		clk =1;	
		refClk=1;#10;
		refClk=0;#10;
		refClk=1;#10;
		clk =0;	
		refClk=0;#10;
		refClk=1;#10;
		refClk=0;#10;
		clk =1;	
		refClk=1;#10;
		refClk=0;#10;
		refClk=1;#10;
		clk =0;	
		refClk=0;#10;
		refClk=1;#10;
		refClk=0;#10;
		clk =1;	


		refClk=0;#10;
		refClk=1;#10;
		refClk=0;#10;
		refClk=1;#10;
		clk =0;
		refClk=0;#10;
		refClk=1;#10;
		refClk=0;#10;
		refClk=1;#10;
		clk =1;
		refClk=0;#10;
		refClk=1;#10;
		refClk=0;#10;
		refClk=1;#10;
		clk =0;
		refClk=0;#10;
		refClk=1;#10;
		refClk=0;#10;
		refClk=1;#10;
		clk =1;
		refClk=0;#10;
		refClk=1;#10;
		refClk=0;#10;
		refClk=1;#10;
		clk =0;
		refClk=0;#10;
		refClk=1;#10;
		refClk=0;#10;
		refClk=1;#10;
		clk =1;
		refClk=0;#10;
		refClk=1;#10;
		refClk=0;#10;
		refClk=1;#10;
		clk =0;
		refClk=0;#10;
		refClk=1;#10;
		refClk=0;#10;
		refClk=1;#10;
		clk =1;
		refClk=0;#10;
		refClk=1;#10;
		refClk=0;#10;
		refClk=1;#10;
		clk =0;
		refClk=0;#10;
		refClk=1;#10;
		refClk=0;#10;
		refClk=1;#10;
		clk =1;
		refClk=0;#10;
		refClk=1;#10;
		refClk=0;#10;
		refClk=1;#10;
		clk =0;
		refClk=0;#10;
		refClk=1;#10;
		refClk=0;#10;
		refClk=1;#10;
		clk =1;


		refClk=0;#10;
		refClk=1;#10;
		refClk=0;#10;

		refClk=0;#10;
		refClk=1;#10;
		refClk=0;#10;


	end
endmodule
*/