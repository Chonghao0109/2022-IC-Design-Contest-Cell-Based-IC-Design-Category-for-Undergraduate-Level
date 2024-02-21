
module JAM(
	input wire CLK,
	input wire RST,
	input wire [6:0] Cost,
	output reg [2:0] W,
	output reg [2:0] J,
	output reg [3:0] MatchCount,
	output reg [9:0] MinCost,
	output reg  Valid 
);
	
	
	localparam size = 8;



	reg [2:0] P 		[size-1:0];
	reg [7:0] READ_DATA;

	reg [2:0] REG_P	[size-1:0];
	reg [2:0] NEXT_P 	[size-1:0];
	reg [7:0] NEXT_READ_DATA;
	reg [2:0] swap_position1,swap_position2;
	reg [2:0] value;

	reg [2:0] NEXT_W;//,NEXT_J;
	reg Data_Finish;

	

	// - - - - - - - - - Finit State Machine - - - - - - - - - - - -
	
	//	
	//
	//

	parameter 	Loading_Data 		= 0,
							Calculate_Cost	= 1,
							Refresh_Data		= 2,
							Data_Out				= 3;
							

	reg [9:0] Data_Cost;
	reg [6:0] Data [size-1:0];
	reg [1:0] state;


	
	integer j;
	always@(posedge CLK or posedge RST) begin : proc_state
		if(RST) begin
			state <= Loading_Data;
			for(j=0;j<size;j=j+1) P[j] <= $unsigned(j);
			//J <= 0;
			W <= 0;
			MatchCount <= 1;
			MinCost <= 1023;
		end else begin
			case(state)



				Loading_Data 			:begin

					if(W==7)begin
						state <= Calculate_Cost;
					end
					else begin
						W <= W + 1;
						//J <= W + 1;
					end

					Data[W] <= Cost;

				end




				Calculate_Cost 			:begin
					
					if( Data_Cost < MinCost)begin
						MinCost <= Data_Cost;
						MatchCount <= 1;
					end
					else if(Data_Cost==MinCost)begin
						MatchCount <= MatchCount+1;
					end

					if(P[0]==7&&P[1]==6&&P[2]==5&&P[3]==4&&P[4]==3&&P[5]==2&&P[6]==1) state <= Data_Out;
					else state <= Refresh_Data;
					
					for(j=0;j<size;j=j+1) P[j] <= NEXT_P[j];
					//{P[0],P[1],P[2],P[3],P[4],P[5],P[6],P[7]} <= 
					//	{NEXT_P[0],NEXT_P[1],NEXT_P[2],NEXT_P[3],NEXT_P[4],NEXT_P[5],NEXT_P[6],NEXT_P[7]};

					READ_DATA <= NEXT_READ_DATA;
					
					W <= 7;
					//J <= NEXT_P[7];
				
				end




				Refresh_Data			:begin
					
					W <= NEXT_W;
					//J <= NEXT_J;

					Data[W] <= Cost;
										
					if(Data_Finish) state <= Calculate_Cost;
					else state <= Refresh_Data;

				end



				default state <= Data_Out;


			endcase
		end
	end
	
	always@(*) begin
		Valid <= state==Data_Out?1:0;
	end


	always@(*)begin
		case(state)
			Loading_Data: J <= W;
			default J <= P[W];
		endcase
	end



	always@(*)  begin : proc_Data_Cost
		Data_Cost = Data[0]+Data[1]+Data[2]+Data[3]+Data[4]+Data[5]+Data[6]+Data[7];
	end
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -



	// - - - - - - - - - - - - - - - Next_P - - - - - - - - - - - - - - -
	// max_delay 2 cycle
	
	integer i;
	always@(*)  begin : proc_NEXT_P 
		// Step 1.
		// Find swap_position1
		swap_position1 = 0;
		for(i=0;i<(size-1);i=i+1)begin
			if(P[i] < P[i+1])
				swap_position1 = $unsigned(i);
		end


		// Step 2.
		// Find swap_position1
		swap_position2 = (size-1);
		value = (size-1);
		for(i=0;i<size;i=i+1)begin
			if(i>swap_position1)begin
				if( P[i] > P[swap_position1] && P[i] <= value)begin
					swap_position2 = $unsigned(i);
					value = P[swap_position2];
				end
			end
		end

		

	end
	always @(*) begin

		// swap 
		for(i=0;i<size;i=i+1)begin
			if(i==swap_position1) REG_P[i] <= P[swap_position2];
			else if(i==swap_position2) REG_P[i] <= P[swap_position1];
			else REG_P[i] <= P[i];
		end


		for(i=0;i<size;i=i+1)begin 
			if(i>swap_position1)
				NEXT_P[i] <= REG_P[ size-i+swap_position1 ];
			else
				NEXT_P[i] <= REG_P[i];
		end

		for(i=0;i<size;i=i+1)	NEXT_READ_DATA[i] <= NEXT_P[i]==P[i]?0:1;

	end
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -




	// - - - - - - - - - - - - - - - Next Read - - - - - - - - - - - - - - - -

	
	integer k;
	always@(*)  begin :proc_Next_Read
		Data_Finish = 1;
		//for(k=0;k<8;k=k+1)begin
		//	if(READ_DATA[k] && k<W) begin
		//		NEXT_W = k;
		//		Data_Finish = 0;
		//	end
		//end
		if(READ_DATA[7] && 7<W) begin
			NEXT_W = 7;
			Data_Finish = 0;
		end
		else if(READ_DATA[6] && 6<W) begin
			NEXT_W = 6;
			Data_Finish = 0;
		end
		else if(READ_DATA[5] && 5<W) begin
			NEXT_W = 5;
			Data_Finish = 0;
		end
		else if(READ_DATA[4] && 4<W) begin
			NEXT_W = 4;
			Data_Finish = 0;
		end
		else if(READ_DATA[3] && 3<W) begin
			NEXT_W = 3;
			Data_Finish = 0;
		end
		else if(READ_DATA[2] && 2<W) begin
			NEXT_W = 2;
			Data_Finish = 0;
		end
		else if(READ_DATA[1] && 1<W) begin
			NEXT_W = 1;
			Data_Finish = 0;
		end
		else if(READ_DATA[0] && 0<W) begin
			NEXT_W = 0;
			Data_Finish = 0;
		end
	end

	//always @(*) begin 
	//	NEXT_J = P[NEXT_W];
	//end

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -




endmodule 



 
