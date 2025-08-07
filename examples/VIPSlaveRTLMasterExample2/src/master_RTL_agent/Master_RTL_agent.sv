`ifndef MASTER_RTL_AGENT_INCLUDED_
`define MASTER_RTL_AGENT_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: Master_RTL_agent
//  This agent is a configurable with respect to configuration which can create active and passive components
//  It contains testbench components like sequencer,driver_proxy and monitor_proxy for APB
//--------------------------------------------------------------------------------------------
class Master_RTL_agent extends uvm_agent;
  `uvm_component_utils(Master_RTL_agent)

 Master_RTL_agent_config apb_master_agent_cfg_h;

 Master_RTL_sequencer apb_master_seqr_h;
  
 Master_RTL_driver apb_master_drv_h;

 Master_RTL_monitor apb_master_mon_h;

 //apb_master_coverage apb_master_cov_h;

 //apb_master_adapter apb_reg_adapter_h;
    
 extern function new(string name = "Master_RTL_agent", uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);

endclass : Master_RTL_agent

function Master_RTL_agent::new(string name="Master_RTL_agent", uvm_component parent);
  super.new(name,parent);
endfunction : new

function void Master_RTL_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);

  if(!uvm_config_db #(Master_RTL_agent_config)::get(this,"","Master_RTL_agent_config", apb_master_agent_cfg_h)) begin
    `uvm_fatal("FATAL_MA_CANNOT_GET_APB_MASTER_AGENT_CONFIG", "cannot get apb_master_agent_cfg_h from uvm_config_db");
  end

  if(apb_master_agent_cfg_h.is_active == UVM_ACTIVE) begin
    apb_master_drv_h=apb_master_driver_proxy::type_id::create("apb_master_drv_h",this);
    apb_master_seqr_h=apb_master_sequencer::type_id::create("apb_master_seqr_h",this);
  end

  apb_master_mon_h=apb_master_monitor_proxy::type_id::create("apb_master_mon_h",this);

/*  if(apb_master_agent_cfg_h.has_coverage) begin
    apb_master_cov_h = apb_master_coverage::type_id::create("apb_master_cov_h",this);
  end

  apb_reg_adapter_h = apb_master_adapter::type_id::create("apb_reg_adapter_h"); */
endfunction : build_phase

//--------------------------------------------------------------------------------------------
// Function: connect_phase 
// Connecting apb_master driver, apb_master monitor and apb_master sequencer for configuration
//
// Parameters:
// phase - uvm phase
//--------------------------------------------------------------------------------------------
function void Master_RTL_agent::connect_phase(uvm_phase phase);
  if(apb_master_agent_cfg_h.is_active == UVM_ACTIVE) begin
    apb_master_drv_h.apb_master_agent_cfg_h = apb_master_agent_cfg_h;
    apb_master_seqr_h.apb_master_agent_cfg_h = apb_master_agent_cfg_h;
    
    //Connecting driver_proxy port to sequencer export
    apb_master_drv_h.seq_item_port.connect(apb_master_seqr_h.seq_item_export);
  end
  apb_master_mon_h.apb_master_agent_cfg_h = apb_master_agent_cfg_h;
/*
  if(apb_master_agent_cfg_h.has_coverage) begin
    apb_master_cov_h.apb_master_agent_cfg_h = apb_master_agent_cfg_h;
  
    //Connecting monitor_proxy port to coverage export
    apb_master_mon_h.apb_master_analysis_port.connect(apb_master_cov_h.analysis_export);
  end
    apb_master_mon_h.apb_master_agent_cfg_h = apb_master_agent_cfg_h;
*/
endfunction : connect_phase

`endif

