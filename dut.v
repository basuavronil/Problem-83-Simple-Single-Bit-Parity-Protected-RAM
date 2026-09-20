module parity_protected_ram (
    input  wire       clk,
    input  wire       rst_n,
    
    // Write Interface (Producer)
    input  wire       wr_en,
    input  wire [3:0] wr_addr,
    input  wire [7:0] wr_data,
    
    // Read Interface (Consumer)
    input  wire       rd_en,
    input  wire [3:0] rd_addr,
    output reg  [7:0] rd_data,
    output reg        parity_error
);

    // Memory array: 16 entries deep. 
    // Each entry is 9 bits wide (Bit 8 = Parity Bit, Bits [7:0] = Data payload)
    reg [8:0] ram [0:15];

    // Calculate parity bit for the incoming write data
    wire wr_parity = ^wr_data; 

    // WRITE LOGIC
    always @(posedge clk) begin
        if (wr_en) begin
            // Store 1-bit parity at bit 8, and 8-bit data at bits 7:0
            ram[wr_addr] <= {wr_parity, wr_data}; 
        end
    end

    // READ LOGIC
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_data      <= 8'd0;
            parity_error <= 1'b0;
        end else if (rd_en) begin
            // Deliver data payload to output
            rd_data <= ram[rd_addr][7:0];
            
            // Check if stored parity (bit 8) matches recalculated parity (^bits[7:0])
            // If they don't match, parity_error goes HIGH (1)
            parity_error <= (ram[rd_addr][8] != ^ram[rd_addr][7:0]);
        end else begin
            parity_error <= 1'b0;
        end
    end

endmodule
