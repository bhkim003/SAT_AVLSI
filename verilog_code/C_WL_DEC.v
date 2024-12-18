module C_WL_DEC(
    input  [2:0]   VPE_XIDX,  // 3bit input (selects one of 5)
    input  [5:0]   SW_IN_VPE, // 6bit input (selects one of 61)
    output [299:0] WL_SW,     // 300개의 switch wordline
    output [4:0]   WL_SIGN    // 5개의 sign wordline
);
    
    wire [2:0]   wVPE_XIDX;
    wire [5:0]   wSW_IN_VPE;
    
    reg  [4:0]   wVPE_XIDX_DEC;
    reg  [60:0]  wSW_IN_VPE_DEC;
    wire [304:0] wWL;
    wire [299:0] wWL_SW;
    wire [4:0]   wWL_SIGN;
    
    assign wVPE_XIDX  = VPE_XIDX;
    assign wSW_IN_VPE = SW_IN_VPE;
    
    integer i;
    always @(*) begin
        for (i = 0; i < 5; i = i + 1) begin
            wVPE_XIDX_DEC[i] = (wVPE_XIDX == i[2:0]);
        end
    end
    
    integer j;
    always @(*) begin
        for (j = 0; j < 61; j = j + 1) begin
            wSW_IN_VPE_DEC[j] = (wSW_IN_VPE == j[5:0]);
        end
    end
    
    genvar k, l;
    generate
        for (k = 0; k < 5; k = k + 1) begin : VPE_XIDX_DEC5
            for (l = 0; l < 61; l = l + 1) begin : SW_IN_VPE_DEC61
                assign wWL[k * 61 + l] = wVPE_XIDX_DEC[k] & wSW_IN_VPE_DEC[l];
            end
        end
    endgenerate
    
    assign wWL_SW[59:0]    = wWL[59:0];
    assign wWL_SIGN[0]     = wWL[60];
    assign wWL_SW[119:60]  = wWL[120:61];
    assign wWL_SIGN[1]     = wWL[121];
    assign wWL_SW[179:120] = wWL[181:122];
    assign wWL_SIGN[2]     = wWL[182];
    assign wWL_SW[239:180] = wWL[242:183];
    assign wWL_SIGN[3]     = wWL[243];
    assign wWL_SW[299:240] = wWL[303:244];
    assign wWL_SIGN[4]     = wWL[304];
    assign WL_SW           = wWL_SW;
    assign WL_SIGN         = wWL_SIGN;
    
endmodule // C_WL_DEC
