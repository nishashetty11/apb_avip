`ifndef MASTER_VIP_SLAVE_IP_VIRTUAL_8B_WRITE_SEQ_INCLUDED_
`define MASTER_VIP_SLAVE_IP_VIRTUAL_8B_WRITE_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: Master_VIP_Slave_IP_virtual_8b_write_seq
// Creates and starts the master and slave vd_vws sequnences of variable data and variable 
// wait states.
//--------------------------------------------------------------------------------------------
class Master_VIP_Slave_IP_virtual_8b_write_seq extends Master_VIP_Slave_IP_virtual_base_seq;
  `uvm_object_utils(Master_VIP_Slave_IP_virtual_8b_write_seq)

  //Variable: apb_master_8b_seq_h
  //Instatiation of apb_master_8b_write_seq
  apb_master_8b_write_seq apb_master_8b_write_seq_h;

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------

  extern function new(string name ="Master_VIP_Slave_IP_virtual_8b_write_seq");
  extern task body();

endclass : Master_VIP_Slave_IP_virtual_8b_write_seq
//--------------------------------------------------------------------------------------------
// Construct: new
//
// Parameters:
//  name - Master_VIP_Slave_IP_virtual_8b_write_seq
//--------------------------------------------------------------------------------------------

function Master_VIP_Slave_IP_virtual_8b_write_seq::new(string name ="Master_VIP_Slave_IP_virtual_8b_write_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task - body
// Creates and starts the 8bit data of master and slave sequences
//--------------------------------------------------------------------------------------------
task Master_VIP_Slave_IP_virtual_8b_write_seq::body();
  super.body();
  apb_master_8b_write_seq_h=apb_master_8b_write_seq::type_id::create("apb_master_8b_write_seq_h");
  
 
  fork
    begin: MASTER_WRITE_SEQ
      repeat(1) begin
          if(!apb_master_8b_write_seq_h.randomize() with {address_seq == 32'h008;
                                                                    }) begin
            `uvm_error(get_type_name(), "Randomization failed : Inside Master_VIP_Slave_IP_virtual_8b_write_seq.sv")
        end
        apb_master_8b_write_seq_h.start(p_sequencer.apb_master_seqr_h);
      end
    end

  join

 endtask : body

`endif
