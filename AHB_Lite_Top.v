module AHB_Lite_Top (
    input wire        HCLK,
    input wire        HRESETn,
    input wire [63:0] cpu_inst,  // Assuming cpu_inst is the instruction set from the CPU
    output wire       Interrupt,
    output wire [31:0] HRDATA_master
);

    // AHB Master Signals
    wire [31:0] HADDR_master;
    wire [31:0] HWDATA_master;
    wire [31:0] HRDATA_slave;
    wire [2:0]  HBURST_master;
    wire [2:0]  HSIZE_master;
    wire [1:0]  HTRANS_master;
    wire        HWRITE_master;
    wire        HREADY_slave;
    wire        HRESP_slave;

    // Decoder and Multiplexer Control Signals
    wire [3:0] HSEL;  // Selects the active slave
    wire [1:0] HADDR_sel;
    
    // Multiplexer signals for data paths between master and slaves
    wire [31:0] HRDATA_mem, HRDATA_timer;
    wire        HREADY_mem, HREADY_timer;
    wire        HRESP_mem, HRESP_timer;
    
    // Timer interrupt signal
    wire Interrupt_timer;

    // Instantiate AHB Master (ALU REG Pipelined)
    AHB_Master_ALU_REG_pipelined master(
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HADDR(HADDR_master),
        .HBURST(HBURST_master),
        .HSIZE(HSIZE_master),
        .HTRANS(HTRANS_master),
        .HWDATA(HWDATA_master),
        .HWRITE(HWRITE_master),
        .HRDATA(HRDATA_slave),
        .HREADY(HREADY_slave),
        .HRESP(HRESP_slave),
        .cpu_inst(cpu_inst)
    );

    // Instantiate Decoder
    decoder addr_decoder(
        .HADDR(HADDR_master[3:2]), // Assume we're using bits [3:2] to select the slave
        .HSEL(HSEL)
    );

    // Instantiate Memory Slave
    AHB_Lite_Memory_Slave memory_slave (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HSEL(HSEL[0]),
        .HADDR(HADDR_master[31:2]), // Memory is 4-byte aligned
        .HWDATA(HWDATA_master),
        .HWRITE(HWRITE_master),
        .HSIZE(HSIZE_master),
        .HTRANS(HTRANS_master),
        .WORK(HSEL[0]),
        .HRDATA(HRDATA_mem),
        .HREADY(HREADY_mem),
        .HRESP(HRESP_mem)
    );

    // Instantiate Timer Slave
    AHB_Lite_Timer_Slave timer_slave (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HSEL(HSEL[1]),
        .HADDR(HADDR_master[31:2]), // Timer is 4-byte aligned
        .HWRITE(HWRITE_master),
        .HTRANS(HTRANS_master),
        .HWDATA(HWDATA_master),
        .WORK(HSEL[1]),
        .HRDATA(HRDATA_timer),
        .HREADY(HREADY_timer),
        .HRESP(HRESP_timer),
        .Interrupt(Interrupt_timer)
    );

    // Instantiate Multiplexor for HRDATA, HREADY, and HRESP signals
    multiplexor slave_mux (
        .HADDR(HADDR_master[3:2]),  // Use [3:2] for slave selection
        .X1(HRDATA_mem), .X2(HRDATA_timer), .X3(32'b0), .X4(32'b0), // Other slaves not present
        .Y1(HREADY_mem), .Y2(HREADY_timer), .Y3(1'b1), .Y4(1'b1),
        .Z1(HRESP_mem), .Z2(HRESP_timer), .Z3(1'b0), .Z4(1'b0),
        .X(HRDATA_slave),
        .Y(HREADY_slave),
        .Z(HRESP_slave)
    );

    // Interrupt signal from Timer slave
    assign Interrupt = Interrupt_timer;

    // Output master HRDATA
    assign HRDATA_master = HRDATA_slave;

endmodule
