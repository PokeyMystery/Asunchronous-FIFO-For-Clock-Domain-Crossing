`timescale 1ns/10ps
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "test.sv"

module tb;
    reg clk_wr, clk_rd;

    // Clock generation
    always #5 clk_wr = ~clk_wr;
    always #5 clk_rd = ~clk_rd;

    // Interface instantiation
    asy_fifo_intf#(`FIFO_WIDTH) _if (clk_wr, clk_rd);

    // DUT instantiation
    asy_fifo#(`FIFO_WIDTH, `FIFO_DEPTH) u0 (
        .clk_wr(clk_wr),
        .clk_rd(clk_rd),
        .rst_n(_if.rst_n),
        .wr_data(_if.wr_data),
        .rd_data(_if.rd_data),
        .wr_en(_if.wr_en),
        .rd_en(_if.rd_en),
        .flag_full(_if.flag_full),
        .flag_empty(_if.flag_empty)
    );

    // Covergroups for different FIFO conditions and transitions
    covergroup fifo_cg;
        coverpoint u0.count {
            bins empty = {0};
            bins half_full = {`FIFO_DEPTH/2};
            bins full = {`FIFO_DEPTH};
            bins others[] = {[1:`FIFO_DEPTH-1]};
        }
        coverpoint u0.wr_en {
            bins write_pointer[] = {u0.wr_en};
        }
    endgroup: fifo_cg;

    covergroup full_cg;
        coverpoint u0.flag_full {
            bins full_true = {1'b1};
            bins full_false = {1'b0};
        }
    endgroup: full_cg;

    covergroup empty_cg;
        coverpoint u0.flag_empty {
            bins empty_true = {1'b1};
            bins empty_false = {1'b0};
        }
    endgroup: empty_cg;

    covergroup write_conditions_cg;
        coverpoint u0.wr_ptr {
            bins at_zero = {0};
            bins at_max = {`FIFO_DEPTH-1};
            bins at_middle = {`FIFO_DEPTH/2};
        }
    endgroup: write_conditions_cg;

    covergroup read_conditions_cg;
        coverpoint u0.rd_ptr {
            bins at_zero = {0};
            bins at_max = {`FIFO_DEPTH-1};
            bins at_middle = {`FIFO_DEPTH/2};
        }
    endgroup: read_conditions_cg;

    covergroup data_transitions_cg;
        data_sample: coverpoint u0.wr_data {
            bins range1 = {[0:(2^`FIFO_WIDTH)/2]};
            bins range2 = {[(2^`FIFO_WIDTH)/2:`FIFO_WIDTH]};
            bins range3[] = default;
        }
    endgroup: data_transitions_cg;

    // Covergroup instances
    fifo_cg cg = new;
    full_cg ful_cg = new();
    empty_cg ept_cg = new();
    write_conditions_cg wr_cg = new();
    read_conditions_cg rd_cg = new();
    data_transitions_cg dat_cg = new();

    // Assertions for FIFO properties
    property FIFO_FULL;
        @(u0.wr_en) (u0.count == `FIFO_DEPTH) |-> (u0.flag_full == 1);
    endproperty

    assert property (FIFO_FULL)
        else `uvm_error("TB_TOP", "FIFO full but flag not set");

    property FIFO_EMPTY;
        @(u0.rd_en) (u0.count == 0) |-> (u0.flag_empty == 1);
    endproperty

    assert property (FIFO_EMPTY)
        else `uvm_error("TB_TOP", "FIFO empty but flag not set");

    property FULL_and_EMPTY;
        @(posedge clk_wr or posedge clk_rd) !(u0.flag_full && u0.flag_empty);
    endproperty

    assert property (FULL_and_EMPTY)
        else `uvm_fatal("TB_TOP", "FIFO empty and full at the same time");
        
    property eventually_count_increases;
        @(posedge clk_wr) (u0.count == 0) |=> (u0.count == `FIFO_DEPTH);
    endproperty

    assert property (eventually_count_increases)
        else `uvm_error("TB_TOP", "did not transistion from 0 to full");
        
    property eventually_count_decreases;
        @(posedge clk_rd) (u0.count == `FIFO_DEPTH) |=> (u0.count == 0);
    endproperty

    assert property (eventually_count_decreases)
        else `uvm_error("TB_TOP", "did not transistion from full to");

    // Sampling covergroups
    always @(posedge clk_wr) begin
        fork
            cg.sample();
            dat_cg.sample();
        join
    end

    always @(u0.wr_en) begin
        fork
            ful_cg.sample();
            wr_cg.sample();
        join
    end

    always @(u0.rd_en) begin
        fork
            ept_cg.sample();
            rd_cg.sample();
        join
    end

    // Initial block for UVM configuration and test run
    initial begin
        clk_wr = 0;
        clk_rd = 0;
        uvm_config_db#(virtual asy_fifo_intf)::set(null, "uvm_test_top", "asy_fifo_intf", _if);
        run_test("base_test");
    end

    // Dumpvars for simulation
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars();
    end
    
    // FSDB dump for simulation
    initial begin
        $fsdbDumpfile("FIFO.fsdb");
        $fsdbDumpvars(0, tb);
    end
endmodule
