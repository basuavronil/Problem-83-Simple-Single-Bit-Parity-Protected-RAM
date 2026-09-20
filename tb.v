`timescale 1ns / 1ps

module tb_parity_protected_ram;

    // Testbench Signals
    reg        clk;
    reg        rst_n;
    reg        wr_en;
    reg  [3:0] wr_addr;
    reg  [7:0] wr_data;
    reg        rd_en;
    reg  [3:0] rd_addr;
    
    wire [7:0] rd_data;
    wire       parity_error;

    // Instantiate the Unit Under Test (UUT)
    parity_protected_ram uut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .rd_en(rd_en),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .parity_error(parity_error)
    );

    // Clock Generation (100 MHz -> 10ns period)
    always #5 clk = ~clk;

    // Test Sequence
    initial begin
        // 1. Initialize Inputs
        clk     = 0;
        rst_n   = 0;
        wr_en   = 0;
        wr_addr = 0;
        wr_data = 0;
        rd_en   = 0;
        rd_addr = 0;

        // 2. Apply Reset
        #15;
        rst_n = 1;
        #10;

        // ---------------------------------------------------------------------
        // TEST CASE 1: Write data with EVEN number of 1s (0000_0011 -> 2 ones)
        // ---------------------------------------------------------------------
        $display("[%0t ns] TEST 1: Writing 8'b0000_0011 to Address 4", $time);
        @(posedge clk);
        wr_en   <= 1;
        wr_addr <= 4'd4;
        wr_data <= 8'b0000_0011; // Even parity -> Parity Bit = 0
        
        @(posedge clk);
        wr_en   <= 0;

        // Read back Address 4
        @(posedge clk);
        rd_en   <= 1;
        rd_addr <= 4'd4;

        @(posedge clk);
        #1; // Wait for non-blocking assignment
        if (rd_data == 8'b0000_0011 && parity_error == 0) begin
            $display("-> PASS: Read data = %b, parity_error = %b", rd_data, parity_error);
        end else begin
            $display("-> FAIL: Read data = %b, parity_error = %b", rd_data, parity_error);
        end
        rd_en <= 0;

        // ---------------------------------------------------------------------
        // TEST CASE 2: Write data with ODD number of 1s (1010_0001 -> 3 ones)
        // ---------------------------------------------------------------------
        $display("[%0t ns] TEST 2: Writing 8'b1010_0001 to Address 7", $time);
        @(posedge clk);
        wr_en   <= 1;
        wr_addr <= 4'd7;
        wr_data <= 8'b1010_0001; // Odd parity -> Parity Bit = 1

        @(posedge clk);
        wr_en   <= 0;

        // Read back Address 7
        @(posedge clk);
        rd_en   <= 1;
        rd_addr <= 4'd7;

        @(posedge clk);
        #1;
        if (rd_data == 8'b1010_0001 && parity_error == 0) begin
            $display("-> PASS: Read data = %b, parity_error = %b", rd_data, parity_error);
        end else begin
            $display("-> FAIL: Read data = %b, parity_error = %b", rd_data, parity_error);
        end
        rd_en <= 0;

        // ---------------------------------------------------------------------
        // TEST CASE 3: Intentionally Corrupt Memory to Trigger parity_error
        // ---------------------------------------------------------------------
        $display("[%0t ns] TEST 3: Force Bit-Flip Corruption at Address 7", $time);
        
        // Directly flip a bit inside RAM hierarchy to simulate a hardware soft error
        uut.ram[7] = uut.ram[7] ^ 9'b0000_0000_1; // Flip bit 0

        // Read back corrupted Address 7
        @(posedge clk);
        rd_en   <= 1;
        rd_addr <= 4'd7;

        @(posedge clk);
        #1;
        if (parity_error == 1) begin
            $display("-> PASS: Parity error successfully detected! parity_error = %b", parity_error);
        end else begin
            $display("-> FAIL: Parity error went undetected! parity_error = %b", parity_error);
        end
        rd_en <= 0;

        // Finish Simulation
        #20;
        $display("[%0t ns] All tests completed.", $time);
        $finish;
    end

endmodule
