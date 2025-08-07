`ifndef APB_MASTER_AGENT_CONFIG_INCLUDED_
`define APB_MASTER_AGENT_CONFIG_INCLUDED_


class Master_RTL_agent_config extends uvm_object;
  `uvm_object_utils(Master_RTL_agent_config)

 uvm_active_passive_enum is_active = UVM_ACTIVE;  
 int no_of_slaves;
 bit has_coverage;

 bit [ADDRESS_WIDTH-1:0]paddr;

 bit [MEMORY_WIDTH-1:0]master_memory[(SLAVE_MEMORY_SIZE+SLAVE_MEMORY_GAP)*NO_OF_SLAVES:0];

 bit [ADDRESS_WIDTH-1:0]master_min_addr_range_array[int];

 bit [ADDRESS_WIDTH-1:0]master_max_addr_range_array[int];

  extern function new(string name = "Master_RTL_agent_config");
  extern function void do_print(uvm_printer printer);
  extern function void master_min_addr_range(int slave_number, bit [ADDRESS_WIDTH-1:0]slave_min_address_range);
  extern function void master_max_addr_range(int slave_number, bit [ADDRESS_WIDTH-1:0]slave_max_address_range);

endclass : Master_RTL_agent_config


function Master_RTL_agent_config::new(string name = "Master_RTL_agent_config");
  super.new(name);
endfunction : new


function void Master_RTL_agent_config::do_print(uvm_printer printer);
  super.do_print(printer);

  printer.print_field ("is_active",    is_active,    $bits(is_active),    UVM_DEC);
  printer.print_field ("has_coverage", has_coverage, $bits(has_coverage), UVM_DEC);
  printer.print_field ("no_of_slaves", no_of_slaves, $bits(no_of_slaves), UVM_DEC);
  foreach(master_max_addr_range_array[i]) begin
    printer.print_field($sformatf("master_min_addr_range_array[%0d]",i),master_min_addr_range_array[i],
                        $bits(master_min_addr_range_array[i]),UVM_HEX);
    printer.print_field($sformatf("master_max_addr_range_array[%0d]",i),master_max_addr_range_array[i],
                        $bits(master_max_addr_range_array[i]),UVM_HEX);
  end

endfunction : do_print


function void Master_RTL_agent_config::master_max_addr_range(int slave_number, bit[ADDRESS_WIDTH-1:0]slave_max_address_range);
  master_max_addr_range_array[slave_number] = slave_max_address_range;
endfunction : master_max_addr_range


function void Master_RTL_agent_config::master_min_addr_range(int slave_number, bit[ADDRESS_WIDTH-1:0]slave_min_address_range);
  master_min_addr_range_array[slave_number] = slave_min_address_range;
endfunction : master_min_addr_range

`endif

