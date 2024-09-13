module AHB_Master_ALU_REG_pipelined (
    input wire        HCLK,        
    input wire        HRESETn,     
    output reg [31:0] HADDR,       
    output reg [2:0] HBURST,         
    output reg [2:0]  HSIZE,       
    output reg [1:0]  HTRANS,      
    output reg [31:0] HWDATA,      
    output reg        HWRITE,      
    input wire [31:0] HRDATA,      
    input wire        HREADY,      
    input wire        HRESP,
    input wire [63:0] cpu_inst
);

    wire [31:0] ReadData1, ReadData2;
    wire [31:0] ALUResult;
    reg RegWrite;
    reg [31:0] WriteData;
    reg type_data ;
    reg ALU_REG;
    reg write_read;
    reg [7:0] burst_length;
    reg [2:0] ReadReg1_ADDR; //[21:19])
    reg [2:0] ReadReg2_ADDR;  //[24:22]
    reg [2:0] WriteReg_ADDR;  //[27:25]
    reg [2:0] AlU_OP;
    reg [2:0] WriteReg_ADDR2;
    reg [31:0] HWDATA_t;

// Instantiating ALU
ALU alu(
    .A(ReadData1),
    .B(ReadData2),
    .AlU_OP(AlU_OP),
    .Result(ALUResult)
);

// Instantiating Register File
RegisterFile rf(
    .clk(HCLK),
    .ReadReg1_ADDR(ReadReg1_ADDR),
    .ReadReg2_ADDR(ReadReg2_ADDR),
    .WriteReg_ADDR(WriteReg_ADDR2),
    .WriteData(WriteData),
    .RegWrite(RegWrite),
    .ReadData1(ReadData1),
    .ReadData2(ReadData2)
);


localparam      IDLE         = 2'b00,
                BUSY     = 2'b01,
                NONSEQ   = 2'b10,
                SEQ      = 2'b11;

reg [9:0] burst_counter;
reg work;

always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn)
    begin   
        HTRANS <= IDLE;   
    end
    else
