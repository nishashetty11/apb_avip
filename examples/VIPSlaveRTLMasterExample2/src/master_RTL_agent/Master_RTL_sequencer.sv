`ifndef MASTER_RTL_SEQUENCER_INCLUDED_
`define MASTER_RTL_SEQUENCER_INCLUDED_


class Master_RTL_sequencer extends uvm_sequencer #(Master_RTL_tx);
  `uvm_component_utils(apb_master_sequencer)

 Master_RTL_agent_config apb_master_agent_cfg_h;

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "Master_RTL_sequencer", uvm_component parent);
 
endclass : Master_RTL_sequencer
 

function Master_RTL_sequencer::new(string name = "Master_RTL_sequencer",uvm_component parent);
  super.new(name,parent);
endfunction : new

`endif

