`ifndef MASTER_VIP_SLAVE_IP_VIRTUAL_8B_WRITE_READ_SEQ_INCLUDED_
`define MASTER_VIP_SLAVE_IP_VIRTUAL_8B_WRITE_READ_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: Master_VIP_Slave_IP_virtual_8b_write_read_seq
//  Creates and starts the master and slave sequences
//--------------------------------------------------------------------------------------------
class Master_VIP_Slave_IP_virtual_8b_write_read_seq extends Master_VIP_Slave_IP_virtual_base_seq;
  `uvm_object_utils(Master_VIP_Slave_IP_virtual_8b_write_read_seq)

  //Variable: apb_master_8b_seq_h
  //Instatiation of apb_master_8b_write_seq
  apb_master_8b_write_seq apb_master_8b_write_seq_h;
  apb_master_8b_read_seq apb_master_8b_read_seq_h;

  //Variable: apb_slave_8b_write_seq_h
  //Instantiation of apb_master_8b_write_read_seq
  //-------------------------------------------------------
  extern function new(string name = "Master_VIP_Slave_IP_virtual_8b_write_read_seq");
  extern task body();

endclass : Master_VIP_Slave_IP_virtual_8b_write_read_seq

//--------------------------------------------------------------------------------------------
// Construct: new
//
// Parameters:
//  name - Master_VIP_Slave_IP_virtual_8b_write_read_seq
//--------------------------------------------------------------------------------------------
function Master_VIP_Slave_IP_virtual_8b_write_read_seq::new(string name = "Master_VIP_Slave_IP_virtual_8b_write_read_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task - body
//  Creates and starts the 8bit data of master and slave sequences
//--------------------------------------------------------------------------------------------
task Master_VIP_Slave_IP_virtual_8b_write_read_seq::body();
  super.body();

  // Create child sequences
  apb_master_8b_write_seq_h = apb_master_8b_write_seq::type_id::create("apb_master_8b_write_seq_h");
  apb_master_8b_read_seq_h  = apb_master_8b_read_seq ::type_id::create("apb_master_8b_read_seq_h");

  fork
    begin: MASTER_WRITE_SEQ
      repeat(1) begin
          if(!apb_master_8b_write_seq_h.randomize() with {address_seq == 32'h008;
                                                          cont_write_read_seq == 1;
                                                                    }) begin
            `uvm_error(get_type_name(), "Randomization failed : Inside apb_virtual_8b_write_read_seq.sv")
        end
        apb_master_8b_write_seq_h.start(p_sequencer.apb_master_seqr_h);
      end
    end

  begin: MASTER_READ_SEQ
      repeat(1) begin
          if(!apb_master_8b_read_seq_h.randomize() with {address_seq == 32'h008;
                                                         cont_write_read_seq == 1;
                                                                    }) begin
            `uvm_error(get_type_name(), "Randomization failed : Inside apb_virtual_8b_write_read_seq.sv")
        end
        apb_master_8b_read_seq_h.start(p_sequencer.apb_master_seqr_h);
      end
    end
  join



endtask : body




`endif
