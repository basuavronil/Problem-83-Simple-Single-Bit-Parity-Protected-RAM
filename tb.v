`timescale 1ns / 1ps

module tb_parity;

    // Testbench Signals
    reg        clk;
    reg        rst;
    reg        wr_en;
    reg  [9:0] wr_addr;
    reg  [7:0] wr_data;
    reg        rd_en;
    reg  [9:0] rd_addr;

    wire [7:0] rd_data;
    wire       parity_error;

    // Instantiate Unit Under Test (UUT)
    parity uut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .rd_en(rd_en),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .parity_error(parity_error)
    );

    // Clock Generation: 100 MHz (10ns period)
    always #5 clk = ~clk;

    // Test Sequence
    initial begin
        // 1. Initialize Inputs
        clk     = 0;
        rst     = 0;
        wr_en   = 0;
        wr_addr = 0;
        wr_data = 0;
        rd_en   = 0;
        rd_addr = 0;

        // 2. Apply Reset
        #15;
        rst = 1; // Release active-low reset
        #10;

        // ---------------------------------------------------------------------
        // TEST 1: Write Data with EVEN Parity (8'b0000_1100 -> 2 ones)
        // ---------------------------------------------------------------------
        $display("[%0t ns] TEST 1: Writing EVEN Parity Data (8'b0000_1100) to Address 10", $time);
        @(posedge clk);
        wr_en   <= 1;
        wr_addr <= 10'd10;
        wr_data <= 8'b0000_1100;

        @(posedge clk);
        wr_en   <= 0;

        // Read Back Address 10
        @(posedge clk);
        rd_en   <= 1;
        rd_addr <= 10'd10;

        @(posedge clk);
        #1; // Delay for non-blocking assignment update
        if (rd_data == 8'b0000_1100 && parity_error == 0) begin
            $display("-> PASS: rd_data = %b, parity_error = %b", rd_data, parity_error);
        end else begin
            $display("-> FAIL: rd_data = %b, parity_error = %b", rd_data, parity_error);
        end
        rd_en <= 0;

        // ---------------------------------------------------------------------
        // TEST 2: Write Data with ODD Parity (8'b1010_1000 -> 3 ones)
        // ---------------------------------------------------------------------
        $display("[%0t ns] TEST 2: Writing ODD Parity Data (8'b1010_1000) to Address 1023", $time);
        @(posedge clk);
        wr_en   <= 1;
        wr_addr <= 10'd1023; // Highest RAM address
        wr_data <= 8'b1010_1000;

        @(posedge clk);
        wr_en   <= 0;

        // Read Back Address 1023
        @(posedge clk);
        rd_en   <= 1;
        rd_addr <= 10'd1023;

        @(posedge clk);
        #1;
        if (rd_data == 8'b1010_1000 && parity_error == 0) begin
            $display("-> PASS: rd_data = %b, parity_error = %b", rd_data, parity_error);
        end else begin
            $display("-> FAIL: rd_data = %b, parity_error = %b", rd_data, parity_error);
        end
        rd_en <= 0;

        // ---------------------------------------------------------------------
        // TEST 3: Inject Corruption to Test Parity Error Flag
        // ---------------------------------------------------------------------
        $display("[%0t ns] TEST 3: Simulating Bit Corruption at Address 1023", $time);
        
        // Flip bit 0 directly in memory hierarchy
        uut.mem[1023] = uut.mem[1023] ^ 9'b0000_0000_1;

        // Read Back Corrupted Address 1023
        @(posedge clk);
        rd_en   <= 1;
        rd_addr <= 10'd1023;

        @(posedge clk);
        #1;
        if (parity_error == 1) begin
            $display("-> PASS: Parity Error successfully detected! parity_error = %b", parity_error);
        end else begin
            $display("-> FAIL: Parity Error undetected! parity_error = %b", parity_error);
        end
        rd_en <= 0;

        // Finish Simulation
        #20;
        $display("[%0t ns] Simulation Complete.", $time);
        $finish;
    end

endmodule
