class fifo_empty_seq extends uvm_sequence;
  `uvm_object_utils(fifo_empty_seq)
  
  virtual asy_fifo_intf fifu_inf;
  
  function new(string name="fifo_empty_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    if (!uvm_config_db#(virtual asy_fifo_intf)::get(m_sequencer, "", "dut_inf", fifu_inf))
      `uvm_fatal("FIFO_EMPTY_SEQ", "Could not get vif");
      
    `uvm_info("FIFO_EMPTY_SEQ", $sformatf("[STARTING FIFO_EMPTY SEQUENCE]"), UVM_LOW);
    
    // Write to FIFO
    repeat(`FIFO_DEPTH) begin
      @(fifu_inf.drv_cb_wr);
      fifu_inf.drv_cb_wr.wr_en <= 1;
      fifu_inf.drv_cb_wr.wr_data <= $random();
    end
    fifu_inf.drv_cb_wr.wr_en <= 0;
    
    // Read from FIFO
    repeat(`FIFO_DEPTH + 12) begin
      @(fifu_inf.drv_cb_rd);
      fifu_inf.drv_cb_rd.rd_en <= 1;
    end
    
    `uvm_info("SEQ", $sformatf("[FIFO_EMPTY Sequence Done]"), UVM_LOW);
  endtask
endclass
