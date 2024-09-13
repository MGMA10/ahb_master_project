
`timescale 1ns / 1ps
 

module AHB_Master_ALU_REG_pipelined_TB;

    // Inputs
    reg HCLK;
    reg HRESETn;
    reg HREADY;
    reg HRESP;
    reg [31:0] HRDATA;
//{HADDR,read_write,AlU_OP,WriteReg_ADDR,ReadReg2_ADDR,ReadReg1_ADDR,Register,2'b000,burst_length,work,HSIZE,HBURST,HWRITE}
    reg [2:0] ReadReg1_ADDR; //[21:19])
    reg [2:0] ReadReg2_ADDR;  //[24:22]
    reg [2:0] WriteReg_ADDR;  //[27:25]
    reg [2:0] AlU_OP;  //[30:28]
    reg [31:0] HADDRin; // [63:32]
    reg [2:0] HSIZEin;  //[6:4]
    reg HWRITEin;   //[0]
    reg [2:0] HBURSTin;  //[3:1]
    reg work ;  //[7]
    reg [7:0] burst_length;  //[15:8]
    reg read_write;  // [31]
    reg Register;  //[18]

    // Outputs

    wire [31:0] HADDR;
    wire [2:0] HBURST;
    wire [2:0] HSIZE;
    wire [1:0] HTRANS;
    wire [31:0] HWDATA;
    wire HWRITE;


    wire rg_wr;
    wire [31:0] refi;
    wire [31:0] ins;
    wire reg_write;
    wire type_data;
    

    assign rg_wr = uut.WriteData;
    assign type_data = uut.type_data;
    assign ins = uut.cpu_inst[31:0];
    assign reg_write = uut.RegWrite;
    assign refi = uut.rf.registers[0];


    // Instantiate the Unit Under Test (UUT)
    AHB_Master_ALU_REG_pipelined uut (
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
        .cpu_inst({HADDRin,read_write,AlU_OP,WriteReg_ADDR,ReadReg2_ADDR,ReadReg1_ADDR,Register,2'b000,burst_length,work,HSIZEin,HBURSTin,HWRITEin})
    );


    // Clock generation
    always #5 HCLK = ~HCLK;

    initial begin
        // Initialize Inputs
        HCLK = 0;
        HRESETn = 0;
        HREADY = 1;
        HRESP = 0;
        HRDATA = 0;
        HRDATA = 10;
        // Wait 100 ns for global reset to finish
        #10;
        
        // Release reset
        HRESETn = 1;

        // Test Case 1: Basic Read and store in the register
        ReadReg1_ADDR = 0; //[21:19])
        ReadReg2_ADDR = 1;  //[24:22]
        WriteReg_ADDR = 0;  //[27:25]
        AlU_OP = 0;  //[30:28]
        HADDRin = 0; // [63:32]
        HSIZEin = 3;  //[6:4]
        HWRITEin = 1;   //[0]
        HBURSTin = 0;  //[3:1]
        work = 1;  //[7]
        burst_length = 0;  //[15:8]
        read_write = 0;  // [31]
        Register = 0;  //[18]
        #10
        $display("Test Case 1 :) $t",$time);

        #10 // as we need 1 clk addetional in the background to write in the reg file so we can not read after write from the same address directely

        // Test Case 2: send the data you reseave and store before 
        ReadReg1_ADDR = 0; //[21:19])
        ReadReg2_ADDR = 1;  //[24:22]
        WriteReg_ADDR = 0;  //[27:25]
        AlU_OP = 0;  //[30:28]
        HADDRin = 0; // [63:32]
        HSIZEin = 3;  //[6:4]
        HWRITEin = 0;   //[0]
        HBURSTin = 0;  //[3:1]
        work = 1;  //[7]
        burst_length = 0;  //[15:8]
        read_write = 1;  // [31]
        Register = 0;  //[18]
        #10
        $display("Test Case 2 :) $t",$time);

        // Test Case 3: Basic Read and store in the register in anther address
        ReadReg1_ADDR = 0; //[21:19])
        ReadReg2_ADDR = 1;  //[24:22]
        WriteReg_ADDR = 1;  //[27:25]
        AlU_OP = 0;  //[30:28]
        HADDRin = 0; // [63:32]
        HSIZEin = 3;  //[6:4]
        HWRITEin = 1;   //[0]
        HBURSTin = 0;  //[3:1]
        work = 1;  //[7]
        burst_length = 0;  //[15:8]
        read_write = 0;  // [31]
        Register = 0;  //[18]
        HRDATA = 15;
        #10
        $display("Test Case 3 :) $t",$time);

        #10 // as we need 1 clk addetional in the background to write in the reg file so we can not read after write from the same address directely
        // Test Case 4: ALU operation and store in the reg
        ReadReg1_ADDR = 0; //[21:19])
        ReadReg2_ADDR = 1;  //[24:22]
        WriteReg_ADDR = 2;  //[27:25]
        AlU_OP = 6;  //[30:28]
        HADDRin = 0; // [63:32]
        HSIZEin = 3;  //[6:4]
        HWRITEin = 1;   //[0]
        HBURSTin = 0;  //[3:1]
        work = 1;  //[7]
        burst_length = 0;  //[15:8]
        read_write = 1;  // [31]
        Register = 1;  //[18]
        HRDATA = 15;
        #10
        $display("Test Case 4 :) $t",$time);

        // Test Case 5: ALU operation and send
        ReadReg1_ADDR = 0; //[21:19])
        ReadReg2_ADDR = 1;  //[24:22]
        WriteReg_ADDR = 2;  //[27:25]
        AlU_OP = 0;  //[30:28]
        HADDRin = 0; // [63:32]
        HSIZEin = 3;  //[6:4]
        HWRITEin = 0;   //[0]
        HBURSTin = 0;  //[3:1]
        work = 1;  //[7]
        burst_length = 0;  //[15:8]
        read_write = 0;  // [31]
        Register = 1;  //[18]
        HRDATA = 15;
        #10
        $display("Test Case 5 :) $t",$time);

        // Test Case n: send the data you reseave and store before to test address 2 
        ReadReg1_ADDR = 2; //[21:19])
        ReadReg2_ADDR = 1;  //[24:22]
        WriteReg_ADDR = 0;  //[27:25]
        AlU_OP = 0;  //[30:28]
        HADDRin = 0; // [63:32]
        HSIZEin = 3;  //[6:4]
        HWRITEin = 0;   //[0]
        HBURSTin = 0;  //[3:1]
        work = 1;  //[7]
        burst_length = 0;  //[15:8]
        read_write = 1;  // [31]
        Register = 0;  //[18]
        #10
        $display("Test Case n :) $t",$time);

        // Test Case 6: Check Reset Behavior
        HREADY = 0;
        #20;
        HREADY = 1;
        $display("Test Case 6 :) $t",$time);

        // Test Case 8: Check Reset Behavior
        HRESETn = 0;
        #10;
        HRESETn = 1;
        #10
        $display("Test Case 7 :) $t",$time);

        // Test Case 8: block don't work
        work = 0;  //[7]
        #30;
        work = 1;  //[7]
        $display("Test Case 8 :) $t",$time);
        #20 //after rewaork we shoud wait 2 clk or more to end the operation and return to the ideal

        // Test Case 9: HBURST send the data you reseave and store before 
        ReadReg1_ADDR = 0; //[21:19])
        ReadReg2_ADDR = 1;  //[24:22]
        WriteReg_ADDR = 0;  //[27:25]
        AlU_OP = 0;  //[30:28]
        HADDRin = 0; // [63:32]
        HSIZEin = 3;  //[6:4]
        HWRITEin = 0;   //[0]
        HBURSTin = 1;  //[3:1]
        work = 1;  //[7]
        burst_length = 3;  //[15:8]
        read_write = 1;  // [31]
        Register = 0;  //[18]
        

        #100;
        $stop;
    end

endmodule

//after rewaork we shoud wait 2 clk or more to end the operation and return to the ideal
// as we need 1 clk addetional in the background to write in the reg file so we can not read after write from the same address directely
// i could make it pipelined put in the case of simple cpu with reg file we need the bypath to be handeled to make a pipelined so i will remake it with my risc v pipelined processor to pipeline the ahb bus
// i have anther way to handel the over lapping and make it pipelined without use pipelined processor put in this case i will lose in the speed of the path.
// this processor make oeration internaly and externaly with the ahb path and the both is separate 
//the alu could write in the reg or in the write ahb bath directly and the same for the reg file