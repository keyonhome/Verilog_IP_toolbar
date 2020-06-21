/////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: KEYANG Liu
// Module Name: Asy_fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module Asy_fifo
#(
parameter DATA_width = 8,
parameter DATA_depth = 32,
parameter SIZE = 5
)(
input wr_clk,
input rd_clk,
input wr_en,
input rd_en,
input rst_n,
input [DATA_width-1:0] Data_in,
output reg [DATA_width-1:0] Data_out,
output reg full,
output reg empty 
    );
    // define FIFO buffer 
    reg [DATA_width-1:0] fifo [DATA_depth-1:0];
    //define write pointer and read pointer
    reg [$clog2(DATA_depth):0] wr_ptr =0 ,rd_ptr=0;
  
    //define fifo wirte
    always@(posedge wr_clk or negedge rst_n )
    begin
        if(rst_n==0)begin
            wr_ptr<=0;
        end
        else if(wr_en ==1 && full!=1) begin
            wr_ptr<=wr_ptr+1;
            fifo[wr_ptr]<= Data_in;
        end
        else
            wr_ptr<=wr_ptr;
    end 
   //define fifo read 
    always@(posedge wr_clk or negedge rst_n )
    begin
        if(rst_n==0)begin
           rd_ptr<=0;
        end
        else if(rd_en ==1 && empty!=1) begin
            rd_ptr <= rd_ptr+1;
            Data_out <= fifo[rd_ptr];
            end
        else
            rd_ptr<=rd_ptr;     
    end 
    
 // binary into gray code
 wire [$clog2(DATA_depth) : 0] wr_ptr_g, rd_ptr_g; 

	assign wr_ptr_g = wr_ptr ^ (wr_ptr >> 1);
	assign rd_ptr_g = rd_ptr ^ (rd_ptr >> 1);
	
//define the second register for synchronize
reg [$clog2(DATA_depth) : 0] wr_ptr_gr, wr_ptr_grr, rd_ptr_gr, rd_ptr_grr; 
	
//wr_pointer after gray coding synchronize into read clock region

always@(posedge rd_clk or negedge rst_n)
begin
if(rst_n)begin
    wr_ptr_gr<= 0;
    wr_ptr_grr<=0;
end
    else begin
        wr_ptr_gr <= wr_ptr_g;
        wr_ptr_grr <= wr_ptr_gr;
    end
end
//rd_pointer after gray coding synchronize into  write clock region
always@(posedge rd_clk or negedge rst_n)
begin
if(rst_n)begin
    rd_ptr_gr<= 0;
    rd_ptr_grr<=0;
end
    else begin
        rd_ptr_gr <= rd_ptr_g;
        rd_ptr_grr <= rd_ptr_gr;
    end
end
//judgr empty
always@(posedge rd_clk or negedge rst_n) begin
		if(rst_n) empty <= 0;
		else if(wr_ptr_grr == rd_ptr_g) begin
			empty <= 1;
		end
		else empty <= 0;
 	end
//judge full
always@(posedge wr_clk) begin
 		if(rst_n) full <= 0;
 		else if( (rd_ptr_grr[$clog2(DATA_depth) - 2 : 0] == wr_ptr_g[$clog2(DATA_depth) - 2 : 0])
 			&& ( rd_ptr_grr[$clog2(DATA_depth):$clog2(DATA_depth)-1] != wr_ptr_g[$clog2(DATA_depth):$clog2(DATA_depth)-1] ) ) begin
 			full <= 1;
 		end
 		else full <= 0;
 	end




endmodule
