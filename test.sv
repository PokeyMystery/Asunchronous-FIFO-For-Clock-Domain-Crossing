`include "package.sv"
class base_test extends uvm_test;
  `uvm_component_utils(base_test)
  function new(string name = "base_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  env  				e0;
  gen_item		seq;
  rst_seq r_seq;
  fifo_full_seq  fifu_seq;
  fifo_empty_seq fiep_seq;
  virtual  asy_fifo_intf vif;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    e0 = env::type_id::create("e0", this);
    
    if (!uvm_config_db#(virtual asy_fifo_intf)::get(this, "", "asy_fifo_intf", vif))
      `uvm_fatal("TEST", "Did not get vif")      
    uvm_config_db#(virtual asy_fifo_intf)::set(this, "e0.*", "des_vif", vif);
    
    seq = gen_item::type_id::create("seq");
    r_seq = rst_seq::type_id::create("r_seq");
    fifu_seq = fifo_full_seq::type_id::create("fifu_seq");
    fiep_seq = fifo_empty_seq::type_id::create("fiep_seq");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    r_seq.start(e0.a0.s0);
    fifu_seq.start(e0.a0.s0);
    r_seq.start(e0.a0.s0);
    fiep_seq.start(e0.a0.s0);
    r_seq.start(e0.a0.s0);
    seq.start(e0.a0.s0);
    #50;
    phase.drop_objection(this);
  endtask
  
endclass
