// APB4 Peripheral Module
// This module implements a simple register-based peripheral that responds to APB4 requests

module apb4_peripheral #(
    parameter PERIPHERAL_ID = 0,  // ID of this peripheral (0, 1, 2, etc.)
    parameter DATA_WIDTH = 32,    // Data width: 8, 16, or 32 bits
    parameter ADDR_WIDTH = 32     // Address width: 8, 16, 24, or 32 bits
) (
    // Clock and Reset
    input  wire        PCLK,
    input  wire        PRESETn,
    
    // APB4 Completer Interface (Inputs)
    input  wire [ADDR_WIDTH-1:0] PADDR,
    input  wire [2:0]  PPROT,
    input  wire        PSEL,  // Single bit select for this peripheral
    input  wire        PENABLE,
    input  wire        PWRITE,
    input  wire [DATA_WIDTH-1:0] PWDATA,
    input  wire [DATA_WIDTH/8-1:0] PSTRB,
    
    // APB4 Response Interface (Outputs)
    output reg  [DATA_WIDTH-1:0] PRDATA,
    output reg         PREADY,
    output reg         PSLVERR
);
    
    // Internal registers
    reg [DATA_WIDTH-1:0] control_reg;    // Control register at address 0x00
    reg [DATA_WIDTH-1:0] status_reg;     // Status register at address 0x04
    reg [DATA_WIDTH-1:0] data_reg;       // Data register at address 0x08
    reg [DATA_WIDTH-1:0] config_reg;     // Configuration register at address 0x0C
    
    // Address offset for this peripheral (each peripheral gets a 16-byte range)
    localparam ADDR_OFFSET = PERIPHERAL_ID * 16;
    
    // Register addresses (byte addresses) - offset by peripheral ID
    localparam CTRL_ADDR  = ADDR_OFFSET + {ADDR_WIDTH{1'b0}};
    localparam STATUS_ADDR = ADDR_OFFSET + 4;
    localparam DATA_ADDR   = ADDR_OFFSET + 8;
    localparam CONFIG_ADDR = ADDR_OFFSET + 12;
    
    // APB4 state machine states
    // Using standard Verilog instead of SystemVerilog typedef enum
    localparam IDLE = 2'b00;
    localparam SETUP = 2'b01;
    localparam ACCESS = 2'b10;
    
    reg [1:0] current_state, next_state;
    
    // State machine sequential logic
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    
    // State machine combinational logic - optimized
    always @(*) begin
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                if (PSEL && !PENABLE) begin
                    next_state = SETUP;
                end
            end
            
            SETUP: begin
                if (PSEL && PENABLE) begin
                    next_state = ACCESS;
                end else if (!PSEL) begin
                    next_state = IDLE;
                end
            end
            
            ACCESS: begin
                if (PREADY) begin
                    if (PSEL && !PENABLE) begin
                        next_state = SETUP;  // Back-to-back transfer
                    end else begin
                        next_state = IDLE;   // Single transfer or PSEL deasserted
                    end
                end
            end
        endcase
    end
    
    // Function for byte lane handling to eliminate code duplication
    function [DATA_WIDTH-1:0] handle_byte_lanes;
        input [DATA_WIDTH-1:0] data_in;
        input [DATA_WIDTH-1:0] data_current;
        input [DATA_WIDTH/8-1:0] strobe;
        reg [DATA_WIDTH-1:0] result;
        begin
            result = data_current; // Keep existing value by default
            if (DATA_WIDTH >= 8) begin
                if (strobe[0]) result[7:0] = data_in[7:0];
            end
            if (DATA_WIDTH >= 16) begin
                if (strobe[1]) result[15:8] = data_in[15:8];
            end
            if (DATA_WIDTH >= 24) begin
                if (strobe[2]) result[23:16] = data_in[23:16];
            end
            if (DATA_WIDTH >= 32) begin
                if (strobe[3]) result[31:24] = data_in[31:24];
            end
            handle_byte_lanes = result;
        end
    endfunction

    // Register read/write logic with parameterized byte strobe support
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            control_reg <= {DATA_WIDTH{1'b0}};
            status_reg  <= {DATA_WIDTH{1'b0}};
            data_reg    <= {DATA_WIDTH{1'b0}};
            config_reg  <= {DATA_WIDTH{1'b0}};
        end else begin
            // Write operations with parameterized byte strobe support
            if (current_state == ACCESS && PWRITE && PREADY) begin
                case (PADDR)
                    CTRL_ADDR:   control_reg <= handle_byte_lanes(PWDATA, control_reg, PSTRB);
                    STATUS_ADDR: status_reg <= handle_byte_lanes(PWDATA, status_reg, PSTRB);
                    DATA_ADDR:   data_reg <= handle_byte_lanes(PWDATA, data_reg, PSTRB);
                    CONFIG_ADDR: config_reg <= handle_byte_lanes(PWDATA, config_reg, PSTRB);
                endcase
            end
            
            // Status register auto-update (example: increment counter)
            if (control_reg[0]) begin  // Enable bit
                status_reg[DATA_WIDTH/2-1:0] <= status_reg[DATA_WIDTH/2-1:0] + 1;
            end
        end
    end
    
    // Read data multiplexer
    always @(*) begin
        PRDATA = {DATA_WIDTH{1'b0}};
        
        if (current_state == ACCESS && !PWRITE) begin
            case (PADDR)
                CTRL_ADDR:  PRDATA = control_reg;
                STATUS_ADDR: PRDATA = status_reg;
                DATA_ADDR:   PRDATA = data_reg;
                CONFIG_ADDR: PRDATA = config_reg;
                default:    PRDATA = {DATA_WIDTH{1'b1}};  // Invalid address - all ones
            endcase
        end
    end
    
    // Ready signal generation - optimized
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PREADY <= 1'b0;
        end else begin
            PREADY <= (current_state == ACCESS);  // Only ready in ACCESS state
        end
    end
    
    // Slave error signal - optimized
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PSLVERR <= 1'b0;
        end else begin
            // Drive PSLVERR LOW by default
            PSLVERR <= 1'b0;
            
            // Assert PSLVERR for invalid addresses in ACCESS phase
            if (current_state == ACCESS && PSEL && PENABLE) begin
                // Check if address is one of the valid addresses (CTRL_ADDR, STATUS_ADDR, DATA_ADDR, CONFIG_ADDR)
                if (PADDR != CTRL_ADDR && PADDR != STATUS_ADDR && PADDR != DATA_ADDR && PADDR != CONFIG_ADDR) begin
                    PSLVERR <= 1'b1;
                end
            end
        end
    end
    
endmodule 
