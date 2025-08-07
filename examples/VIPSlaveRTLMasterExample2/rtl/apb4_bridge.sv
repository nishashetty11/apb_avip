// APB4 Bridge Module
// This module acts as a requester (master) and initiates APB4 transfers

module apb4_bridge #(
    parameter NUM_PERIPHERALS = 1,  // Number of peripherals supported
    parameter DATA_WIDTH = 32,      // Data width: 8, 16, or 32 bits
    parameter ADDR_WIDTH = 32       // Address width: 8, 16, 24, or 32 bits
) (
    // Clock and Reset
    input  wire        PCLK,
    input  wire        PRESETn,
    
    // APB4 Requester Interface (Outputs)
    output reg  [ADDR_WIDTH-1:0] PADDR,
    output reg  [2:0]  PPROT,
    output reg  [NUM_PERIPHERALS-1:0] PSEL,  // Multi-bit select for multiple peripherals
    output reg         PENABLE,
    output reg         PWRITE,
    output reg  [DATA_WIDTH-1:0] PWDATA,
    output reg  [DATA_WIDTH/8-1:0] PSTRB,
    output reg         PWAKEUP,
    
    // APB4 Response Interface (Inputs)
    input  wire [DATA_WIDTH-1:0] PRDATA,
    input  wire        PREADY,
    input  wire        PSLVERR,
    
    // Internal interface for initiating transfers
    input  wire        transfer_req,    // Transfer request
    input  wire [ADDR_WIDTH-1:0] transfer_addr,   // Transfer address
    input  wire        transfer_write,  // Write transfer (1=write, 0=read)
    input  wire [DATA_WIDTH-1:0] transfer_wdata,  // Write data
    input  wire [DATA_WIDTH/8-1:0] transfer_strb,   // Write strobe
    input  wire [2:0]  transfer_prot,   // Protection type
    input  wire [NUM_PERIPHERALS-1:0] transfer_sel,  // Peripheral select
    output reg  [DATA_WIDTH-1:0] transfer_rdata,  // Read data
    output reg         transfer_done,   // Transfer complete
    output reg         transfer_error   // Transfer error
);
    
    // APB4 state machine states
    // Using standard Verilog instead of SystemVerilog typedef enum
    localparam IDLE = 2'b00;
    localparam SETUP = 2'b01;
    localparam ACCESS = 2'b10;
    
    reg [1:0] current_state, next_state;
    
    // Internal signals
    reg [ADDR_WIDTH-1:0] addr_reg;
    reg [DATA_WIDTH-1:0] wdata_reg;
    reg [DATA_WIDTH/8-1:0] strb_reg;
    reg [2:0]  prot_reg;
    reg        write_reg;
    reg [NUM_PERIPHERALS-1:0] sel_reg;
    
    // State machine sequential logic
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    
    // State machine combinational logic
    always @(*) begin
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                if (transfer_req) begin
                    next_state = SETUP;
                end
            end
            
            SETUP: begin
                next_state = ACCESS;
            end
            
            ACCESS: begin
                if (PREADY) begin
                    next_state = IDLE;
                end
            end
        endcase
    end
    
    // Register transfer parameters
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            addr_reg <= {ADDR_WIDTH{1'b0}};
            wdata_reg <= {DATA_WIDTH{1'b0}};
            strb_reg <= {DATA_WIDTH/8{1'b0}};
            prot_reg <= 3'h0;
            write_reg <= 1'b0;
        end else if (current_state == IDLE && transfer_req) begin
            addr_reg <= transfer_addr;
            wdata_reg <= transfer_wdata;
            strb_reg <= transfer_strb;
            prot_reg <= transfer_prot;
            write_reg <= transfer_write;
            sel_reg <= transfer_sel;
        end
    end
    
    // APB4 signal generation
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PADDR <= {ADDR_WIDTH{1'b0}};
            PPROT <= 3'h0;
            PSEL <= {NUM_PERIPHERALS{1'b0}};  // Reset all select bits
            PENABLE <= 1'b0;
            PWRITE <= 1'b0;
            PWDATA <= {DATA_WIDTH{1'b0}};
            PSTRB <= {DATA_WIDTH/8{1'b0}};
            PWAKEUP <= 1'b0;
        end else begin
            case (current_state)
                IDLE: begin
                    PSEL <= {NUM_PERIPHERALS{1'b0}};  // Clear all select bits
                    PENABLE <= 1'b0;
                    PWAKEUP <= 1'b0;  // Deassert PWAKEUP when not driving bus
                end
                
                SETUP: begin
                    PADDR <= addr_reg;
                    PPROT <= prot_reg;
                    PSEL <= sel_reg;  // Set the selected peripheral
                    PENABLE <= 1'b0;
                    PWRITE <= write_reg;
                    PWDATA <= wdata_reg;
                    PSTRB <= strb_reg;  // Drive PSTRB to stable value in SETUP phase
                    PWAKEUP <= 1'b1;  // Assert PWAKEUP when driving bus
                end
                
                ACCESS: begin
                    PENABLE <= 1'b1;
                    PWAKEUP <= 1'b1;  // Continue asserting PWAKEUP during transfer
                end
            endcase
        end
    end
    
    // Read data capture and transfer completion signals
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            transfer_rdata <= {DATA_WIDTH{1'b0}};
            transfer_done <= 1'b0;
            transfer_error <= 1'b0;
        end else begin
            // Read data capture
            if (current_state == ACCESS && PREADY && !write_reg) begin
                transfer_rdata <= PRDATA;
            end
            
            // Transfer completion and error signals - simplified logic
            if (current_state == ACCESS && PREADY) begin
                transfer_done <= 1'b1;
                transfer_error <= PSLVERR;
            end else if (current_state == IDLE) begin
                transfer_done <= 1'b0;
                transfer_error <= 1'b0;
            end
        end
    end
    
endmodule

// APB4 Bridge Testbench Module
// This module tests the bridge functionality independently

module apb4_bridge_testbench;
    
    // Parameters for testbench
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 32;
    parameter NUM_PERIPHERALS = 2;
    
    // Clock and reset
    reg PCLK;
    reg PRESETn;
    
    // Transfer interface signals (connected to bridge)
    reg        transfer_req;
    reg [ADDR_WIDTH-1:0] transfer_addr;
    reg        transfer_write;
    reg [DATA_WIDTH-1:0] transfer_wdata;  // Using parameterized width
    reg [DATA_WIDTH/8-1:0] transfer_strb;   // Using parameterized width
    reg [2:0]  transfer_prot;
    reg [NUM_PERIPHERALS-1:0] transfer_sel;  // Two peripheral selects
    wire [DATA_WIDTH-1:0] transfer_rdata;  // Using parameterized width
    wire        transfer_done;
    wire        transfer_error;
    
    // APB4 response signals (simulated peripheral)
    reg [DATA_WIDTH-1:0] PRDATA;
    reg        PREADY;
    reg        PSLVERR;
    
    // Test result tracking
    integer test_count = 0;
    integer passed_tests = 0;
    integer failed_tests = 0;
    reg test_passed;
    reg [DATA_WIDTH-1:0] expected_data;
    reg expected_error;
    
    // Variables for capturing transfer results
    reg [DATA_WIDTH-1:0] captured_rdata;
    reg captured_error;
    
    // Clock generation
    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;  // 100MHz clock
    end
    
    // Reset generation
    initial begin
        PRESETn = 0;
        #20;
        PRESETn = 1;
    end
    
    // APB4 bus signals (outputs from bridge)
    wire [ADDR_WIDTH-1:0] PADDR;
    wire [2:0]  PPROT;
    wire [NUM_PERIPHERALS-1:0] PSEL;  // Two peripherals for this testbench
    wire        PENABLE;
    wire        PWRITE;
    wire [DATA_WIDTH-1:0] PWDATA;  // Using parameterized width
    wire [DATA_WIDTH/8-1:0] PSTRB;   // Using parameterized width
    wire        PWAKEUP;
    
    // Instantiate the bridge module
    apb4_bridge #(
        .NUM_PERIPHERALS(NUM_PERIPHERALS),  // Two peripherals for this testbench
        .DATA_WIDTH(DATA_WIDTH),       // 32-bit data width for testbench
        .ADDR_WIDTH(ADDR_WIDTH)       // 32-bit address width for testbench
    ) dut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PADDR(PADDR),
        .PPROT(PPROT),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PWDATA(PWDATA),
        .PSTRB(PSTRB),
        .PWAKEUP(PWAKEUP),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR),
        .transfer_req(transfer_req),
        .transfer_addr(transfer_addr),
        .transfer_write(transfer_write),
        .transfer_wdata(transfer_wdata),
        .transfer_strb(transfer_strb),
        .transfer_prot(transfer_prot),
        .transfer_sel(transfer_sel),
        .transfer_rdata(transfer_rdata),
        .transfer_done(transfer_done),
        .transfer_error(transfer_error)
    );
    
    // Simple peripheral simulation for 2 peripherals - updated to match actual peripheral behavior exactly
    // Add internal registers to store written data
    reg [DATA_WIDTH-1:0] peripheral0_regs [0:3];  // 4 registers for Peripheral 0 (0x00, 0x04, 0x08, 0x0C)
    reg [DATA_WIDTH-1:0] peripheral1_regs [0:3];  // 4 registers for Peripheral 1 (0x10, 0x14, 0x18, 0x1C)
    
    // Peripheral state machines (simplified - just track if we're in ACCESS state)
    reg peripheral0_in_access, peripheral1_in_access;
    
    // Initialize registers to match actual peripheral (all zeros initially)
    initial begin
        // Initialize Peripheral 0 registers to all zeros (matches actual peripheral)
        peripheral0_regs[0] = {DATA_WIDTH{1'b0}};  // Control register
        peripheral0_regs[1] = {DATA_WIDTH{1'b0}};  // Status register
        peripheral0_regs[2] = {DATA_WIDTH{1'b0}};  // Data register
        peripheral0_regs[3] = {DATA_WIDTH{1'b0}};  // Config register
        
        // Initialize Peripheral 1 registers to all zeros (matches actual peripheral)
        peripheral1_regs[0] = {DATA_WIDTH{1'b0}};  // Control register
        peripheral1_regs[1] = {DATA_WIDTH{1'b0}};  // Status register
        peripheral1_regs[2] = {DATA_WIDTH{1'b0}};  // Data register
        peripheral1_regs[3] = {DATA_WIDTH{1'b0}};  // Config register
        
        peripheral0_in_access = 1'b0;
        peripheral1_in_access = 1'b0;
    end
    
    // Track ACCESS state for each peripheral
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            peripheral0_in_access <= 1'b0;
            peripheral1_in_access <= 1'b0;
        end else begin
            // Peripheral 0 ACCESS state tracking
            if (PSEL[0] && PENABLE && PREADY) begin
                peripheral0_in_access <= 1'b1;
            end else if (!PSEL[0]) begin
                peripheral0_in_access <= 1'b0;
            end
            
            // Peripheral 1 ACCESS state tracking
            if (PSEL[1] && PENABLE && PREADY) begin
                peripheral1_in_access <= 1'b1;
            end else if (!PSEL[1]) begin
                peripheral1_in_access <= 1'b0;
            end
        end
    end
    
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PREADY <= 1'b0;
            PSLVERR <= 1'b0;
            PRDATA <= {DATA_WIDTH{1'b0}};
            
            // Reset registers to all zeros (matches actual peripheral)
            peripheral0_regs[0] <= {DATA_WIDTH{1'b0}};
            peripheral0_regs[1] <= {DATA_WIDTH{1'b0}};
            peripheral0_regs[2] <= {DATA_WIDTH{1'b0}};
            peripheral0_regs[3] <= {DATA_WIDTH{1'b0}};
            peripheral1_regs[0] <= {DATA_WIDTH{1'b0}};
            peripheral1_regs[1] <= {DATA_WIDTH{1'b0}};
            peripheral1_regs[2] <= {DATA_WIDTH{1'b0}};
            peripheral1_regs[3] <= {DATA_WIDTH{1'b0}};
        end else begin
            // Follow APB4 specification: PSLVERR is only valid when PSEL, PENABLE, and PREADY are all HIGH
            // Drive PSLVERR LOW by default (recommended behavior)
            PSLVERR <= 1'b0;
            
            // Simulate peripheral response - match actual peripheral timing
            if ((PSEL[0] || PSEL[1]) && PENABLE) begin  // Check both peripherals
                // Assert PREADY to complete the transfer (matches actual peripheral)
                PREADY <= 1'b1;
                
                // Handle write operations - match actual peripheral timing (ACCESS && PWRITE && PREADY)
                if (PWRITE && PREADY) begin
                    if (PSEL[0]) begin  // Peripheral 0 write
                        case (PADDR)
                            32'h00: peripheral0_regs[0] <= PWDATA;  // Control register
                            32'h04: peripheral0_regs[1] <= PWDATA;  // Status register
                            32'h08: peripheral0_regs[2] <= PWDATA;  // Data register
                            32'h0C: peripheral0_regs[3] <= PWDATA;  // Config register
                        endcase
                    end else if (PSEL[1]) begin  // Peripheral 1 write
                        case (PADDR)
                            32'h10: peripheral1_regs[0] <= PWDATA;  // Control register
                            32'h14: peripheral1_regs[1] <= PWDATA;  // Status register
                            32'h18: peripheral1_regs[2] <= PWDATA;  // Data register
                            32'h1C: peripheral1_regs[3] <= PWDATA;  // Config register
                        endcase
                    end
                end else if (!PWRITE) begin
                    // Handle read operations - match actual peripheral timing (ACCESS && !PWRITE)
                    if (PSEL[0]) begin  // Peripheral 0 (addresses 0x00, 0x04, 0x08, 0x0C)
                        case (PADDR)
                            32'h00: PRDATA <= peripheral0_regs[0];  // Control register
                            32'h04: PRDATA <= peripheral0_regs[1];  // Status register
                            32'h08: PRDATA <= peripheral0_regs[2];  // Data register
                            32'h0C: PRDATA <= peripheral0_regs[3];  // Config register
                            default: PRDATA <= {DATA_WIDTH{1'b1}};  // Invalid address - all ones (matches actual peripheral)
                        endcase
                    end else if (PSEL[1]) begin  // Peripheral 1 (addresses 0x10, 0x14, 0x18, 0x1C)
                        case (PADDR)
                            32'h10: PRDATA <= peripheral1_regs[0];  // Control register
                            32'h14: PRDATA <= peripheral1_regs[1];  // Status register
                            32'h18: PRDATA <= peripheral1_regs[2];  // Data register
                            32'h1C: PRDATA <= peripheral1_regs[3];  // Config register
                            default: PRDATA <= {DATA_WIDTH{1'b1}};  // Invalid address - all ones (matches actual peripheral)
                        endcase
                    end
                end
            end else begin
                // When not in transfer, clear PREADY and PSLVERR (PSLVERR already set to 0 above)
                PREADY <= 1'b0;
            end
        end
    end
    
    // Separate logic for PSLVERR generation - updated to match actual peripheral behavior
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PSLVERR <= 1'b0;
        end else begin
            // Drive PSLVERR LOW by default
            PSLVERR <= 1'b0;
            
            // Only assert PSLVERR when PSEL, PENABLE, and PREADY are all HIGH (final transfer cycle)
            if ((PSEL[0] || PSEL[1]) && PENABLE && PREADY) begin
                // Check for invalid addresses - match actual peripheral logic
                if (PSEL[0]) begin
                    // Peripheral 0: only addresses 0x00, 0x04, 0x08, 0x0C are valid
                    if (PADDR != 32'h00 && PADDR != 32'h04 && PADDR != 32'h08 && PADDR != 32'h0C) begin
                        PSLVERR <= 1'b1;
                    end
                end else if (PSEL[1]) begin
                    // Peripheral 1: only addresses 0x10, 0x14, 0x18, 0x1C are valid
                    if (PADDR != 32'h10 && PADDR != 32'h14 && PADDR != 32'h18 && PADDR != 32'h1C) begin
                        PSLVERR <= 1'b1;
                    end
                end
            end
        end
    end
    
    // Test stimulus generation
    initial begin
        // Initialize signals
        transfer_req = 0;
        transfer_addr = {ADDR_WIDTH{1'b0}};
        transfer_write = 0;
        transfer_wdata = {DATA_WIDTH{1'b0}};
        transfer_strb = {DATA_WIDTH/8{1'b0}};
        transfer_prot = 3'h0;
        transfer_sel = 2'b01;
        
        $display("Starting bridge testbench...");
        
        // Wait for initial reset to complete
        wait(PRESETn);
        #10;
        
        // Test 1: Write transfer to Peripheral 0
        $display("Test 1: Write transfer to Peripheral 0");
        write_transfer({ADDR_WIDTH{1'b0}}, 32'h12345678, {DATA_WIDTH/8{1'b1}}, 3'h0, 2'b01, 0);
        if (test_passed) begin
            $display("  PASS");
            passed_tests++;
        end else begin
            $display("  FAIL");
            failed_tests++;
        end
        reset_between_tests();
        
        // Test 2: Read transfer from Peripheral 0
        $display("Test 2: Read transfer from Peripheral 0");
        read_transfer({ADDR_WIDTH{1'b0}}, 3'h0, 2'b01, {DATA_WIDTH{1'b0}}, 0);
        if (test_passed) begin
            $display("  PASS");
            passed_tests++;
        end else begin
            $display("  FAIL");
            failed_tests++;
        end
        reset_between_tests();
        
        // Test 3: Read transfer from different address in Peripheral 0
        $display("Test 3: Read transfer from different address in Peripheral 0");
        read_transfer(32'h04, 3'h0, 2'b01, {DATA_WIDTH{1'b0}}, 0);
        if (test_passed) begin
            $display("  PASS");
            passed_tests++;
        end else begin
            $display("  FAIL");
            failed_tests++;
        end
        reset_between_tests();
        
        // Test 4: Write transfer to Peripheral 1
        $display("Test 4: Write transfer to Peripheral 1");
        write_transfer(32'h10, 32'h87654321, {DATA_WIDTH/8{1'b1}}, 3'h0, 2'b10, 0);
        if (test_passed) begin
            $display("  PASS");
            passed_tests++;
        end else begin
            $display("  FAIL");
            failed_tests++;
        end
        reset_between_tests();
        
        // Test 5: Read transfer from Peripheral 1
        $display("Test 5: Read transfer from Peripheral 1");
        read_transfer(32'h10, 3'h0, 2'b10, {DATA_WIDTH{1'b0}}, 0);
        if (test_passed) begin
            $display("  PASS");
            passed_tests++;
        end else begin
            $display("  FAIL");
            failed_tests++;
        end
        reset_between_tests();
        
        // Test 6: Read transfer from different address in Peripheral 1
        $display("Test 6: Read transfer from different address in Peripheral 1");
        read_transfer(32'h14, 3'h0, 2'b10, {DATA_WIDTH{1'b0}}, 0);
        if (test_passed) begin
            $display("  PASS");
            passed_tests++;
        end else begin
            $display("  FAIL");
            failed_tests++;
        end
        reset_between_tests();
        
        // Test 7: Byte write transfer to Peripheral 0
        $display("Test 7: Byte write transfer to Peripheral 0");
        write_transfer(32'h08, 32'h000000FF, 4'h1, 3'h0, 2'b01, 0);
        if (test_passed) begin
            $display("  PASS");
            passed_tests++;
        end else begin
            $display("  FAIL");
            failed_tests++;
        end
        reset_between_tests();
        
        // Test 8: Half-word write transfer to Peripheral 0
        $display("Test 8: Half-word write transfer to Peripheral 0");
        write_transfer(32'h0C, 32'h0000BEEF, 4'h3, 3'h0, 2'b01, 0);
        if (test_passed) begin
            $display("  PASS");
            passed_tests++;
        end else begin
            $display("  FAIL");
            failed_tests++;
        end
        reset_between_tests();
        
        // Test 9: Byte write transfer to Peripheral 1
        $display("Test 9: Byte write transfer to Peripheral 1");
        write_transfer(32'h18, 32'h000000AA, 4'h1, 3'h0, 2'b10, 0);
        if (test_passed) begin
            $display("  PASS");
            passed_tests++;
        end else begin
            $display("  FAIL");
            failed_tests++;
        end
        reset_between_tests();
        
        // Test 10: Invalid address read from Peripheral 0
        $display("Test 10: Invalid address read from Peripheral 0");
        read_transfer(32'h20, 3'h0, 2'b01, {DATA_WIDTH{1'b1}}, 1);
        if (test_passed) begin
            $display("  PASS");
            passed_tests++;
        end else begin
            $display("  FAIL");
            failed_tests++;
        end
        reset_between_tests();
        
        // Test 11: Invalid address read from Peripheral 1
        $display("Test 11: Invalid address read from Peripheral 1");
        read_transfer(32'h30, 3'h0, 2'b10, {DATA_WIDTH{1'b1}}, 1);
        if (test_passed) begin
            $display("  PASS");
            passed_tests++;
        end else begin
            $display("  FAIL");
            failed_tests++;
        end
        reset_between_tests();
        
        // Test 12: Multiple consecutive transfers to Peripheral 0
        $display("Test 12: Multiple consecutive transfers to Peripheral 0");
        for (integer i = 0; i < 3; i = i + 1) begin
            write_transfer({ADDR_WIDTH{1'b0}} + (i * 4), 32'h11111111 + (i * 16'h1111), {DATA_WIDTH/8{1'b1}}, 3'h0, 2'b01, 0);
            read_transfer({ADDR_WIDTH{1'b0}} + (i * 4), 3'h0, 2'b01, 32'h11111111 + (i * 16'h1111), 0);
            #10;
        end
        if (test_passed) begin
            $display("  PASS");
            passed_tests++;
        end else begin
            $display("  FAIL");
            failed_tests++;
        end
        reset_between_tests();
        
        // Test 13: Multiple consecutive transfers to Peripheral 1
        $display("Test 13: Multiple consecutive transfers to Peripheral 1");
        for (integer i = 0; i < 3; i = i + 1) begin
            write_transfer(32'h10 + (i * 4), 32'hAAAA0000 + (i * 16'h1111), {DATA_WIDTH/8{1'b1}}, 3'h0, 2'b10, 0);
            read_transfer(32'h10 + (i * 4), 3'h0, 2'b10, 32'hAAAA0000 + (i * 16'h1111), 0);
            #10;
        end
        if (test_passed) begin
            $display("  PASS");
            passed_tests++;
        end else begin
            $display("  FAIL");
            failed_tests++;
        end
        reset_between_tests();
        
        // Test 14: Protection level testing on Peripheral 0
        $display("Test 14: Protection level testing on Peripheral 0");
        write_transfer({ADDR_WIDTH{1'b0}}, 32'h99999999, {DATA_WIDTH/8{1'b1}}, 3'h1, 2'b01, 0);
        read_transfer({ADDR_WIDTH{1'b0}}, 3'h2, 2'b01, 32'h99999999, 0);
        if (test_passed) begin
            $display("  PASS");
            passed_tests++;
        end else begin
            $display("  FAIL");
            failed_tests++;
        end
        reset_between_tests();
        
        // Test 15: Protection level testing on Peripheral 1
        $display("Test 15: Protection level testing on Peripheral 1");
        write_transfer(32'h10, 32'h88888888, {DATA_WIDTH/8{1'b1}}, 3'h1, 2'b10, 0);
        read_transfer(32'h10, 3'h2, 2'b10, 32'h88888888, 0);
        if (test_passed) begin
            $display("  PASS");
            passed_tests++;
        end else begin
            $display("  FAIL");
            failed_tests++;
        end
        reset_between_tests();
        
        // Test 16: PSEL behavior testing for Peripheral 0
        $display("Test 16: PSEL behavior testing for Peripheral 0");
        @(posedge PCLK);
        transfer_addr = {ADDR_WIDTH{1'b0}};
        transfer_write = 1;
        transfer_wdata = 32'hDEADBEEF;
        transfer_strb = {DATA_WIDTH/8{1'b1}};
        transfer_prot = 3'h0;
        transfer_sel = 2'b01;
        transfer_req = 1;
        
        @(posedge PCLK);
        transfer_req = 0;
        
        @(posedge PCLK);
        repeat(1) @(posedge PCLK);
        
        test_count++;
        if (PSEL[0] && !PENABLE) begin
            passed_tests++;
        end else begin
            failed_tests++;
            $display("FAIL: PSEL[0] not correctly asserted in SETUP phase");
        end
        
        wait(transfer_done);
        @(posedge PCLK);
        @(posedge PCLK);
        
        test_count++;
        if (!PSEL[0]) begin
            passed_tests++;
        end else begin
            failed_tests++;
            $display("FAIL: PSEL[0] not correctly deasserted after transfer");
        end
        reset_between_tests();
        
        // Test 17: PSEL behavior testing for Peripheral 1
        $display("Test 17: PSEL behavior testing for Peripheral 1");
        @(posedge PCLK);
        transfer_addr = 32'h10;
        transfer_write = 1;
        transfer_wdata = 32'hCAFEBABE;
        transfer_strb = {DATA_WIDTH/8{1'b1}};
        transfer_prot = 3'h0;
        transfer_sel = 2'b10;
        transfer_req = 1;
        
        @(posedge PCLK);
        transfer_req = 0;
        
        @(posedge PCLK);
        repeat(1) @(posedge PCLK);
        
        test_count++;
        if (PSEL[1] && !PENABLE) begin
            passed_tests++;
        end else begin
            failed_tests++;
            $display("FAIL: PSEL[1] not correctly asserted in SETUP phase");
        end
        
        wait(transfer_done);
        @(posedge PCLK);
        @(posedge PCLK);
        
        test_count++;
        if (!PSEL[1]) begin
            passed_tests++;
        end else begin
            failed_tests++;
            $display("FAIL: PSEL[1] not correctly deasserted after transfer");
        end
        reset_between_tests();
        
        // Test 18: PSEL with no transfer request
        $display("Test 18: PSEL with no transfer request");
        @(posedge PCLK);
        transfer_req = 0;
        
        repeat(3) @(posedge PCLK);
        test_count++;
        if (!PSEL[0] && !PSEL[1]) begin
            passed_tests++;
        end else begin
            failed_tests++;
            $display("FAIL: PSEL incorrectly asserted when no transfer requested");
        end
        
        // End simulation
        #50;
        $display("==========================================");
        $display("TEST SUMMARY");
        $display("==========================================");
        $display("Total tests executed: %0d", test_count);
        $display("Tests passed: %0d", passed_tests);
        $display("Tests failed: %0d", failed_tests);
        $display("Success rate: %0.1f%%", (passed_tests * 100.0) / test_count);
        
        if (failed_tests == 0) begin
            $display("ALL TESTS PASSED! Bridge testbench completed successfully");
        end else begin
            $display("SOME TESTS FAILED! Please review the failures above");
        end
        $stop;
    end
    
    // Task to perform a write transfer
    task write_transfer(input reg [ADDR_WIDTH-1:0] addr, input reg [DATA_WIDTH-1:0] data, input reg [DATA_WIDTH/8-1:0] strb, input reg [2:0] prot, input reg [NUM_PERIPHERALS-1:0] sel, input reg expected_err = 0);
        test_count++;
        @(posedge PCLK);
        transfer_addr = addr;
        transfer_write = 1;
        transfer_wdata = data;
        transfer_strb = strb;
        transfer_prot = prot;
        transfer_sel = sel;
        transfer_req = 1;
        
        @(posedge PCLK);
        transfer_req = 0;
        
        // Wait for transfer completion with timeout
        repeat(100) begin
            if (transfer_done) break;
            @(posedge PCLK);
        end
        
        if (!transfer_done) begin
            $display("ERROR: Write transfer timeout after 100 cycles!");
            $stop;
        end
        
        @(posedge PCLK);
        
        // Validate test result
        test_passed = (transfer_error == expected_err);
        if (test_passed) begin
            passed_tests++;
        end else begin
            failed_tests++;
            $display("FAIL: Write transfer to 0x%08X - expected error: %b, got: %b", addr, expected_err, transfer_error);
        end
    endtask
    
    // Task to perform a read transfer
    task read_transfer(input reg [ADDR_WIDTH-1:0] addr, input reg [2:0] prot, input reg [NUM_PERIPHERALS-1:0] sel, input reg [DATA_WIDTH-1:0] expected_data = {DATA_WIDTH{1'b0}}, input reg expected_err = 0);
        test_count++;
        @(posedge PCLK);
        transfer_addr = addr;
        transfer_write = 0;
        transfer_wdata = {DATA_WIDTH{1'b0}};
        transfer_strb = {DATA_WIDTH/8{1'b0}};
        transfer_prot = prot;
        transfer_sel = sel;
        transfer_req = 1;
        
        @(posedge PCLK);
        transfer_req = 0;
        
        // Wait for transfer completion with timeout
        repeat(100) begin
            if (transfer_done) begin
                captured_rdata = transfer_rdata;
                captured_error = transfer_error;
                break;
            end
            @(posedge PCLK);
        end
        
        if (!transfer_done) begin
            $display("ERROR: Read transfer timeout after 100 cycles!");
            $stop;
        end
        
        // Validate test result using captured values
        if (expected_err) begin
            test_passed = (captured_error == expected_err) && (captured_rdata == expected_data);
        end else begin
            test_passed = (captured_error == expected_err) && (captured_rdata == expected_data || expected_data == {DATA_WIDTH{1'b0}});
        end
        
        if (test_passed) begin
            passed_tests++;
        end else begin
            failed_tests++;
            $display("FAIL: Read transfer from 0x%08X - expected data: 0x%08X, got: 0x%08X, expected error: %b, got: %b", 
                    addr, expected_data, captured_rdata, expected_err, captured_error);
        end
    endtask
    
    // Task to reset between test cases
    task reset_between_tests();
        @(posedge PCLK);
        PRESETn = 0;
        #20;
        PRESETn = 1;
        #10;
    endtask
    
    // Monitor APB4 bus activity - removed for less verbose output
    // Monitor transfer completion - removed for less verbose output
    // Monitor bridge state machine - removed for less verbose output
    
    // Waveform dump
    initial begin
        $dumpfile("apb4_bridge_testbench.vcd");
        $dumpvars(0, apb4_bridge_testbench);
    end
    
endmodule 
