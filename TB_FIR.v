`timescale 1ns / 1ps

module TB_FIR1();

localparam signed [15:0] pi_pos = 16'h6488;    // pi+
localparam signed [15:0] pi_neg = 16'h9878;    // pi-
localparam  phase_inc_2M = 200;
localparam  phase_inc_30M = 3000;

reg rst_n;
reg sin_clk,fir_clk =0;
reg phase_tvalid = 0;
reg signed [15:0]  phase_2M=0 ;
reg signed [15:0] phase_30M =0;
wire tvalid_2M, tvalid_30M;
wire signed [15:0] sin_2M,sin_30M,cos_2M,cos_30M;

reg signed [15:0] data_in = 0;
wire signed [15:0] data_out;

cordic_0 cordic_2M (
                     .aclk (sin_clk),                    
                     .s_axis_phase_tvalid(phase_tvalid), 
                     .s_axis_phase_tdata(phase_2M),      
                     .m_axis_dout_tvalid (tvalid_2M),
                     .m_axis_dout_tdata ({sin_2M,cos_2M})  
                    );       
cordic_0 cordic_30M (
                     .aclk (sin_clk),                    
                     .s_axis_phase_tvalid(phase_tvalid), 
                     .s_axis_phase_tdata(phase_30M),      
                     .m_axis_dout_tvalid (tvalid_30M),
                     .m_axis_dout_tdata ({sin_30M,cos_30M})  
                    );                                                        

always@(posedge sin_clk)
begin
        phase_tvalid = 1'b1;
        
        if( phase_2M + phase_inc_2M < pi_pos)
        begin
            phase_2M<= phase_2M + phase_inc_2M;
        end
        else
        begin
            phase_2M <= pi_neg + phase_2M+ phase_inc_2M - pi_pos;
        end
        
        
        if( phase_30M + phase_inc_30M < pi_pos)
        begin
            phase_30M<= phase_30M + phase_inc_30M;
        end
        else
        begin
            phase_30M <= pi_neg + (phase_30M+ phase_inc_30M - pi_pos);
        end        
        
end
                                                 
initial                                               
begin                                                 
    sin_clk = 0;                 //sincos_clk = 500Mhz
    forever #(1) sin_clk = !sin_clk;        
end   
                                                
initial                                               
begin                               //fir_clk = 100Mhz
    fir_clk = 0;                                      
    forever #(5) fir_clk = !fir_clk;          
end                                                   

initial       

begin         
    rst_n = 1;
#50 rst_n = 0;
#10 rst_n = 1;
end           
              

always@(posedge fir_clk)
begin
    data_in <= (sin_30M + sin_2M)/2;
end

FIR test
             (
              .clk(fir_clk),
              .rst_n(rst_n),
              .data_in(data_in),
              .data_out(data_out)
              );




endmodule
