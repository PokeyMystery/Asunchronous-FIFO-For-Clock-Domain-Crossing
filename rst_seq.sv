class rst_seq extends uvm_sequence;
  `uvm_object_utils(rst_seq)
  
  virtual asy_fifo_intf r_inf;
  
  function new(string name="rst_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    if (!uvm_config_db#(virtual asy_fifo_intf)::get(m_sequencer, "", "des_vif", r_inf))
      `uvm_fatal("RST_SEQ", "Could not get vif");
      
    `uvm_info("RST_SEQ", $sformatf("[STARTING RESET SEQUENCE]"), UVM_LOW);
    
    // Assert reset
    r_inf.rst_n = 0;
    r_inf.wr_data = 0;
    r_inf.wr_en = 0;
    r_inf.rd_en = 0;
    
    // Deassert reset
    repeat(1) @(posedge r_inf.clk_wr);
    #2 r_inf.rst_n = 1;
    
    `uvm_info("SEQ", $sformatf("[RESET Sequence Done]"), UVM_LOW);
  endtask
endclass
