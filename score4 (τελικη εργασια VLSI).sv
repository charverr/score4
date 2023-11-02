module score4 (
	input  logic clk,
	input  logic rst,

	input  logic left,
	input  logic right,
	input  logic put,
	
	output logic player,
	output logic invalid_move,
	output logic win_a,
	output logic win_b,
	output logic full_panel,

	output logic hsync,
	output logic vsync,
	output logic [3:0] red,
	output logic [3:0] green,
	output logic [3:0] blue	
);



logic left_edge_reg;
logic right_edge_reg;
logic put_edge_reg;


logic en;
logic [0:9]h;
logic [0:9]v;
int panel[0:5][0:6];
logic [0:6]play;

int empty_block;
int i;
logic state_change;



always_ff @(posedge clk , posedge rst ) begin
 if (rst) begin
 left_edge_reg <= 1'b0;
 right_edge_reg <= 1'b0;
 put_edge_reg <= 1'b0;
 end else begin
 left_edge_reg <= left;
 right_edge_reg <= right;
 put_edge_reg <= put;
 
 end
end
assign falling_edge_l = left_edge_reg & (~left);
assign rising_edge_l = (~left_edge_reg) & left;
assign falling_edge_r = right_edge_reg & (~right);
assign rising_edge_r = (~right_edge_reg) & right;
assign falling_edge_p = put_edge_reg & (~put);
assign rising_edge_p = (~put_edge_reg) & put;




