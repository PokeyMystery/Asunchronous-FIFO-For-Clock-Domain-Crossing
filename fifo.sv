module asy_fifo#(
  parameter WIDTH = 8,
  parameter DEPTH = 12
)(
  input logic clk_wr,
  input logic clk_rd,
  input logic rst_n,
  input logic [WIDTH-1:0] wr_data,
  output logic [WIDTH-1:0] rd_data,
  input logic wr_en,
  input logic rd_en,
  output logic flag_full,
  output logic flag_empty
);

  reg [WIDTH-1:0] fifo [DEPTH-1:0];
  localparam POINTER_WIDTH = $clog2(DEPTH);
  logic [POINTER_WIDTH-1:0] wr_ptr, rd_ptr, wr_lp, rd_lp, count;

  // Write Clock Domain
  always @(posedge clk_wr or negedge rst_n) begin
    if (!rst_n) begin
      foreach (fifo[i]) fifo[i] = 0;
      wr_ptr = 0;
      wr_lp = 0;
      count = 0;
      flag_full = 0;
    end else if (wr_en && !flag_full) begin
      fifo[wr_ptr] = wr_data;
      if (wr_ptr == DEPTH-1) wr_lp = wr_lp + 1;
      wr_ptr = (wr_ptr + 1) % DEPTH;
      count = count + 1;
      flag_empty = 0;
      if (wr_ptr == rd_ptr && wr_lp != rd_lp) flag_full = 1;
      else flag_full = 0;
    end
  end

  // Read Clock Domain
  always @(posedge clk_rd or negedge rst_n) begin
    if (!rst_n) begin
      foreach (fifo[i]) fifo[i] = 0;
      rd_ptr = 0;
      rd_lp = 0;
      rd_data = 0;
      flag_empty = 1;
    end else if (rd_en && !flag_empty) begin
      rd_data = fifo[rd_ptr];
      flag_full = 0;
      if (rd_ptr == DEPTH-1) rd_lp = rd_lp + 1;
      rd_ptr = (rd_ptr + 1) % DEPTH;
      count = count - 1;
      if (rd_ptr == wr_ptr && wr_lp == rd_lp) flag_empty = 1;
      else flag_empty = 0;
    end
  end
endmodule
