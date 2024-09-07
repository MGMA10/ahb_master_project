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
    input wire [7:0] cpu_cont
);


localparam      IDLE         = 2'b00,
                BUSY     = 2'b01,
                NONSEQ   = 2'b10,
                SEQ      = 2'b11;

reg [3:0] burst_counter;
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
                        // slave will increment the adress " HADDR <= HADDR + (4 << HSIZE); "
                        burst_counter <= burst_counter + 1;
                        HTRANS <= SEQ;
                    end else begin
                        HTRANS <= IDLE;
                    end
                end
            end
            SEQ:begin
                if (HREADY) begin
                        // slave will increment the adress " HADDR <= HADDR + (4 << HSIZE); "
                        burst_counter <= burst_counter + 1;
                    if (!work)
                    HTRANS <= BUSY;
                    else if (burst_counter < HBURST)
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
always @(posedge HCLK) begin
    HADDR <= cpu_inst[63:32];
    HWDATA <= cpu_inst[31:0];
    HSIZE <= cpu_cont[6:4];  
    HWRITE <= cpu_cont[0];   
    HBURST <= cpu_cont[3:1];
    work <= cpu_cont[7];
end
endmodule