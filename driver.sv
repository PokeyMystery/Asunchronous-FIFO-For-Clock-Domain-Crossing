class driver extends uvm_driver #(Item);              
  `uvm_component_utils(driver)
  
  function new(string name = "driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  virtual asy_fifo_intf vif;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual asy_fifo_intf)::get(this, "", "des_vif", vif))
      `uvm_fatal("DRV", "Could not get vif")
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      Item m_item;
      `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_HIGH)
      seq_item_port.get_next_item(m_item);
      fork
        drive_wr_item(m_item); 
        drive_rd_item(m_item); 
      join
      seq_item_port.item_done();
    end
  endtask
  
  virtual task drive_wr_item(Item m_item); 
    // `uvm_info("DRV", $sformatf("drive new item: %s", m_item.convert2str()), UVM_MEDIUM);
    @(vif.drv_cb_wr);
    if (!vif.flag_full) begin
      vif.drv_cb_wr.wr_en <= m_item.wr_en;
      vif.drv_cb_wr.wr_data <= m_item.wr_data; 
    end else begin
      vif.drv_cb_wr.wr_en <= 0;
    end
  endtask

  virtual task drive_rd_item(Item m_item); 
    @(vif.drv_cb_rd);
    if (!vif.flag_empty) begin
      vif.drv_cb_rd.rd_en <= m_item.rd_en; 
    end else begin
      vif.drv_cb_rd.rd_en <= 0; 
    end
  endtask
endclass
