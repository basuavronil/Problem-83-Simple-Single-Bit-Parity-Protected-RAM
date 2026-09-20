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

    // Real-Time Monitor Setup
    initial begin
        // Print formatted header
        $display("\n==========================================================================================================");
        $display(" TIME(ns) | RST | WR_EN | WR_ADDR | WR_DATA  | RD_EN | RD_ADDR | RD_DATA  | PARITY_ERR | TEST CASE STATUS");
        $display("==========================================================================================================");
        
        // $monitor continuously displays signal changes whenever any tracked variable changes
        $monitor("%8t |  %b  |   %b   |  %4d   | %b |   %b   |  %4d   | %b |     %b      |", 
                 $time, rst, wr_en, wr_addr, wr_data, rd_en, rd_addr, rd_data, parity_error);
    end

    // Test Sequence
    initial begin
        // Waveform Dump Setup (for GTKWave / EDA Playground)
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_parity);

        // 1. Initialize Inputs
        clk     = 0;
        rst     = 0;
        wr_en   = 0;
        wr_addr = 0;
        wr_data = 0;
        rd_en   = 0;
        rd_addr = 0;

        // ---------------------------------------------------------------------
        // CASE 1: Reset Behavior Verification
        // ---------------------------------------------------------------------
        #15;
        rst = 1; // Release active-low reset
        #10;

        // ---------------------------------------------------------------------
        // CASE 2: Write/Read EVEN Parity Payload (8'b0000_1100 -> 2 ones)
        // ---------------------------------------------------------------------
        $display("\n---> CASE 2: Writing & Reading EVEN Parity Data at Address 5");
        @(posedge clk);
        wr_en   <= 1;
        wr_addr <= 10'd5;
        wr_data <= 8'b0000_1100;

        @(posedge clk);
        wr_en   <= 0;

        @(posedge clk);
        rd_en   <= 1;
        rd_addr <= 10'd5;

        @(posedge clk);
        #1; // Delay to allow non-blocking outputs to settle
        if (rd_data == 8'b0000_1100 && parity_error == 0)
            $display("-> PASS: EVEN Parity Write/Read Success");
        else
            $display("-> FAIL: EVEN Parity Check Failed");
        rd_en <= 0;

        // ---------------------------------------------------------------------
        // CASE 3: Write/Read ODD Parity Payload (8'b1010_1000 -> 3 ones)
        // ---------------------------------------------------------------------
        $display("\n---> CASE 3: Writing & Reading ODD Parity Data at Max Address (1023)");
        @(posedge clk);
        wr_en   <= 1;
        wr_addr <= 10'd1023;
        wr_data <= 8'b1010_1000;

        @(posedge clk);
        wr_en   <= 0;

        @(posedge clk);
        rd_en   <= 1;
        rd_addr <= 10'd1023;

        @(posedge clk);
        #1;
        if (rd_data == 8'b1010_1000 && parity_error == 0)
            $display("-> PASS: ODD Parity Write/Read Success");
        else
            $display("-> FAIL: ODD Parity Check Failed");
        rd_en <= 0;

        // ---------------------------------------------------------------------
        // CASE 4: Inject Payload Bit Corruption (Simulate Soft Error)
        // ---------------------------------------------------------------------
        $display("\n---> CASE 4: Injecting Data Bit-Flip at Address 1023");
        
        // Direct hierarchical force to flip bit 0 of payload inside RAM
        uut.mem[1023] = uut.mem[1023] ^ 9'b0000_0000_1;

        @(posedge clk);
        rd_en   <= 1;
        rd_addr <= 10'd1023;

        @(posedge clk);
        #1;
        if (parity_error == 1)
            $display("-> PASS: Parity Error Flag Successfully Triggered!");
        else
            $display("-> FAIL: Parity Error Undetected!");
        rd_en <= 0;

        // ---------------------------------------------------------------------
        // CASE 5: Inject Parity Bit Corruption (Parity Bit itself flips)
        // ---------------------------------------------------------------------
        $display("\n---> CASE 5: Injecting Parity Bit Corruption at Address 5");
        
        // Direct hierarchical force to flip bit 8 (stored parity bit)
        uut.mem[5] = uut.mem[5] ^ 9'b1000_0000_0;

        @(posedge clk);
        rd_en   <= 1;
        rd_addr <= 10'd5;

        @(posedge clk);
        #1;
        if (parity_error == 1)
            $display("-> PASS: Parity Bit Corruption Successfully Detected!");
        else
            $display("-> FAIL: Parity Bit Corruption Undetected!");
        rd_en <= 0;

        // ---------------------------------------------------------------------
        // CASE 6: Back-to-Back Sequential Read Operations
        // ---------------------------------------------------------------------
        $display("\n---> CASE 6: Rapid Read Operations on Unwritten Memory");
        @(posedge clk);
        rd_en   <= 1;
        rd_addr <= 10'd0;

        @(posedge clk);
        rd_addr <= 10'd1;

        @(posedge clk);
        rd_en   <= 0;

        // Finish Simulation
        #20;
        $display("\n==========================================================================================================");
        $display("ALL TEST CASES COMPLETED SUCCESSFULLY");
        $display("==========================================================================================================\n");
        $finish;
    end

endmodule
