module AHB_Lite_Memory_Slave (
    input  wire        HCLK,
    input  wire        HRESETn,
    input  wire        HSEL,
    input  wire [29:0] HADDR,
    input  wire [31:0] HWDATA,
    input  wire        HWRITE,
    input  wire [2:0]  HSIZE,
    input  wire [1:0]  HTRANS,
    input  wire        WORK,
    output reg  [31:0] HRDATA,
    output reg         HREADY,
    output reg         HRESP
);
    reg [31:0] memory [0:1023];  // 1024-word memory

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            HREADY <= 1'b1;
            HRDATA    <= 32'b0;
            HRESP     <= 1'b1;  // Default response
        end else if (HSEL && WORK && (HTRANS != 1'b1)) begin
            // Valid transfer
            if (HWRITE) begin
                // Write to memory
                memory[HADDR[9:0]] <= HWDATA;
                HREADY <= 1'b1;
                HRESP     <= 1'b0;  // OKAY response
            end else begin
                // Read from memory
                HRDATA <= memory[HADDR[9:0]];
                HREADY <= 1'b1;
                HRESP     <= 1'b0;  // OKAY response
            end
        end else begin
            HREADY <= 1'b1;
            HRESP     <= 1'b1;  // Default response
        end
    end
endmodule
