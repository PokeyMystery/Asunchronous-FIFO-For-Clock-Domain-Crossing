interface asy_fifo_intf#(parameter WIDTH=8)(input clk_wr, clk_rd);
  logic [WIDTH-1:0] wr_data;
  logic [WIDTH-1:0] rd_data;
  logic wr_en, rd_en;
  logic flag_full, flag_empty;
  logic rst_n;
  
  clocking drv_cb_wr @(posedge clk_wr);
    default input #1step output #1;
    output wr_en;
    output wr_data;
  endclocking 

  clocking drv_cb_rd @(posedge clk_rd);
    default input #1step output #1;
    output rd_en;
  endclocking 
  
  clocking mon_cb_rd @(posedge clk_rd);
    default input #0 output #1;
    input rst_n;
    input rd_en;
    input rd_data;
    input flag_empty;
  endclocking 
  
  clocking mon_cb_wr @(posedge clk_wr);
    default input #0 output #1;
    input rst_n;
    input wr_en;
    input wr_data;
    input flag_full;
  endclocking 


endinterface
