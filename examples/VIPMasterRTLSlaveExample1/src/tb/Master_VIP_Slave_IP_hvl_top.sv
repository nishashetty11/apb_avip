`ifndef MASTER_VIP_SLAVE_HVL_TOP_INCLUDED_
`define MASTER_VIP_SLAVE_HVL_TOP_INCLUDED_


module Master_VIP_Slave_IP_hvl_top;

  //-------------------------------------------------------
  // Importing UVM Package and test Package
  //-------------------------------------------------------
  import uvm_pkg::*;
  import Master_VIP_Slave_IP_test_pkg::*;
  
  //-------------------------------------------------------
  // Calling run_test for simulation
  //-------------------------------------------------------
  initial begin
    run_test("Master_VIP_Slave_IP_base_test");
  end

endmodule

`endif

