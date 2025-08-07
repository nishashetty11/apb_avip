`ifndef MASTER_VIP_SLAVE_IP_VIRTUAL_SEQ_PKG_INCLUDED_
`define MASTER_VIP_SLAVE_IP_VIRTUAL_SEQ_PKG_INCLUDED_


package Master_VIP_Slave_IP_virtual_seq_pkg;

  //-------------------------------------------------------
  // Importing UVM Pkg
  //-------------------------------------------------------
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import apb_global_pkg::*;
  import apb_env_pkg::*;
  import apb_master_pkg::*;
  import apb_slave_pkg::*;
  import apb_master_seq_pkg::*;
  import apb_slave_seq_pkg::*;

  //-------------------------------------------------------
  // Including required apb master seq files
  //-------------------------------------------------------
  `include "Master_VIP_Slave_IP_virtual_base_seq.sv"
  `include "Master_VIP_Slave_IP_virtual_8b_write_seq.sv"
  `include "Master_VIP_Slave_IP_virtual_8b_read_seq.sv"
  `include "Master_VIP_Slave_IP_virtual_8b_write_read_seq.sv"
  `include "Master_VIP_Slave_IP_virtual_16b_write_seq.sv"
endpackage : Master_VIP_Slave_IP_virtual_seq_pkg

`endif

