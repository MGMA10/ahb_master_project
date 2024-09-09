module AHB_Master (
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
    input wire [63:0] cpu_inst,
    input wire [7:0] cpu_cont,
    input wire [7:0] num_beats
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
        case (HTRANS)
            IDLE:begin
                HADDR <= cpu_inst[63:32];
                HWDATA <= cpu_inst[31:0];
                HSIZE <= cpu_cont[6:4];  
                HWRITE <= cpu_cont[0];   
                HBURST <= cpu_cont[3:1];
                work <= cpu_cont[7];
                if (HREADY && work) begin
                    HTRANS <= NONSEQ;
                    burst_counter <= 0;        
                end
            end
            BUSY:begin
                if (HREADY && work) begin
                    HTRANS <= SEQ; 
                end
            end
            NONSEQ:begin
                if (HREADY) begin
                    if (!work)
                    HTRANS <= BUSY;
                    else if (HBURST) begin
                        HWDATA <= cpu_inst[31:0];
                        burst_counter <= burst_counter + 1;
                        HTRANS <= SEQ;
                    end else begin
                        HTRANS <= IDLE;
                        HWDATA <= cpu_inst[31:0];
                    end
                end
            end
            SEQ:begin
                if (HREADY) begin
                    HWDATA <= cpu_inst[31:0];
                    HADDR <= HADDR + (4 << HSIZE); 
                        burst_counter <= burst_counter + 1;
                    if (!work)
                    HTRANS <= BUSY;
                    else if(HBURST == 3'b001 && burst_counter * HSIZE < 8'b1111111111 && burst_counter < num_beats)
                        HTRANS <= SEQ;

                    /* fitures not Supported
 
                    else if(HBURST == 3'b010 && burst_counter < 4)
                            HTRANS <= SEQ;

                    else if(HBURST == 3'b011 && burst_counter < 4)
                        HTRANS <= SEQ;

                    else if(HBURST == 3'b100 && burst_counter < 8)
                            HTRANS <= SEQ;

                    else if(HBURST == 3'b101 && burst_counter < 8)
                            HTRANS <= SEQ;

                    else if(HBURST == 3'b110 && burst_counter < 16)
                            HTRANS <= SEQ;

                    else if(HBURST == 3'b111 && burst_counter < 16)
                            HTRANS <= SEQ; 
*/
                        else begin
                        HTRANS <= IDLE;
                    end
                end  
            end
            default:HTRANS <= IDLE;
        endcase
    end
end

/* If we make it pipelined we will use this as an interface block
always @(posedge HCLK) begin
    HADDR <= cpu_inst[63:32];
    HWDATA <= cpu_inst[31:0];
    HSIZE <= cpu_cont[6:4];  
    HWRITE <= cpu_cont[0];   
    HBURST <= cpu_cont[3:1];
    work <= cpu_cont[7];
end
*/
endmodule