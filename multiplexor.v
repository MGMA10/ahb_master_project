module multiplexor (
    input [1:0] HADDR,  
    input [31:0] X1,X2,X3,X4,
    input Y1,Y2,Y3,Y4,
    input Z1,Z2,Z3,Z4,
    output [31:0] X,
    input Y,
    input Z
);
    always @(*) begin
        case (HADDR)
            0:begin
                X=X1;
                Y=Y1;
                Z=Z1;
            end 
            1:begin
                X=X2;
                Y=Y2;
                Z=Z2;
            end 
            2:begin
                X=X3;
                Y=Y3;
                Z=Z3;
            end 
            3:begin
                X=X4;
                Y=Y4;
                Z=Z4;
            end 
            default: begin
                X=X1;
                Y=Y1;
                Z=Z1;
            end 
        endcase
    end


endmodule