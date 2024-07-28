`timescale 1ns / 1ps
parameter coff0 = 16'h04F6;
parameter coff1 = 16'h0ae4;
parameter coff2 = 16'h1089;
parameter coff3 = 16'h1496;
parameter coff4 = 16'h160f;
parameter coff5 = 16'h1496;
parameter coff6 = 16'h1089;
parameter coff7 = 16'h0ae4;
parameter coff8 = 16'h04f6;

module FIR 
             (
              input clk,
              input rst_n,
              input signed [15:0]  data_in,
              output signed [15:0] data_out
            );
integer i,j,k;
logic signed [15:0] cof [8:0];
logic signed [15:0] delay [8:0];
logic signed [31:0] prod [8:0];        // multiply delay*cof
logic signed [32:0] sum0 [4:0];
logic signed [33:0] sum1 [2:0];
logic signed [34:0] sum2 [1:0];
logic signed [35:0] sum3 ;

assign cof[0] = coff0;  // assign coefficients from parameters
assign cof[1] = coff1;
assign cof[2] = coff2;
assign cof[3] = coff3;
assign cof[4] = coff4;
assign cof[5] = coff5;
assign cof[6] = coff6;
assign cof[7] = coff7;
assign cof[8] = coff8;

 always@(posedge clk or posedge rst_n)                   // delay
 begin
    if(!rst_n)
       for(i=0;i<=8;i=i+1)
       begin
            delay[i] <= 0;
      end
    else
    begin
       delay[0] <= data_in;
       for(i=1;i<=8;i=i+1)
        begin
            delay[i] <= delay[i-1];
       end
    end
end
                       
always@(posedge clk or negedge rst_n)                //  multiply
begin
   if(!rst_n)
        for(j=0;j<=8;j=j+1)                   
        begin
           prod[j] <= 0;
       end   
   else 
        for(j=0;j<=8;j=j+1)                   
        begin
           prod[j] <= delay[j]*cof[j];
       end
end
 
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
       sum0[0] <= 0;
       sum0[1] <= 0;
       sum0[2] <= 0;
       sum0[3] <= 0;
       sum0[4] <= 0;
    end
    else
    begin
       sum0[0] <= prod[0]+prod[1];
       sum0[1] <= prod[2]+prod[3];
       sum0[2] <= prod[4]+prod[5];
       sum0[3] <= prod[6]+prod[7];
       sum0[4] <= prod[8];
   end
end
    
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        sum1[0] <= 0;    
        sum1[1] <= 0;    
        sum1[2] <= 0;
    end
    else
    begin
       sum1[0] <= sum0[0]+sum0[1];    
       sum1[1] <= sum0[2]+sum0[3];    
       sum1[2] <= sum0[4];
    end
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        sum2[0] <= 0;    
        sum2[1] <= 0; 
    end
    else
    begin
         sum2[0] <= sum1[0]+sum1[1];    
         sum2[1] <= sum1[2];    
    end
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
         sum3 <= 0; 

    else
         sum3 <= sum2[0]+sum2[1]; 
end

          
assign data_out = $signed(sum3[35:14]);   
            
endmodule
