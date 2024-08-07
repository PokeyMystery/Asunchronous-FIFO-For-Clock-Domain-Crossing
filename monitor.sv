class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)
  
  function new(string name="monitor", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  uvm_analysis_port #(Item) mon_port_write;
  uvm_analysis_port #(Item) mon_port_read;
  virtual asy_fifo_intf vif;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual asy_fifo_intf)::get(this, "", "des_vif", vif))
      `uvm_fatal("MON", "Could not get vif")
    mon_port_write = new("mon_port_write", this);
    mon_port_read = new("mon_port_read", this);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork
      monitor_write();
      monitor_read();
    join
  endtask

  task monitor_write();
    forever begin
      @ (vif.mon_cb_wr);
      begin
      Item item = Item::type_id::create("item");			
      item.wr_data = vif.mon_cb_wr.wr_data;
      item.rst_n = vif.rst_n;
      item.wr_en = vif.mon_cb_wr.wr_en;
      item.flag_full = vif.mon_cb_wr.flag_full;
      mon_port_write.write(item);
      `uvm_info("MON", $sformatf("Saw item %s", item.convert2str()), UVM_HIGH)
      end
    end
  endtask

  task monitor_read();
    forever begin
      @ (vif.mon_cb_rd);
      begin
      Item item = Item::type_id::create("item");			
      item.rd_data = vif.mon_cb_rd.rd_data;
      item.rst_n = vif.rst_n;
      item.rd_en = vif.mon_cb_rd.rd_en;
      item.flag_empty = vif.mon_cb_rd.flag_empty;
      mon_port_read.write(item);
      `uvm_info("MON", $sformatf("Saw item %s", item.convert2str()), UVM_HIGH)
      end
    end
  endtask
endclass
