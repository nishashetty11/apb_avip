`ifndef MASTER_RTL_DRIVER_INCLUDED_
`define MASTER_RTL_DRIVER_INCLUDED_
    
class Master_RTL_driver extends uvm_driver #(Master_RTL_tx);
  `uvm_component_utils(Master_RTL_driver)
  
 Master_RTL_tx apb_master_tx_h;
  
  virtual Master_RTL_intf apb_master_intf_h;
   
  Master_RTL_agent_config apb_master_agent_cfg_h;

  extern function new(string name = "Master_RTL_driver", uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual function void end_of_elaboration_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);

endclass : Master_RTL_driver


function Master_RTL_driver::new(string name = "Master_RTL_driver",uvm_component parent);
  super.new(name, parent);
endfunction : new


function void Master_RTL_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db #(virtual Master_RTL_intf)::get(this,"","Master_RTL_intf", apb_master_intf_h)) begin
    `uvm_fatal("FATAL_MDP_CANNOT_GET_MASTER_RTL_INTF","cannot get() apb_master_intf_h");
  end
endfunction : build_phase


function void Master_RTL_driver::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
endfunction : connect_phase


function void Master_RTL_driver::end_of_elaboration_phase(uvm_phase phase);
  super.end_of_elaboration_phase(phase);
endfunction : end_of_elaboration_phase


task Master_RTL_driver::run_phase(uvm_phase phase);
 `uvm_info(get_type_name(),$sformatf("Inside run_phase Master_RTL_driver"),UVM_LOW);
  wait_for_preset_n();
  `uvm_info(get_type_name(),$sformatf("Inside run_phase after wait_for_preset_n Master_RTL_driver"),UVM_LOW);
  data_transfer();
  `uvm_info(get_type_name(),$sformatf("Inside run_phase after data_transfer Master_RTL_driver"),UVM_LOW);  
endtask :run_phase

task Master_RTL_driver::wait_for_preset_n();
    @(negedge apb_master_intf_h.preset_n);
    `uvm_info("MASTER_RTL_DRIVER",$sformatf("SYSTEM RESET DETECTED"),UVM_HIGH)
    @(posedge apb_master_intf_h.preset_n);
    `uvm_info("MASTER_RTL_DRIVER",$sformatf("SYSTEM RESET DEACTIVATED"),UVM_HIGH)
endtask : wait_for_preset_n

/*
  forever begin
    apb_transfer_char_s struct_packet;
    apb_transfer_cfg_s struct_cfg;

    seq_item_port.get_next_item(req);
    //Printing the req item
    `uvm_info(get_type_name(), $sformatf("REQ-MASTER_TX \n %s",req.sprint),UVM_HIGH);
  
    //Converting transaction to struct data_packet
    apb_master_seq_item_converter::from_class(req, struct_packet); 
    //Converting configurations to struct cfg_packet
    apb_master_cfg_converter::from_class(apb_master_agent_cfg_h, struct_cfg);
    //Calling the drive_to_bfm task in driver proxy
    apb_master_drv_bfm_h.drive_to_bfm(struct_packet,struct_cfg);
    //Converting struct to transaction
    apb_master_seq_item_converter::to_class(struct_packet, req);
    
    `uvm_info(get_type_name(), $sformatf("AFTER :: received req packet \n %s", req.sprint()), UVM_NONE); 
    seq_item_port.item_done();
  end

*/

task Master_RTL_driver::data_transfer();
  forever begin
   Master_RTL_tx master_tx; 
    `uvm_info(get_type_name(),$sformatf("Inside data_transfer before get_next_item Master_RTL_driver"),UVM_LOW);
     seq_item_port.get_next_item(master_req);
    `uvm_info(get_type_name(),$sformatf("Inside data_transfer after get_next_item Master_RTL_driver"),UVM_LOW);
     master_req.sprint();


      

`endif

