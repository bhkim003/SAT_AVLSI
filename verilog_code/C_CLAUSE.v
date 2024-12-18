module C_CLAUSE(
    input        CLK,
    input        RESET_N,
    input [59:0] V,
    input [59:0] WL_SW,
    input        WL_SIGN,
    input        BL_EN,
    input        BL_SI,
    input        BL_SL,
    input        BL_SR,
    input        SRAM_STATE,
    output       C0,
    output       C1
); //Clause Column

    reg [59:0] rENL, rENR;
    reg rSI, rSL, rSR;
    
    wire [59:0] wV, wWL_SW, wWLSW_BLEN, wENL, wENR;
    wire wCLK;
    wire wC0, wC1;
    wire wWL_SIGN, wWLSIGN_BLEN, wBL_EN;
    wire wVL, wVR, wSI_i, wSL_i, wSR_i, wSI_o, wSL_o, wSR_o;
    
    assign wCLK     = CLK;
    assign wWL_SW   = WL_SW;
    assign wWL_SIGN = WL_SIGN;
    assign wWLSW_BLEN = wWL_SW & {60{wBL_EN}};
    assign wWLSIGN_BLEN = wWL_SIGN & wBL_EN;
    assign wBL_EN   = BL_EN & SRAM_STATE;
    assign wSI_i    = BL_SI;
    assign wSL_i    = BL_SL;
    assign wSR_i    = BL_SR;
    
    assign wV = V;
    assign wENL = rENL;
    assign wENR = rENR;
    assign wVL = wENL[ 0] ? wV[ 0] : wENL[ 1] ? wV[ 1] : wENL[ 2] ? wV[ 2] : wENL[ 3] ? wV[ 3] : wENL[ 4] ? wV[ 4] : wENL[ 5] ? wV[ 5] : wENL[ 6] ? wV[ 6] : wENL[ 7] ? wV[ 7] : wENL[ 8] ? wV[ 8] : wENL[ 9] ? wV[ 9] : 
                 wENL[10] ? wV[10] : wENL[11] ? wV[11] : wENL[12] ? wV[12] : wENL[13] ? wV[13] : wENL[14] ? wV[14] : wENL[15] ? wV[15] : wENL[16] ? wV[16] : wENL[17] ? wV[17] : wENL[18] ? wV[18] : wENL[19] ? wV[19] : 
                 wENL[20] ? wV[20] : wENL[21] ? wV[21] : wENL[22] ? wV[22] : wENL[23] ? wV[23] : wENL[24] ? wV[24] : wENL[25] ? wV[25] : wENL[26] ? wV[26] : wENL[27] ? wV[27] : wENL[28] ? wV[28] : wENL[29] ? wV[29] : 
                 wENL[30] ? wV[30] : wENL[31] ? wV[31] : wENL[32] ? wV[32] : wENL[33] ? wV[33] : wENL[34] ? wV[34] : wENL[35] ? wV[35] : wENL[36] ? wV[36] : wENL[37] ? wV[37] : wENL[38] ? wV[38] : wENL[39] ? wV[39] : 
                 wENL[40] ? wV[40] : wENL[41] ? wV[41] : wENL[42] ? wV[42] : wENL[43] ? wV[43] : wENL[44] ? wV[44] : wENL[45] ? wV[45] : wENL[46] ? wV[46] : wENL[47] ? wV[47] : wENL[48] ? wV[48] : wENL[49] ? wV[49] : 
                 wENL[50] ? wV[50] : wENL[51] ? wV[51] : wENL[52] ? wV[52] : wENL[53] ? wV[53] : wENL[54] ? wV[54] : wENL[55] ? wV[55] : wENL[56] ? wV[56] : wENL[57] ? wV[57] : wENL[58] ? wV[58] : wENL[59] ? wV[59] : 1'b0;
    assign wVR = wENR[ 0] ? wV[ 0] : wENR[ 1] ? wV[ 1] : wENR[ 2] ? wV[ 2] : wENR[ 3] ? wV[ 3] : wENR[ 4] ? wV[ 4] : wENR[ 5] ? wV[ 5] : wENR[ 6] ? wV[ 6] : wENR[ 7] ? wV[ 7] : wENR[ 8] ? wV[ 8] : wENR[ 9] ? wV[ 9] : 
                 wENR[10] ? wV[10] : wENR[11] ? wV[11] : wENR[12] ? wV[12] : wENR[13] ? wV[13] : wENR[14] ? wV[14] : wENR[15] ? wV[15] : wENR[16] ? wV[16] : wENR[17] ? wV[17] : wENR[18] ? wV[18] : wENR[19] ? wV[19] : 
                 wENR[20] ? wV[20] : wENR[21] ? wV[21] : wENR[22] ? wV[22] : wENR[23] ? wV[23] : wENR[24] ? wV[24] : wENR[25] ? wV[25] : wENR[26] ? wV[26] : wENR[27] ? wV[27] : wENR[28] ? wV[28] : wENR[29] ? wV[29] : 
                 wENR[30] ? wV[30] : wENR[31] ? wV[31] : wENR[32] ? wV[32] : wENR[33] ? wV[33] : wENR[34] ? wV[34] : wENR[35] ? wV[35] : wENR[36] ? wV[36] : wENR[37] ? wV[37] : wENR[38] ? wV[38] : wENR[39] ? wV[39] : 
                 wENR[40] ? wV[40] : wENR[41] ? wV[41] : wENR[42] ? wV[42] : wENR[43] ? wV[43] : wENR[44] ? wV[44] : wENR[45] ? wV[45] : wENR[46] ? wV[46] : wENR[47] ? wV[47] : wENR[48] ? wV[48] : wENR[49] ? wV[49] : 
                 wENR[50] ? wV[50] : wENR[51] ? wV[51] : wENR[52] ? wV[52] : wENR[53] ? wV[53] : wENR[54] ? wV[54] : wENR[55] ? wV[55] : wENR[56] ? wV[56] : wENR[57] ? wV[57] : wENR[58] ? wV[58] : wENR[59] ? wV[59] : 1'b0;
    
    assign wSI_o = rSI;
    assign wSL_o = rSL;
    assign wSR_o = rSR;
    
    assign wC0 = (wVL ^ wSL_o) & (wVR ^ wSR_o); //0: satisfied, non-0: unsatisfied
    assign wC1 = wC0 ? ~wSI_o : 1'b0;
    
    assign C0 = wC0;
    assign C1 = wC1;
    
    always @(posedge wCLK or negedge RESET_N) begin //3bit SRAM
        if (!RESET_N) begin
            rSI <= 1'b0;
            rSL <= 1'b0;
            rSR <= 1'b0;
        end
        else if (wWLSIGN_BLEN) begin
            rSI <= wSI_i;
            rSL <= wSL_i;
            rSR <= wSR_i;
        end
    end
    
    genvar i;
    generate
        for (i = 0; i < 60; i = i + 1) begin : ENABLE_SWITCH60  //60x2=120bit SRAM
            always @(posedge wCLK or negedge RESET_N) begin
                if (!RESET_N) begin
                    rENL[i] <= 1'b0;
                    rENR[i] <= 1'b0;
                end
                else if (wWLSW_BLEN[i]) begin
                    rENL[i] <= wSL_i;
                    rENR[i] <= wSR_i;
                end
            end
        end
    endgenerate

endmodule // C_CLAUSE
