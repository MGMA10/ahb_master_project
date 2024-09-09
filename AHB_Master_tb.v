module AHB_Master_tb();

    // Signals
    reg         HCLK;        
    reg         HRESETn;     
    wire [31:0] HADDR;       
    wire [2:0]  HBURST;      
    wire [2:0]  HSIZE;       
    wire [1:0]  HTRANS;      
    wire [31:0] HWDATA;      
    wire        HWRITE;      
    reg  [31:0] HRDATA;      
    reg         HREADY;      
    reg         HRESP;
    reg  [63:0] cpu_inst;
    reg  [7:0]  cpu_cont;
    reg [7:0] num_beats;
    // Instantiation
    AHB_Master dut (
        .HCLK(HCLK),        
        .HRESETn(HRESETn),     
        .HADDR(HADDR),       
        .HBURST(HBURST),      
        .HSIZE(HSIZE),       
        .HTRANS(HTRANS),      
        .HWDATA(HWDATA),      
        .HWRITE(HWRITE),      
        .HRDATA(HRDATA),      
        .HREADY(HREADY),      
        .HRESP(HRESP),
        .cpu_inst(cpu_inst),
        .cpu_cont(cpu_cont),
        .num_beats(num_beats)
    );



    initial begin
        // Initialize Signals
        HCLK = 0;
        HRESETn = 0;
        HREADY = 1;
        HRESP = 0;
        cpu_inst = 64'h00000000_00000000;
        cpu_cont = 8'b00000000;
        HRDATA = 32'h00000000;
        num_beats = 4;

        // Apply Reset
        #10 HRESETn = 1;

        // Perform Write Transaction (HSIZE = 4-byte, Incrementing Burst, Non-Sequential)

        cpu_inst = 64'h000DD000_AAAAAAAA;  // Address = 0xAAAAAAAA, Write Data = 0x00000000
        cpu_cont = 8'b10010011;  // Work = 1, HSIZE = 4-byte, HBURST = INCR, HWRITE = 1
        #20;
        
        // Check if the transaction transitions to NONSEQ
        if (HTRANS == 2'b10)
            $display("NONSEQ transaction started at time %0t", $time);
        else
            $display("ERROR: NONSEQ transaction did not start as expected at time %0t", $time);

        // Simulate HREADY being low (slave busy)
        HREADY = 0;
        #30;
        
        // Simulate slave ready
        HREADY = 1;
        #20;

        // Check if the transaction transitions to SEQ
        if (HTRANS == 2'b11)
            $display("SEQ transaction continued at time %0t", $time);
        else
            $display("ERROR: SEQ transaction did not continue as expected at time %0t", $time);
        #30
        // Perform Read Transaction (Single Transfer, HSIZE = 4-byte, Non-Sequential)
        cpu_inst = 64'hBBBBBBBB_00000000;  // Address = 0xBBBBBBBB, No Write Data
        cpu_cont = 8'b10000010;  // Work = 1, HSIZE = 4-byte, HBURST = SINGLE, HWRITE = 0
        num_beats = 5; 
        #10;

        // Check if the transaction transitions to NONSEQ for read
        if (HTRANS == 2'b10)
            $display("NONSEQ Read transaction started at time %0t", $time);
        else
            $display("ERROR: NONSEQ Read transaction did not start as expected at time %0t", $time);
        #10
        // Simulate read data from slave
        HRDATA = 32'hDEADBEEF;
        #10
        HRDATA = 32'hDAAAAEEF;
        #10
        HRDATA = 32'hDAADDEEF;
        #10
        HRDATA = 32'hDAAAFFF;
        #10
        HRDATA = 32'hAAAAAAAA;
        #10
        // Check the end of the transaction
        if (HTRANS == 2'b00)
            $display("Transaction ended successfully at time %0t", $time);
        else
            $display("ERROR: Transaction did not end as expected at time %0t", $time);

        // Perform BURST Transaction (Single Transfer, HSIZE = 4-byte, Sequential)
            cpu_inst = 64'hBBBBBBBB_00000000;  // Address = 0xBBBBBBBB, No Write Data
            cpu_cont = 8'b10000000;  // Work = 1, HSIZE = 4-byte, HBURST = SINGLE, HWRITE = 0
            num_beats = 5; // Shoud be egnored
            //Check the undefiend length
            #200;
    
            
        // Finish simulation
        $stop;
    end

    // Clock Generation
    always #5 HCLK = ~HCLK;  // 10ns clock period

endmodule
