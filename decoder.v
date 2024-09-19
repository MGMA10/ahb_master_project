module decoder (
    input  [1:0] HADDR,   
    output [3:0] HSEL     
);
always @(*) begin
    case (HADDR)
        0: HSEL = 4'b0001;
        1: HSEL = 4'b0010;
        2: HSEL = 4'b0100;
        3: HSEL = 4'b1000;
        default: HSEL = 4'b0001;
    endcase
end

endmodule