begin
        RegWrite <= 0;
        case (HTRANS)
            IDLE:begin
                if (type_data == 1)
                begin
                    if(ALU_REG)
                        begin
                            if(write_read)
                            begin
                                WriteData   <= ALUResult;
                                RegWrite    <= 1;
                            end                           
                             else
                            begin
                                HWDATA_t      <= ALUResult;
                                RegWrite    <= 0;
                            end                        end
                        else
                        begin
                            if (HWRITE)
                            begin
                                WriteData   <= HRDATA;
                                RegWrite    <= 1;
                            end
                            else
                            begin
                                HWDATA_t      <= ReadData1;
                                RegWrite    <= 0;
                            end
                        end
                        type_data <= 1;
                end
                type_data <= 1;
                HADDR <= cpu_inst[63:32];
                HSIZE <= cpu_inst[6:4];  
                HWRITE <= cpu_inst[0];   
                HBURST <= cpu_inst[3:1];
                work <= cpu_inst[7];
                write_read <= cpu_inst [31];
                ALU_REG <= cpu_inst [18];
                burst_length <= cpu_inst[15:8];
                ReadReg1_ADDR <= cpu_inst[21:19];//[21:19])
                ReadReg2_ADDR <=  cpu_inst[24:22];//[24:22]
                WriteReg_ADDR <=  cpu_inst[27:25];//[27:25]
                WriteReg_ADDR2 <= WriteReg_ADDR;
                HWDATA <= HWDATA_t;
                AlU_OP <= cpu_inst [30:28];
                if (HREADY && work) begin
                    HTRANS <= NONSEQ;
                    burst_counter <= 0;        
                end
            end 
            BUSY:begin
                work <= cpu_inst[7];
                if (work) begin
                    
                    HTRANS <= IDLE; 
                end
            end
            NONSEQ:begin
                type_data <= 1;
                HADDR <= cpu_inst[63:32];
                HSIZE <= cpu_inst[6:4];  
                HWRITE <= cpu_inst[0];   
                HBURST <= cpu_inst[3:1];
                work <= cpu_inst[7];
                write_read <= cpu_inst [31];
                ALU_REG <= cpu_inst [18];
                burst_length <= cpu_inst[15:8];
                ReadReg1_ADDR <= cpu_inst[21:19];//[21:19])
                ReadReg2_ADDR <=  cpu_inst[24:22];//[24:22]
                WriteReg_ADDR <=  cpu_inst[27:25];//[27:25]
                WriteReg_ADDR2 <= WriteReg_ADDR;
                HWDATA <= HWDATA_t;
                AlU_OP <= cpu_inst [30:28];
                if(ALU_REG)
                        begin
                            if(write_read)
                            begin
                                WriteData   <= ALUResult;
                                RegWrite    <= 1;
                            end
                            else
                            begin
                                HWDATA_t      <= ALUResult;
                                RegWrite    <= 0;
                            end
                        end
                        else
                        begin
                            if (HWRITE)
                            begin
                                WriteData   <= HRDATA;
                                RegWrite    <= 1;
                            end
                            else
                            begin
                                HWDATA_t      <= ReadData1;
                                RegWrite    <= 0;
                            end
                        end

                if (HREADY) begin
                    if (!work)
                    HTRANS <= BUSY;
                    else if (HBURST) begin
                        type_data <= 1;
                        burst_counter <= burst_counter + 1;
                        HTRANS <= SEQ;
                    end else begin
                        type_data <= 1;
                        HTRANS <= IDLE;
                    end
                end
            end  
            SEQ:begin
                HWDATA <= HWDATA_t;
                ReadReg1_ADDR <= ReadReg1_ADDR +1;
                WriteReg_ADDR <=  WriteReg_ADDR;
                WriteReg_ADDR2 <= WriteReg_ADDR;
                RegWrite    <= 0;
                if (HREADY) begin
                    if(ALU_REG)
                        begin
                            if(write_read)
                            begin
                                WriteData   <= ALUResult;
                                RegWrite    <= 1;
                            end
                            else
                            begin
                                HWDATA_t      <= ALUResult;
                                RegWrite    <= 0;
                            end                        end
                        else
                        begin
                            if (HWRITE)
                            begin
                                WriteData   <= HRDATA;
                                RegWrite    <= 1;
                            end
                            else
                            begin
                                HWDATA_t      <= ReadData1;
                                RegWrite    <= 0;
                            end
                        end
                    HADDR <= HADDR + (4 << HSIZE); 
                        burst_counter <= burst_counter + 1;
                    if (!work)
                    HTRANS <= BUSY;
                    else if(HBURST == 3'b001 && burst_counter * HSIZE < 8'b1111111111 && burst_counter < burst_length-1)
                    HTRANS <= SEQ;
                        
                        else begin
                        HTRANS <= IDLE;
                    end
                end  
            end
            default:HTRANS <= IDLE;
        endcase
    end
end


endmodule



/////////////////////////////////////////////////
////////////////////////////////////////////////
///////////////moduels/////////////////////////
///////////////////////////////////////////////
//////////////////////////////////////////////

module ALU(
    input [31:0] A,    
    input [31:0] B,       
    input [2:0] AlU_OP,   
    output reg [31:0] Result 
);
    always @(*) begin
        case (AlU_OP)
            3'b000: Result = A + B;    // Addition
            3'b001: Result = A - B;    // Subtraction
            3'b010: Result = A & B;    // Bitwise AND
            3'b011: Result = A | B;    // Bitwise OR
            3'b100: Result = A ^ B;    // Bitwise XOR
            3'b101: Result = ~A;       // Bitwise NOT
            3'b110: Result = A << 1;   // Shift left
            3'b111: Result = A >> 1;   // Shift right
            default: Result = 8'b0;
        endcase
    end
endmodule


// 8 registers of 32 bits each
module RegisterFile(
    input clk,
    input [2:0] ReadReg1_ADDR,
    input [2:0] ReadReg2_ADDR,
    input [2:0] WriteReg_ADDR,
    input [31:0] WriteData,
    input RegWrite,
    output [31:0] ReadData1,
    output [31:0] ReadData2
);
    reg [31:0] registers [7:0]; 

    assign ReadData1 = registers[ReadReg1_ADDR];
    assign ReadData2 = registers[ReadReg2_ADDR];

    always @(posedge clk) begin
        if (RegWrite) begin
            registers[WriteReg_ADDR] <= WriteData;
        end
    end
endmodule
