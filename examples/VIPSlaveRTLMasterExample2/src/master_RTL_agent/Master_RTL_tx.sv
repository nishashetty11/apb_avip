`ifndef MASTER_RTL_TX_INCLUDED_
`define MASTER_RTL_TX_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: Master_RTL_tx.
//  This class holds the data items required to drive stimulus to dut 
//  and also holds methods that manipulate those data items
//--------------------------------------------------------------------------------------------
 class Master_RTL_tx extends uvm_sequence_item;
  `uvm_object_utils(Master_RTL_tx)

 rand bit [ADDRESS_WIDTH-1:0] paddr;
 rand protection_type_e pprot;
 rand slave_no_e pselx;
 rand tx_type_e pwrite;
 rand transfer_size_e transfer_size;
 rand bit [DATA_WIDTH-1:0]pwdata;
 rand bit [(DATA_WIDTH/8)-1:0]pstrb;              
 bit [DATA_WIDTH-1:0]prdata;
 slave_error_e pslverr;
 apb_master_agent_config apb_master_agent_cfg_h;
 int no_of_wait_states_detected;
 rand bit cont_write_read;
 bit [ADDRESS_WIDTH-1:0]address;

 extern function new  (string name = "Master_RTL_tx");
 extern function void do_copy(uvm_object rhs);
 extern function bit  do_compare(uvm_object rhs, uvm_comparer comparer);
 extern function void do_print(uvm_printer printer);
 extern function void post_randomize();
                            }
endclass : Master_RTL_tx

//--------------------------------------------------------------------------------------------
// Construct: new
//  Initializes the class object
//
// Parameters:
//  name - Master_RTL_tx
//--------------------------------------------------------------------------------------------
function Master_RTL_tx::new(string name = "Master_RTL_tx");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Function: do_copy
//  Copy method is implemented using handle rhs
//
// Parameters:
//  rhs - uvm_object
//--------------------------------------------------------------------------------------------
function void Master_RTL_tx::do_copy (uvm_object rhs);
  Master_RTL_tx Master_RTL_tx_copy_obj;

  if(!$cast(Master_RTL_tx_copy_obj,rhs)) begin
    `uvm_fatal("do_copy","cast of the rhs object failed")
  end
  super.do_copy(rhs);

  paddr   = Master_RTL_tx_copy_obj.paddr;
  pprot   = Master_RTL_tx_copy_obj.pprot;
  pselx   = Master_RTL_tx_copy_obj.pselx;
  pwrite  = Master_RTL_tx_copy_obj.pwrite;
  pwdata  = Master_RTL_tx_copy_obj.pwdata;
  pstrb   = Master_RTL_tx_copy_obj.pstrb;
  prdata  = Master_RTL_tx_copy_obj.prdata;
  pslverr = Master_RTL_tx_copy_obj.pslverr;

endfunction : do_copy

//--------------------------------------------------------------------------------------------
// Function: do_compare
//  Compare method is implemented using handle rhs
//
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
function bit Master_RTL_tx::do_compare (uvm_object rhs, uvm_comparer comparer);
  Master_RTL_tx Master_RTL_tx_compare_obj;

  if(!$cast(Master_RTL_tx_compare_obj,rhs)) begin
    `uvm_fatal("FATAL_APB_MASTER_TX_DO_COMPARE_FAILED","cast of the rhs object failed")
    return 0;
  end

  return super.do_compare(Master_RTL_tx_compare_obj, comparer) &&
  paddr   == Master_RTL_tx_compare_obj.paddr &&
  pprot   == Master_RTL_tx_compare_obj.pprot &&
  pselx   == Master_RTL_tx_compare_obj.pselx &&
  pwrite  == Master_RTL_tx_compare_obj.pwrite &&
  pwdata  == Master_RTL_tx_compare_obj.pwdata &&
  pstrb   == Master_RTL_tx_compare_obj.pstrb &&
  prdata  == Master_RTL_tx_compare_obj.prdata &&
  pslverr == Master_RTL_tx_compare_obj.pslverr;

endfunction : do_compare

//--------------------------------------------------------------------------------------------
// Function: do_print method
//  Print method can be added to display the data members values
//
// Parameters:
//  printer - uvm_printer
//--------------------------------------------------------------------------------------------
function void Master_RTL_tx::do_print(uvm_printer printer);
  
  printer.print_string ("pselx",pselx.name());
  printer.print_field  ("paddr",paddr,$bits(paddr),UVM_HEX);
  printer.print_string ("pwrite",pwrite.name());
  printer.print_field  ("pwdata",pwdata,$bits(pwdata),UVM_HEX);
  printer.print_string ("transfer_size",transfer_size.name());
  printer.print_field  ("pstrb",pstrb,4,UVM_BIN);
  printer.print_string ("pprot",pprot.name());
  printer.print_field  ("prdata",prdata,$bits(prdata),UVM_HEX);
  printer.print_string ("pslverr",pslverr.name());
  printer.print_field  ("no_of_wait_states_detected", no_of_wait_states_detected, $bits(no_of_wait_states_detected), UVM_DEC);

endfunction : do_print

//--------------------------------------------------------------------------------------------
// Function : post_randomize
// Selects the address based on the slave selected
//--------------------------------------------------------------------------------------------
function void Master_RTL_tx::post_randomize();
  int index;

  // Derive the slave number using the index
  for(int i=0; i<NO_OF_SLAVES; i++) begin
    if(pselx[i]) begin
      index = i;
    end
  end
  
  // Randmoly chosing paddr value between a given range
  if (!std::randomize(paddr) with { paddr inside {[apb_master_agent_cfg_h.master_min_addr_range_array[index]:
                                                   apb_master_agent_cfg_h.master_max_addr_range_array[index]]};
    paddr %4 == 0;
  }) begin
    `uvm_fatal("FATAL_STD_RANDOMIZATION_PADDR", $sformatf("Not able to randomize paddr"));
  end

  //Constraint to make pwdata non-zero when pstrb is high for that 8-bit lane
  for(int i=0; i<DATA_WIDTH/8; i++) begin
    `uvm_info(get_type_name(),$sformatf("MASTER-TX-pstrb[%0d]=%0d",i,pstrb[i]),UVM_HIGH);
    if(pstrb[i]) begin
      `uvm_info(get_type_name(),$sformatf("MASTER-TX-pstrb[%0d]=%0d",i,pstrb[i]),UVM_HIGH);
      if(!std::randomize(pwdata) with {pwdata[8*i+7 -: 8] != 0;}) begin
        `uvm_fatal("FATAL_STD_RANDOMIZATION_PWDATA", $sformatf("Not able to randomize pwdata"));
      end
      else begin
        `uvm_info(get_type_name(),$sformatf("MASTER-TX-pwdata[%0d]=%0h",8*i+7,pwdata[8*i+7 +: 8]),UVM_HIGH);
      end 
    end
  end

endfunction : post_randomize

`endif

