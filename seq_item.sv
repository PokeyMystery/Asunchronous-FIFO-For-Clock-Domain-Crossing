class Item extends uvm_sequence_item;
   `uvm_object_utils(Item)
  rand bit [`FIFO_WIDTH-1:0] wr_data;
  rand bit wr_en;
  rand bit rd_en;
  bit rst_n;
  bit [`FIFO_WIDTH-1:0] rd_data;
  bit flag_full;
  bit flag_empty;
  
  
  
   virtual function string convert2str();
     return $sformatf("wr_data=%0d, wr_en=%0d, rd_en=%0d", wr_data, wr_en, rd_en);
   endfunction
   
   function new(string name = "Item");
      super.new(name);
   endfunction
   
endclass
