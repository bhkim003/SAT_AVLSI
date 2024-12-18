module C_BL_DRV(
    input  [3:0]   VPE_YIDX,   // 4bit input (select one of 12)
    input  [2:0]   CLAUSE_IDX, // 3bit input (divide 32 columns into 8 groups -> selected group contains 4 columns)
    input  [3:0]   DIN_SI,     // 4bit input (per 4*CLAUSE_YIDX)
    input  [3:0]   DIN_SL,     // 4bit input (per 4*CLAUSE_YIDX)
    input  [3:0]   DIN_SR,     // 4bit input (per 4*CLAUSE_YIDX)
    output [95:0]  BL_EN,      // 8*12=96개의 column index select line
    output [383:0] BL_SI,      // 4*8*12=384개의 sign bitline
    output [383:0] BL_SL,      // 4*8*12=384개의 left switch bitline
    output [383:0] BL_SR       // 4*8*12=384개의 right switch bitline
);

    wire [3:0]   wVPE_YIDX;
    wire [2:0]   wCLAUSE_IDX;
    
    reg [11:0]   wVPE_YIDX_DEC;
    reg [7:0]    wCLAUSE_IDX_DEC;
    wire [95:0]  wYIDX_SEL;
    
    wire [3:0]   wDIN_SI;
    wire [3:0]   wDIN_SL;
    wire [3:0]   wDIN_SR;
    wire [383:0] wBL_SI;
    wire [383:0] wBL_SL;
    wire [383:0] wBL_SR;
    
    assign wVPE_YIDX   = VPE_YIDX;
    assign wCLAUSE_IDX = CLAUSE_IDX;
    
    integer i;
    always @(*) begin
        for (i = 0; i < 12; i = i + 1) begin
            wVPE_YIDX_DEC[i] = (wVPE_YIDX == i[3:0]);
        end
    end
    
    integer j;
    always @(*) begin
        for (j = 0; j < 8; j = j + 1) begin
            wCLAUSE_IDX_DEC[j] = (wCLAUSE_IDX == j[2:0]);
        end
    end
    
    genvar k, l;
    generate
        for (k = 0; k < 12; k = k + 1) begin : VPE_YIDX_DEC12
            for (l = 0; l < 8; l = l + 1) begin : CLAUSE_IDX_DEC8
                assign wYIDX_SEL[k * 8 + l] = wVPE_YIDX_DEC[k] & wCLAUSE_IDX_DEC[l];
            end
        end
    endgenerate
    
    assign wDIN_SI = DIN_SI;
    assign wDIN_SL = DIN_SL;
    assign wDIN_SR = DIN_SR;
    
    genvar m;
    generate
        for (m = 0; m < 96; m = m + 1) begin : BL96
            assign wBL_SI[m * 4 +: 4] = wYIDX_SEL[m] ? wDIN_SI : 4'b0;
            assign wBL_SL[m * 4 +: 4] = wYIDX_SEL[m] ? wDIN_SL : 4'b0;
            assign wBL_SR[m * 4 +: 4] = wYIDX_SEL[m] ? wDIN_SR : 4'b0;
        end
    endgenerate
    
    assign BL_EN = wYIDX_SEL;
    assign BL_SI = wBL_SI;
    assign BL_SL = wBL_SL;
    assign BL_SR = wBL_SR;
    
endmodule // C_BL_DRV
