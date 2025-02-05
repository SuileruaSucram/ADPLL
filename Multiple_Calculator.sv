//Author: Dylan


//Takes a control signal Target_Freq. This is a 32 bit number representing two 16 bit numbers with 7 of those bits representing the decimal places.
//Target Freq should be in Mhz so you can currently target anywhere from 511.99 Mhz to 0.01 Mhz (or 10 kilohertz)
//Requires Ratio of how many times faster that the Crystal oscillator is from the input. If crystal is 2.5 times faster Ratio_Crystal should equal 250.
//Crystal frequecy has been hardcoded in as 50 Mhz on line 18, if needed this value can be changed. 
//Will calculate a multiplier to be sent to Divider module this number again can range from 511.99 to 0.01

//modified: Jisu
//similar thing to Controller.

`timescale 1ps/1ps
module Multiple_Calculator (En, Reset,Clk, Ratio_Crystal, Target_Freq, Multiplier);

input En, Reset,Clk;
input reg [31:0] Ratio_Crystal;
input reg [31:0] Target_Freq;
output reg [31:0] Multiplier;
logic [31:0] T_Multiplier, Temp_1, Temp_2, Temp_3, Temp_4, Temp_5, Temp_6, Temp_7, Temp_8;
reg [31:0] T1,T4,T2;
reg [8:0] Whole_1, Whole_2, Whole_1_T, Whole_2_T;
reg [6:0] Dec_1, Dec_2, Dec_1_T, Dec_2_T;

parameter C_Crystal = 50; //50 MHz

Number_Division DUT1 ((Whole_1_T*Ratio_Crystal),C_Crystal,Temp_1);

Number_Division DUT2 (Temp_1,100,T1);
Number_Division DUT3 ((Dec_1_T*Ratio_Crystal),(100*C_Crystal),Temp_3);
Number_Division DUT4 (Temp_1,100,T_Multiplier[15:7]);
Number_Division DUT5 ((Whole_2_T*Ratio_Crystal),C_Crystal,Temp_4);
Number_Division DUT6 (Temp_4,100,T4);
Number_Division DUT7 ((Dec_2_T*Ratio_Crystal),(100*C_Crystal),Temp_6);
Number_Division DUT8 (Temp_4,100,T_Multiplier[31:23]);

always @(posedge Clk or posedge Reset or negedge En)begin

	if(!En) begin
		/*Dec_1 	<= Dec_1;
		Whole_1	<= Whole_1;
		Dec_2 	<= Dec_2;
		Whole_2 <= Whole_2;
		Temp_1 	<= Temp_1;
		Temp_2 	<= Temp_2;
		Temp_3 	<= Temp_3;
		Temp_4 	<= Temp_4;
		Temp_5 	<= Temp_5;
		Temp_6 	<= Temp_6;
		T_Multiplier <= T_Multiplier;
		Multiplier 	<= Multiplier;
		Whole_1_T = Whole_1_T;
		Dec_1_T = Dec_1_T;
		Whole_2_T = Whole_2_T;
		Dec_2_T = Dec_2_T;
		*/
	end
	
	else if(Reset)begin
		/*Dec_1 	<= 1'b0;
		Whole_1	<= 1'b0;
		Dec_2 	<= 1'b0;
		Whole_2 <= 1'b0;
		*/
		/*Temp_1 	<= 1'b0;
		Temp_2 	<= 1'b0;
		Temp_3 	<= 1'b0;
		Temp_4 	<= 1'b0;
		Temp_5 	<= 1'b0;
		Temp_6 	<= 1'b0;
		T_Multiplier<= 32'b0;
		Multiplier 	<= 32'b0;
		Whole_1_T <= 9'b0;
		Dec_1_T <= 7'b0;
		Whole_2_T <= 9'b0;
		Dec_2_T <= 7'b0;
		*/
	end 

	else begin
		Dec_1 = Target_Freq[6:0];
		Whole_1 = Target_Freq[15:7];
		Dec_2 = Target_Freq[22:16];
		Whole_2 =Target_Freq[31:23];
		
		/*Whole_1_T = Whole_1;
		Dec_1_T = Dec_1;
		Whole_2_T = Whole_2;
		Dec_2_T = Dec_2;
		*/
		
		//First Multiplier
		//Temp_1 = (Whole_1*Ratio_Crystal)/(C_Crystal); //85
		//Temp_2 = Temp_1-(Temp_1/100)*100;
		Temp_2 = Temp_1-((T1)*100); //85

		//Temp_3 = (Dec_1*Ratio_Crystal)/(100*C_Crystal);//2
		
		Temp_7 = Temp_3 + Temp_2;
		if(Temp_7 >= 100)begin
			Temp_7 = Temp_7-100;
			Temp_1 = Temp_1 + 100;

		end
		T_Multiplier[6:0] = Temp_7; //87
		//T_Multiplier[15:7] = Temp_1/100; //0
		
//Same thing for second number
		//Temp_4 = (Whole_2*Ratio_Crystal)/(C_Crystal);//125
		//Temp_5 = Temp_4 -(Temp_4/100)*100;
		Temp_5 = Temp_4 -(T4*100);//25
		//Temp_6 = (Dec_2*Ratio_Crystal)/(100*C_Crystal);//3
		
		Temp_8 = Temp_6 + Temp_5; //28
		if(Temp_8 >= 100)begin
			Temp_8 = Temp_6 - 100;
			Temp_4 = Temp_4 + 100;

		end
		T_Multiplier[22:16] = Temp_8;
		//T_Multiplier[31:23] = Temp_4/100;
		
		Multiplier = T_Multiplier;
	end

end

endmodule


`timescale 1ps/1ps
module Multiple_Calculator_2_Tb;
	reg Reset, En, Clk;
	reg [15:0] Ratio_Crystal; //if Crystal is 5 times faster this value is 500
	reg [31:0] Target_Freq;
	wire [31:0] Multiplier;
	logic [8:0] Whole_1 = Multiplier[15:7];
	logic [6:0] Dec_1 = Multiplier[6:0];
	logic [8:0] Whole_2 = Multiplier[31:23];
	logic [6:0] Dec_2 = Multiplier[22:16];
	Multiple_Calculator DUT(En, Reset,Clk, Ratio_Crystal, Target_Freq, Multiplier);

	always begin
	En= 1'b1;  
	Clk = 1'b1;
	#10;
	Clk = 1'b0;
	#10;	
	Whole_1 = Multiplier[15:7];
	Dec_1 = Multiplier[6:0];
	Whole_2 = Multiplier[31:23];
	Dec_2 = Multiplier[22:16];

end
initial begin
		/*
		Reset=1'b0;
		Ratio_Crystal = 16'd250; //Crystal is 2.5 times faster than input (input = 20 Mhz)
		Target_Freq = 32'b00001100101111110000100010110010;//25.63 and 17.50
		#20;
		#200;
		Ratio_Crystal = 16'd200; //Crystal is 2 times faster than input (input = 25 Mhz)
		Target_Freq = 32'b00001100101111110000100010110010;//25.63 and 17.50
		#200;
		Reset =1'b0;
		Ratio_Crystal = 16'd112; //Crystal is 1.12 times faster than input (input = 44.64 Mhz)
		Target_Freq = 32'b00001100101111110000100010110010;//25.63 and 17.50
		#200;
		*/
		Reset = 1'b0;
		Ratio_Crystal = 16'd250;
		Target_Freq = 32'b00110010000000000001100100110010;//100 and 50.50
		#100;

	
	$stop;
end
endmodule 