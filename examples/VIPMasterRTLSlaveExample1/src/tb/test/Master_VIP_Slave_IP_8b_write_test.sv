`ifndef MASTER_VIP_SLAVE_IP_8B_WRITE_TEST_INCLUDED_
`define MASTER_VIP_SLAVE_IP_8B_WRITE_TEST_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: Master_VIP_Slave_IP_8b_write_test
// Extends the base test and starts the virtual sequence of 8 bit
//--------------------------------------------------------------------------------------------
class Master_VIP_Slave_IP_8b_write_test extends Master_VIP_Slave_IP_base_test;
  `uvm_component_utils(Master_VIP_Slave_IP_8b_write_test)
  
  //Variable: apb_virtual_8b_seq_h
  //Instatiation of apb_virtual_8b_seq
  Master_VIP_Slave_IP_virtual_8b_write_seq apb_virtual_8b_seq_h;

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "Master_VIP_Slave_IP_8b_write_test", uvm_component parent = null);
  extern virtual task run_phase(uvm_phase phase);

endclass : Master_VIP_Slave_IP_8b_write_test

//--------------------------------------------------------------------------------------------
// Construct: n
//
// Parameters:
//  name - Master_VIP_Slave_IP_8b_write_test
//  parent - parent under which this component is created
//--------------------------------------------------------------------------------------------
function Master_VIP_Slave_IP_8b_write_test::new(string name = "Master_VIP_Slave_IP_8b_write_test", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: run_phase
//  Creates the apb_virtual_8b_seq sequnce and starts the 8b virtual sequences
//
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
task Master_VIP_Slave_IP_8b_write_test::run_phase(uvm_phase phase);
  
  apb_virtual_8b_seq_h = Master_VIP_Slave_IP_virtual_8b_write_seq::type_id::create("apb_virtual_8b_seq_h");
  `uvm_info(get_type_name(),$sformatf("Master_VIP_Slave_IP_8b_write_test"),UVM_LOW);
  phase.raise_objection(this);
    apb_virtual_8b_seq_h.start(apb_env_h.apb_virtual_seqr_h);
  phase.drop_objection(this);

endtask : run_phase

`endif