//Player actions (left,right,put)
always_ff@(posedge clk) begin
 if(rst)begin 
	player <= 0;
	invalid_move <= 0;
	win_a <= 0;
	win_b <= 0;
	empty_block <= 5;
	play <= 7'b1000000;
	i <= 0;
	panel <= '{ '{0,0,0,0,0,0,0},'{0,0,0,0,0,0,0},'{0,0,0,0,0,0,0},'{0,0,0,0,0,0,0},'{0,0,0,0,0,0,0},'{0,0,0,0,0,0,0}};
 end
	else begin	
		invalid_move <= 1'b0;
		if(rising_edge_r)begin 
			if(play==7'b0000001)begin
				/*play <= 7'b1000000 ;
				i <= 0;*/
				invalid_move <= 1'b1;
			end
			else begin 
				play <= play >> 1;
				i++;
			end
			state_change <= 1;
		end
		else if(rising_edge_l)begin 
			if(play==7'b1000000)begin
				/*play <= 7'b0000001;
				i <= 6;*/
				invalid_move <= 1'b1;
			end
			else begin
				play <=  play << 1 ;
				i--;
			end
			state_change <= 1;
		end
		else if(rising_edge_p)begin
			if(empty_block>=0)begin
				if(!player)begin
					panel[empty_block][i]=1;	
				end
				else begin 
					panel[empty_block][i]=2;
				end	
				player <= !player;
				state_change <= 1;
			end
			else invalid_move <= 1'b1;
		end
	end
end


//Full Panel, Win Check and Lowest Empty Block Finder
always_ff@(posedge clk) begin 
  if(state_change)begin	
			//$display("play: %b, i:%d\n",play,i);
			for(int j=5;j>=0;j--)begin
				if(panel[j][i]==0)begin
					empty_block <= j;
					//$display("empty_block:%d\n",empty_block);
					break;	
				end	
					else empty_block <= -1;				
			end
		
		//$display("Empty_block:%d,Panel:%p\n",empty_block,panel);
		if(panel[0][0]*panel[0][1]*panel[0][2]*panel[0][3]*panel[0][4]*panel[0][5]*panel[0][6]!=0)full_panel <= 1;
		else full_panel <= 0;
		
		//Horizontal Check 
    for (int row = 0; row<=5 ; row++ )begin
        for (int col = 0; col<=3; col++)begin
            if (panel[row][col] == 1 && panel[row][col+1] == 1 && panel[row][col+2] == 1 && panel[row][col+3] == 1)begin
                win_a <= 1;
					 
            end  
				else if (panel[row][col] == 2 && panel[row][col+1] == 2 && panel[row][col+2] == 2 && panel[row][col+3] == 2)begin
                win_b <= 1;
					 
            end      
        end
    end
    //Vertical Check
    for (int col = 0; col<=6 ; col++ )begin
        for (int row = 0; row<=2; row++)begin
            if (panel[row][col] == 1 && panel[row+1][col] == 1 && panel[row+2][col] == 1 && panel[row+3][col] == 1)begin
                win_a <= 1;
					 
            end  
				else if (panel[row][col] == 2 && panel[row+1][col] == 2 && panel[row+2][col] == 2 && panel[row+3][col] == 2)begin
                win_b <= 1;
					 
            end  
        end
    end
	 
	 //Upwards Diagonal Check
    for (int row = 5; row>=3 ; row-- )begin
        for (int col = 0; col<=3; col++)begin
            if (panel[row][col] == 1 && panel[row-1][col+1] == 1 && panel[row-2][col+2] == 1 && panel[row-3][col+3] == 1)begin
                win_a <= 1;
					 
            end  
				else if (panel[row][col] == 2 && panel[row-1][col+1] == 2 && panel[row-2][col+2] == 2 && panel[row-3][col+3] == 2)begin
                win_b <= 1;
					 
            end  
        end
    end
	 
	 //Downwards Diagonal Check
    for (int row = 0; row<=2 ; row++ )begin
        for (int col = 0; col<=3; col++)begin
            if (panel[row][col] == 1 && panel[row+1][col+1] == 1 && panel[row+2][col+2] == 1 && panel[row+3][col+3] == 1)begin
                win_a <= 1;
					 
            end  
				else if (panel[row][col] == 2 && panel[row+1][col+1] == 2 && panel[row+2][col+2] == 2 && panel[row+3][col+3] == 2)begin
                win_b <= 1;
					 
            end  
        end
    end
		state_change <= 0;
	end
end
	

//A better way of driving VGA colours(failed attempt)
/*
always_ff@(posedge clk) begin 
	y <= 12;
	for(int k=0;k<=5;k++)begin 
		x <= 24;
		for(int m=0;m<=6;m++)begin 
			if(v>=y && v<=y+48 && h>=x && h<=x+48)begin 
				if(panel[k][m]==1)red <= 4'b1111;
				else if(panel[k][m]==2)green <= 4'b1111;
				else begin 
					red <= 4'b0000;
					green <= 4'b0000;
				end
			end
			x <= x+72;
		end
		y <= y+60;
	end
	
	x <= 24;
	for(int k1=0;k1<=6;k1++)begin 
		if(v>=y+24 && v<=y+36 && h>=x && h<=x+48)begin 
			if(play[k1]== !player)red <= 4'b1111;
			else green <= 4'b1111;		
		end
		x <= x+72;
	end
end
*/



//25Mhz simulation
always_ff@(posedge clk , negedge rst )begin
  if(rst)begin
   en <= 0;
	  end
  else en <= ~en;
end


//Pixel counter
always_ff@(posedge clk , negedge rst )begin 
  if(rst)begin
   h<=0;
   v<=0;
	end
  else if(en)begin 
  
    if(h<=798)begin 
      h <= h+1;
    end
    else begin 
      h<=0;
    end 
	 
    if(v<=524 && h==799)begin
      v <= v+1;
	 end
	 else if(v==525) begin 
	   v<=0;
    end
	 
  end
 end

//RGB and Hsync,Vsync assignments
assign red=(v>=12 && v<=60 && h>=24 && h<=72 && panel[0][0] ==1 )?4'b1111:
		 (v>=12 && v<=60 && h>=96 && h<=144 &&panel[0][1] == 1 )?4'b1111:
		 (v>=12 && v<=60 && h>=168 && h<=216&&panel[0][2] == 1 )?4'b1111:
		 (v>=12 && v<=60 && h>=240 && h<=288&&panel[0][3] == 1 )?4'b1111:
		 (v>=12 && v<=60 && h>=312 && h<=360&&panel[0][4] == 1 )?4'b1111:
		 (v>=12 && v<=60 && h>=384 && h<=432&&panel[0][5] == 1 )?4'b1111:
		 (v>=12 && v<=60 && h>=456 && h<=504&&panel[0][6] == 1 )?4'b1111:
		 (v>=72 && v<=120 && h>=24 && h<=72&&panel[1][0] == 1 )?4'b1111:
		 (v>=72 && v<=120 && h>=96 && h<=144&&panel[1][1] == 1 )?4'b1111:
		 (v>=72 && v<=120 && h>=168 && h<=216&&panel[1][2] == 1 )?4'b1111:
		 (v>=72 && v<=120 && h>=240 && h<=288&&panel[1][3] == 1 )?4'b1111:
		 (v>=72 && v<=120 && h>=312 && h<=360&&panel[1][4] == 1 )?4'b1111:
		 (v>=72 && v<=120 && h>=384 && h<=432&&panel[1][5] == 1 )?4'b1111:
		 (v>=72 && v<=120 && h>=456 && h<=504&&panel[1][6] == 1 )?4'b1111:
		 (v>=132 && v<=180 && h>=24 && h<=72&&panel[2][0] == 1 )?4'b1111:
		 (v>=132 && v<=180 && h>=96 && h<=144&&panel[2][1] == 1 )?4'b1111:
		 (v>=132 && v<=180 && h>=168 && h<=216&&panel[2][2] == 1 )?4'b1111:
		 (v>=132 && v<=180 && h>=240 && h<=288&&panel[2][3] == 1 )?4'b1111:
		 (v>=132 && v<=180 && h>=312 && h<=360&&panel[2][4] == 1 )?4'b1111:
		 (v>=132 && v<=180 && h>=384 && h<=432&&panel[2][5] == 1 )?4'b1111:
		 (v>=132 && v<=180 && h>=456 && h<=504&&panel[2][6] == 1 )?4'b1111:
		 (v>=192 && v<=240 && h>=24 && h<=72&&panel[3][0] == 1 )?4'b1111:
		 (v>=192 && v<=240 && h>=96 && h<=144&&panel[3][1] == 1 )?4'b1111:
		 (v>=192 && v<=240 && h>=168 && h<=216&&panel[3][2] == 1 )?4'b1111:
		 (v>=192 && v<=240 && h>=240 && h<=288&&panel[3][3] == 1 )?4'b1111:
		 (v>=192 && v<=240 && h>=312 && h<=360&&panel[3][4] == 1 )?4'b1111:
		 (v>=192 && v<=240 && h>=384 && h<=432&&panel[3][5] == 1 )?4'b1111:
		 (v>=192 && v<=240 && h>=456 && h<=504&&panel[3][6] == 1 )?4'b1111:
		 (v>=252 && v<=300 && h>=24 && h<=72&&panel[4][0] == 1 )?4'b1111:
		 (v>=252 && v<=300 && h>=96 && h<=144&&panel[4][1] == 1 )?4'b1111:
		 (v>=252 && v<=300 && h>=168 && h<=216&&panel[4][2] == 1 )?4'b1111:
		 (v>=252 && v<=300 && h>=240 && h<=288&panel[4][3] == 1 )?4'b1111:
		 (v>=252 && v<=300 && h>=312 && h<=360&&panel[4][4] == 1 )?4'b1111:
		 (v>=252 && v<=300 && h>=384 && h<=432&&panel[4][5] == 1 )?4'b1111:
		 (v>=252 && v<=300 && h>=456 && h<=504&&panel[4][6] == 1 )?4'b1111:
		 (v>=312 && v<=360 && h>=24 && h<=72 && panel[5][0] == 1)?4'b1111:
		 (v>=312 && v<=360 && h>=96 && h<=144&&panel[5][1] == 1 )?4'b1111:
		 (v>=312 && v<=360 && h>=168 && h<=216&&panel[5][2] == 1 )?4'b1111:
		 (v>=312 && v<=360 && h>=240 && h<=288&&panel[5][3] == 1 )?4'b1111:
		 (v>=312 && v<=360 && h>=312 && h<=360&&panel[5][4] == 1 )?4'b1111:
		 (v>=312 && v<=360 && h>=384 && h<=432&&panel[5][5] == 1 )?4'b1111:
		 (v>=312 && v<=360 && h>=456 && h<=504&&panel[5][6] == 1 )?4'b1111:
		 (v>=384 && v<=396 && h>=24 && h<=72 && play[0] && !player )?4'b1111:
		 (v>=384 && v<=396 && h>=96 && h<=144&& play[1] && !player )?4'b1111:
		 (v>=384 && v<=396 && h>=168 && h<=216&& play[2] && !player )?4'b1111:
		 (v>=384 && v<=396 && h>=240 && h<=288&& play[3] && !player)?4'b1111:
		 (v>=384 && v<=396 && h>=312 && h<=360&& play[4] && !player )?4'b1111:
		 (v>=384 && v<=396 && h>=384 && h<=432&& play[5] && !player )?4'b1111:
		 (v>=384 && v<=396 && h>=456 && h<=504&& play[6] && !player )?4'b1111:4'b0000;
		
assign green=(v>=12 && v<=60 && h>=24 && h<=72 && panel[0][0] == 2 )?4'b1111:
		 (v>=12 && v<=60 && h>=96 && h<=144 &&panel[0][1] == 2 )?4'b1111:
		 (v>=12 && v<=60 && h>=168 && h<=216&&panel[0][2] == 2 )?4'b1111:
		 (v>=12 && v<=60 && h>=240 && h<=288&&panel[0][3] == 2 )?4'b1111:
		 (v>=12 && v<=60 && h>=312 && h<=360&&panel[0][4] == 2 )?4'b1111:
		 (v>=12 && v<=60 && h>=384 && h<=432&&panel[0][5] == 2 )?4'b1111:
		 (v>=12 && v<=60 && h>=456 && h<=504&&panel[0][6] == 2 )?4'b1111:
		 (v>=72 && v<=120 && h>=24 && h<=72&&panel[1][0] == 2 )?4'b1111:
		 (v>=72 && v<=120 && h>=96 && h<=144&&panel[1][1] == 2 )?4'b1111:
		 (v>=72 && v<=120 && h>=168 && h<=216&&panel[1][2] == 2 )?4'b1111:
		 (v>=72 && v<=120 && h>=240 && h<=288&&panel[1][3] == 2 )?4'b1111:
		 (v>=72 && v<=120 && h>=312 && h<=360&&panel[1][4] == 2 )?4'b1111:
		 (v>=72 && v<=120 && h>=384 && h<=432&&panel[1][5] == 2 )?4'b1111:
		 (v>=72 && v<=120 && h>=456 && h<=504&&panel[1][6] == 2 )?4'b1111:
		 (v>=132 && v<=180 && h>=24 && h<=72&&panel[2][0] == 2 )?4'b1111:
		 (v>=132 && v<=180 && h>=96 && h<=144&&panel[2][1] == 2 )?4'b1111:
		 (v>=132 && v<=180 && h>=168 && h<=216&&panel[2][2] == 2 )?4'b1111:
		 (v>=132 && v<=180 && h>=240 && h<=288&&panel[2][3] == 2 )?4'b1111:
		 (v>=132 && v<=180 && h>=312 && h<=360&&panel[2][4] == 2 )?4'b1111:
		 (v>=132 && v<=180 && h>=384 && h<=432&&panel[2][5] == 2 )?4'b1111:
		 (v>=132 && v<=180 && h>=456 && h<=504&&panel[2][6] == 2 )?4'b1111:
		 (v>=192 && v<=240 && h>=24 && h<=72&&panel[3][0] == 2 )?4'b1111:
		 (v>=192 && v<=240 && h>=96 && h<=144&&panel[3][1] == 2 )?4'b1111:
		 (v>=192 && v<=240 && h>=168 && h<=216&&panel[3][2] == 2 )?4'b1111:
		 (v>=192 && v<=240 && h>=240 && h<=288&&panel[3][3] == 2 )?4'b1111:
		 (v>=192 && v<=240 && h>=312 && h<=360&&panel[3][4] == 2 )?4'b1111:
		 (v>=192 && v<=240 && h>=384 && h<=432&&panel[3][5] == 2 )?4'b1111:
		 (v>=192 && v<=240 && h>=456 && h<=504&&panel[3][6] == 2 )?4'b1111:
		 (v>=252 && v<=300 && h>=24 && h<=72&&panel[4][0] == 2 )?4'b1111:
		 (v>=252 && v<=300 && h>=96 && h<=144&&panel[4][1] == 2 )?4'b1111:
		 (v>=252 && v<=300 && h>=168 && h<=216&&panel[4][2] == 2 )?4'b1111:
		 (v>=252 && v<=300 && h>=240 && h<=288&panel[4][3] == 2 )?4'b1111:
		 (v>=252 && v<=300 && h>=312 && h<=360&&panel[4][4] == 2 )?4'b1111:
		 (v>=252 && v<=300 && h>=384 && h<=432&&panel[4][5] == 2 )?4'b1111:
		 (v>=252 && v<=300 && h>=456 && h<=504&&panel[4][6] == 2 )?4'b1111:
		 (v>=312 && v<=360 && h>=24 && h<=72 && panel[5][0] == 2)?4'b1111:
		 (v>=312 && v<=360 && h>=96 && h<=144&&panel[5][1] == 2 )?4'b1111:
		 (v>=312 && v<=360 && h>=168 && h<=216&&panel[5][2] == 2 )?4'b1111:
		 (v>=312 && v<=360 && h>=240 && h<=288&&panel[5][3] == 2 )?4'b1111:
		 (v>=312 && v<=360 && h>=312 && h<=360&&panel[5][4] == 2 )?4'b1111:
		 (v>=312 && v<=360 && h>=384 && h<=432&&panel[5][5] == 2 )?4'b1111:
		 (v>=312 && v<=360 && h>=456 && h<=504&&panel[5][6] == 2 )?4'b1111:
		 (v>=384 && v<=396 && h>=24 && h<=72 && play[0] && player )?4'b1111:
		 (v>=384 && v<=396 && h>=96 && h<=144&& play[1] && player )?4'b1111:
		 (v>=384 && v<=396 && h>=168 && h<=216&& play[2] && player )?4'b1111:
		 (v>=384 && v<=396 && h>=240 && h<=288&& play[3] && player)?4'b1111:
		 (v>=384 && v<=396 && h>=312 && h<=360&& play[4] && player )?4'b1111:
		 (v>=384 && v<=396 && h>=384 && h<=432&& play[5] && player )?4'b1111:
		 (v>=384 && v<=396 && h>=456 && h<=504&& play[6] && player )?4'b1111:4'b0000;
		 
assign blue=4'b0000;		 
assign vsync=(v>=491 && v<=492)?0:1;
assign hsync=(h>=656 && h<=751)?0:1;

endmodule
