class fifo_full_seq extends uvm_sequence;
  `uvm_object_utils(fifo_full_seq)
  
  virtual asy_fifo_intf fifu_inf;
   
  function new(string name="fifo_full_seq");
      super.new(name);
   endfunction
      
   virtual task body();
     
     if (!uvm_config_db#(virtual asy_fifo_intf)::get(m_sequencer, "","dut_inf",fifu_inf))
       `uvm_fatal("FIFO_FULL_SEQ", "Could not get vif")
       `uvm_info("FIFO_FULL_SEQ", $sformatf("[STARTING FIFO_FULL SEQUENCE]"), UVM_LOW) 
       
       repeat(`FIFO_DEPTH+10) begin
         @(fifu_inf.drv_cb_wr);
         fifu_inf.drv_cb_wr.wr_en <= 1;
         fifu_inf.drv_cb_wr.wr_data <= $random();
       end
     `uvm_info("SEQ", $sformatf("[FIFO_FULL Sequence Done]"), UVM_LOW)
      
   endtask
endclass
