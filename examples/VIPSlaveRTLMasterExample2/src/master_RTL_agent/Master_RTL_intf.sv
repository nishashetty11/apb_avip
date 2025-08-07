`ifndef MASTER_RTL_INTF_INCLUDED_
`define MASTER_RTL_INTF_INCLUDED_

import Master_RTL_global_pkg::*;
//import apb_global_pkg::*;
interface Master_RTL_intf (input pclk, input preset_n);
  
 logic [NO_OF_SLAVES-1:0]pselx;
 logic penable;  
 logic [ADDRESS_WIDTH-1:0]paddr;
 logic pwrite;
 logic [(DATA_WIDTH/8)-1:0]pstrb; 
 logic [DATA_WIDTH-1:0]pwdata;
 logic pready;
 logic [DATA_WIDTH-1:0]prdata;
 logic pslverr;
 logic [2:0]pprot; 
  
endinterface : Master_RTL_intf
 
`endif

