module parity (
    input wire        clk, 
    input wire        rst,       
    // Write interface 
    input wire        wr_en,
    input wire  [9:0] wr_addr,
    input wire  [7:0] wr_data,
    // Read interface
    input wire        rd_en,
    input wire  [9:0] rd_addr,
    output reg  [7:0] rd_data,
    output reg        parity_error
);

    reg [8:0] mem [0:1023];      
    wire      wr_parity;         
    integer   i;

    assign wr_parity = ^wr_data;

    // Write Logic
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (i = 0; i < 1024; i = i + 1) begin
                mem[i] <= 9'd0;    
            end
        end else if (wr_en) begin
            mem[wr_addr] <= {wr_parity, wr_data};
        end
    end

    // Read Logic
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            rd_data      <= 8'd0; // Cleared single output register (not an array loop)
            parity_error <= 1'b0;
        end else if (rd_en) begin
            rd_data      <= mem[rd_addr][7:0];
            parity_error <= (mem[rd_addr][8] != ^mem[rd_addr][7:0]);
        end else begin
            parity_error <= 1'b0;
        end
    end

endmodule
