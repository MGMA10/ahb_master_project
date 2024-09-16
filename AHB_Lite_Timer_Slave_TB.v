module AHB_Lite_Timer_Slave_TB;

    // Clock and reset
    reg HCLK;
    reg HRESETn;

    // Master to Slave signals
    reg             HSEL;
    reg     [29:0]  HADDR;
    reg             HWRITE;
    reg     [31:0]  HWDATA;
    reg     [1:0]   HTRANS;
    reg             WORK;
    wire    [31:0]  HRDATA;
    wire            HREADY;
    wire            HRESP;
    wire            Interrupt;
    wire    [29:0]  timer_count;
    wire    [29:0]  timer_Target;

    assign timer_count = timer_slave.timer_count;
    assign timer_Target = timer_slave.timer_Target;


    // Clock generation
    always #5 HCLK = ~HCLK;  // 10ns period clock

    // Instantiate Timer Slaves 

    // AHB-Lite Timer Slave
     AHB_Lite_Timer_Slave timer_slave (
         .HCLK(HCLK),
         .HRESETn(HRESETn),
         .HSEL(HSEL),
         .HADDR(HADDR),
         .HWRITE(HWRITE),
         .HTRANS(HTRANS),
         .HWDATA(HWDATA),
         .WORK(WORK),
         .HRDATA(HRDATA),
         .HREADY(HREADY),
         .HRESP(HRESP),
         .Interrupt(Interrupt)
     );

  
    // Tasks for read/write operations
    task ahb_write(input [29:0] address, input [31:0] data);
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

    task ahb_read(input [29:0] address);
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

        #15 HRESETn = 1;  // Deassert reset after 15ns

        // Wait for reset to deassert
        #5;

        // Test writing to timer slave
         $display("TEST 3: Writing to Timer (Enable Timer)");
         ahb_write(32'h00000000, 32'h5);   // Enable timer
         #10;

        // Test reading from timer slave
         $display("TEST 4: Reading from Timer");
         ahb_read(32'h00000004);   // Read timer value
         #10;
         check_data(32'h00000001);  // Check if timer started (may need to adjust depending on design)
        
         // Test Interrupt from timer slave
         $display("TEST 5: Timer Interrupt");
         #30
         if (Interrupt !== 1) begin
            $display("ERROR: Expected: %h, Got: %h", 1, 0);
        end else begin
            $display("PASSED: Got correct data %h", 1);
        end
        
        $stop;
    end

endmodule
