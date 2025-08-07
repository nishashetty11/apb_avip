`ifndef MASTER_VIP_SLAVE_IP_VIRTUAL_BASE_SEQ_INCLUDED_
`define MASTER_VIP_SLAVE_IP_VIRTUAL_BASE_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: Master_VIP_Slave_IP_virtual_base_seq
// Holds the handle of actual sequencer.
//--------------------------------------------------------------------------------------------
class Master_VIP_Slave_IP_virtual_base_seq extends uvm_sequence;
  `uvm_object_utils(Master_VIP_Slave_IP_virtual_base_seq)
  
  //Declaring p_sequencer
  `uvm_declare_p_sequencer(apb_virtual_sequencer)
  
  //Variable : apb_master_seqr_h
  //Declaring handle to the virtual sequencer
  apb_master_sequencer apb_master_seqr_h;

  //Variable : apb_master_seqr_h
  //Declaring handle to the virtual sequencer
  apb_slave_sequencer apb_slave_seqr_h[];

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "Master_VIP_Slave_IP_virtual_base_seq");
  extern task body();

endclass : Master_VIP_Slave_IP_virtual_base_seq

//--------------------------------------------------------------------------------------------
// Construct: new
//
// Parameters:
//  name - Master_VIP_Slave_IP_virtual_base_seq
//--------------------------------------------------------------------------------------------
function Master_VIP_Slave_IP_virtual_base_seq::new(string name = "Master_VIP_Slave_IP_virtual_base_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task : body
// Used to connect the master virtual seqr to master seqr
//
// Parameters:
//  name - Master_VIP_Slave_IP_virtual_base_seq
//--------------------------------------------------------------------------------------------
task Master_VIP_Slave_IP_virtual_base_seq::body();
  apb_slave_seqr_h = new[NO_OF_SLAVES];
  if(!$cast(p_sequencer,m_sequencer))begin
    `uvm_error(get_full_name(),"Virtual sequencer pointer cast failed")
  end
  foreach(apb_slave_seqr_h[i]) begin
    apb_slave_seqr_h[i]  = p_sequencer.apb_slave_seqr_h[i];
  end
  apb_master_seqr_h = p_sequencer.apb_master_seqr_h;

endtask : body

`endif

