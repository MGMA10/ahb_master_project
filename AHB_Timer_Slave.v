module AHB_Lite_Timer_Slave (
    input  wire        HCLK,
    input  wire        HRESETn,
    input  wire        HSEL,
    input  wire [29:0] HADDR,
    input  wire        HWRITE,
    input  wire [1:0]  HTRANS,
    input  wire [31:0] HWDATA,
    input  wire        WORK,
    output reg  [31:0] HRDATA,
    output reg         HREADY,
    output reg         HRESP,
    output reg         Interrupt
);

    reg [29:0] timer_count;
    reg        timer_enable;
    reg [29:0] timer_Target;

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            timer_count  <= 32'b0;
            timer_enable <= 1'b0;
            HREADY    <= 1'b1;
            HRDATA       <= 32'b0;
            HRESP        <= 1'b0;  // OKAY response
            timer_Target <= 1;
            Interrupt <= 0;
        end else begin
            if (timer_enable)
                timer_count <= timer_count + 1;

                if ((timer_count >= timer_Target-1) && timer_enable)
                begin
                    Interrupt <= 1;
                    timer_count <= 0;
                end
                else
                begin
                    Interrupt <= 0;
                end
            if (HSEL && WORK) begin
                if (HWRITE) begin
                    timer_Target <= HWDATA;
                    // Write to Timer Control Register
                    if (HADDR == 32'h00000000) begin
                        timer_enable <= HWDATA[0];
                    end
                    if (HADDR == 32'h00000004) begin
                        timer_count <= 32'b0;  // Reset the timer
                    end
                    HREADY <= 1'b1;
                    HRESP     <= 1'b0;  // OKAY response
                    Interrupt <= 0;
                end else begin
                    // Read Timer Value
                    if (HADDR == 32'h00000000) begin
                        HRDATA <= {29'b0, timer_enable};
                    end else if (HADDR == 32'h00000004) begin
                        HRDATA <= timer_count;
                    end
                    HREADY <= 1'b1;
                    HRESP     <= 1'b0;  // OKAY response
                end
                
            end else begin
                HREADY <= 1'b1;
                HRESP     <= 1'b0;  // Default OKAY response
            end
        end
    end
endmodule
