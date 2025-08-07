`ifndef MASTER_VIP_SLAVE_IP_TEST_PKG_INCLUDED_
`define MASTER_VIP_SLAVE_IP_TEST_PKG_INCLUDED_

package Master_VIP_Slave_IP_test_pkg;

  // UVM
  `include "uvm_macros.svh"
  import uvm_pkg::*;

  // Project packages
  import apb_global_pkg::*;
  import apb_master_pkg::*;
  import apb_slave_pkg::*;
  import apb_env_pkg::*;
  import apb_master_seq_pkg::*;
  import apb_slave_seq_pkg::*;
  import Master_VIP_Slave_IP_virtual_seq_pkg::*;

  // Tests
  `include "Master_VIP_Slave_IP_base_test.sv"
  `include "Master_VIP_Slave_IP_8b_write_test.sv"
  `include "Master_VIP_Slave_IP_8b_read_test.sv"
  `include "Master_VIP_Slave_IP_8b_write_read_test.sv"
  `include "Master_VIP_Slave_IP_16b_write_test.sv"
endpackage : Master_VIP_Slave_IP_test_pkg

`endif

