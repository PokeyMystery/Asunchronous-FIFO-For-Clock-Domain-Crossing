class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)

  `uvm_analysis_imp_decl(_port1)
  `uvm_analysis_imp_decl(_port2)
  
  bit [`FIFO_WIDTH-1:0] expected_data_q [$];
  bit [`FIFO_WIDTH-1:0] actual_data_q [$];

  function new(string name="scoreboard", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  uvm_analysis_imp_port1 #(Item, scoreboard) m_analysis_imp_write;
  uvm_analysis_imp_port2 #(Item, scoreboard) m_analysis_imp_read;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_analysis_imp_write = new("m_analysis_imp_write", this);
    m_analysis_imp_read = new("m_analysis_imp_read", this);
  endfunction
  
  function void handle_write(bit [`FIFO_WIDTH-1:0] wr_data);
    if (expected_data_q.size() >= `FIFO_DEPTH) begin
      `uvm_info("SCB", "Write occurred with a full FIFO", UVM_LOW)
    end else begin
      expected_data_q.push_back(wr_data);
      `uvm_info("SCB", $sformatf("Write Data: %0d", wr_data), UVM_LOW)
    end
  endfunction

  function void handle_read(bit [`FIFO_WIDTH-1:0] rd_data);
    if (expected_data_q.size() == 0) begin
      `uvm_info("SCB", "Read occurred with empty expected data queue", UVM_HIGH)
    end else begin
      bit [`FIFO_WIDTH-1:0] expected = expected_data_q.pop_front();
      actual_data_q.push_back(rd_data);
      if (rd_data != expected) begin
        `uvm_error("SCB", $sformatf("Data mismatch: expected %0d, got %0d", expected, rd_data))
      end else begin
        `uvm_info("SCB", $sformatf("[PASS] Read Data: %0d, Expected Data: %0d", rd_data, expected), UVM_HIGH)
      end
    end
  endfunction

  virtual function void write_port1(Item item);
    if (item.rst_n) begin
      if (item.wr_en) begin
        handle_write(item.wr_data);
      end
      if (item.rd_en) begin
        handle_read(item.rd_data);
      end
    end else begin
      expected_data_q.delete();
      actual_data_q.delete();
      $display("Queue empty: %0d, %0d", expected_data_q.size(), actual_data_q.size());
    end
  endfunction

  virtual function void write_port2(Item item);
    if (item.rst_n) begin
      if (item.rd_en) begin
        handle_read(item.rd_data);
      end
    end else begin
      expected_data_q.delete();
      actual_data_q.delete();
      $display("Queue empty: %0d, %0d", expected_data_q.size(), actual_data_q.size());
    end
  endfunction
endclass
