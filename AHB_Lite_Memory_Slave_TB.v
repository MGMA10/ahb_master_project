module AHB_Lite_Memory_Slave_TB;

    // Clock and reset
    reg HCLK;
    reg HRESETn;

    // Master to Slave signals
    reg        HSEL;
    reg [31:0] HADDR;
    reg        HWRITE;
    reg [31:0] HWDATA;
    reg [1:0]  HTRANS;
    reg        WORK;
    wire [31:0] HRDATA;
    wire        HREADY;
    wire        HRESP;

    // Clock generation
    always #5 HCLK = ~HCLK;  // 10ns period clock

    // Instantiate Memory Slaves
    AHB_Lite_Memory_Slave memory_slave (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HSEL(HSEL),
        .HADDR(HADDR),
        .HWDATA(HWDATA),
        .HWRITE(HWRITE),
        .HSIZE(3'b010), // Assuming word size of 32 bits
        .HTRANS(HTRANS),
        .WORK(WORK),
        .HRDATA(HRDATA),
        .HREADY(HREADY),
        .HRESP(HRESP)
    );


    // Tasks for read/write operations
    task ahb_write(input [31:0] address, input [31:0] data);
        begin
            @(posedge HCLK);  // Wait for clock edge
            HSEL   <= 1'b1;
            HADDR  <= address;
            HWRITE <= 1'b1;
            HTRANS <= 2'b10;  // Non-sequential transfer
            HWDATA <= data;
            @(posedge HCLK);
            HSEL   <= 1'b0;
            HTRANS <= 2'b00;  // Idle state
        end
    endtask

    task ahb_read(input [31:0] address);
        begin
            @(posedge HCLK);  // Wait for clock edge
            HSEL   <= 1'b1;
            HADDR  <= address;
            HWRITE <= 1'b0;
            HTRANS <= 2'b10;  // Non-sequential transfer
            @(posedge HCLK);
            HSEL   <= 1'b0;
            HTRANS <= 2'b00;  // Idle state
        end
    endtask

    // Verification logic
    task check_data(input [31:0] expected);
        begin
            if (HRDATA !== expected) begin
                $display("ERROR: Expected: %h, Got: %h", expected, HRDATA);
            end else begin
                $display("PASSED: Got correct data %h", HRDATA);
            end
        end
    endtask

    // Test sequence
    initial begin
        HCLK = 0;
        HRESETn = 0;
        HSEL = 0;
        HADDR = 0;
        HWRITE = 0;
        HWDATA = 0;
        HTRANS = 2'b00;
        WORK = 1'b1;

        #5 HRESETn = 1;  // Deassert reset after 15ns
        
        // Wait for reset to deassert
        #20;

        // Test writing to memory slave
        $display("TEST 1: Writing to Memory");
        ahb_write(32'h00000010, 32'hDEADBEEF);  // Write DEADBEEF to address 0x10
        #10;

        // Test reading from memory slave
        $display("TEST 2: Reading from Memory");
        ahb_read(32'h00000010);  // Read from address 0x10
        #10;
        check_data(32'hDEADBEEF);  // Expect DEADBEEF

        $stop;
    end

endmodule
