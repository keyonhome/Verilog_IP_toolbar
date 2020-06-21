
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: Keyang Liu
// Module Name: SynFIFO
// Project Name: Syn_FIFO
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


module SynFIFO
#(parameter data_width = 8,
    parameter add_width = 4,
  parameter depth = (1<< add_width))
(input rd_en,
input wr_en,
input clk,
input rst_n,
input [data_width-1:0] data_in,
output reg [data_width-1:0]data_out,
output empty,
output full
  );
 reg [add_width-1:0] r_ptr;
 reg[add_width-1:0] w_ptr;
 reg [add_width-1 :0] fifo [depth-1 : 0];
 reg [depth-1:0] cnt;
 reg rd_en_r;
 reg wr_en_r;
 
 assign full = (cnt==depth-1)?1:0;
 assign empty = (cnt==0)?1:0;
 
 // reset function  to syn the enable signal
 
// always@(posedge clk or negedge rst_n)
// begin
//    if(rst_n == 1'b0)begin
//        rd_en_r <=0;
//        wr_en_r<=0;
//     end
//     else begin
//     rd_en_r<=rd_en;
//     wr_en_r<=wr_en;
//    end    
// end
 //write fucntion
 always@(posedge clk or negedge rst_n)
 begin
 if(rst_n==0)begin
 w_ptr<=0;
 end
 else if(wr_en) begin
    w_ptr <= w_ptr+1;
 end
 else
    w_ptr<=w_ptr;
 end
 
 //rd function
 always@(posedge clk or negedge rst_n)
 begin
 if(rst_n==0)begin
 r_ptr<=0;
 end
 else if(rd_en) begin
    r_ptr <= r_ptr+1;
 end
 else
    r_ptr<=r_ptr;
 end
 
 //full/empty controllor
 always@(posedge clk or posedge rst_n)
 begin
 if(rst_n==0)begin
  cnt<=0;
 end
 else if(wr_en && !rd_en && (cnt!=depth-1) )
    cnt<=cnt+1;
 else if(!wr_en && rd_en && (cnt!= 0))
     cnt <=cnt-1;
 else
    cnt<=cnt;
 
 end
 //dual_RAM function
 integer i;
 always@(posedge clk or negedge rst_n)begin
 if(rst_n==0)begin
    for(i=0;i<depth-1;i=i+1)
        fifo[i]<=0;   
 end
 else if(wr_en && (cnt!=depth-1))
    fifo[w_ptr]<=data_in;
 end
 
 //function of read fifo
 reg[data_width-1:0] data_ram;
 always@(posedge clk or negedge rst_n) begin
  if(rst_n==0)begin
    data_ram<=0;   
 end
 else if(rd_en && (cnt!=0))
    data_ram <=fifo[r_ptr];
 end
 
 always@(posedge clk or negedge rst_n) begin
 if(rst_n==0)begin
    data_out<=0;   
 end
 else if(rd_en && (cnt!=0))
    data_out <=data_ram;
 end
endmodule
