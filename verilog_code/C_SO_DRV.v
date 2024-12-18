module C_SO_DRV(
    input  [4:0] IN,
    output [4:0] OUT
);

    wire [4:0] wIN_B;
    
    assign wIN_B = ~IN;
    assign OUT   = ~wIN_B;
    
endmodule // C_SO_DRV
