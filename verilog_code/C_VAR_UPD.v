module C_VAR_UPD(
    input       CLK,
    input       RESET_N,
    input [6:0] SUM,
    input       EN,
    input       VAR_STATE,
    input       V_PRE,
    output      VI_READOUT,
    output      VI_BUS
);

    reg rVI;
    
    wire [6:0] wSUM;
    wire wVAR_STATE, wV_PRE, wEN, wCLK;
    
    wire wZERO_DET654, wZERO_DET32, wZERO_DET10, wZERO_DET, wMSB_B, wVI_oB, wUPDATE_VAL;
    wire wVI_i, wCLKD;
    wire wVI_o, wVI_READOUT_B, wVI_BUSPRE1_B, wVI_BUSPRE1, wVI_BUSPRE2_B, wVI_BUSPRE2, wVI_BUSPRE_B;
    
    assign wSUM         = SUM;
    assign wVAR_STATE   = VAR_STATE;
    assign wV_PRE       = V_PRE;
    
    assign wZERO_DET654 = (wSUM[6] | wSUM[5] | wSUM[4]);
    assign wZERO_DET32  = (wSUM[3] | wSUM[2]);
    assign wZERO_DET10  = (wSUM[1] | wSUM[0]);
    assign wZERO_DET    = ~(wZERO_DET654 | wZERO_DET32 | wZERO_DET10);
    assign wVI_oB       = ~wVI_o;
    assign wMSB_B       = ~wSUM[6]; // 1: SUM is positive_num, 0: SUM is negative_num
    assign wUPDATE_VAL  = wZERO_DET ? wVI_oB : wMSB_B;
    assign wVI_i        = wVAR_STATE ? wV_PRE : wUPDATE_VAL;
    assign wCLKD        = CLK & EN;
    
    always @(posedge wCLKD or negedge RESET_N) begin
        if (!RESET_N) begin
            rVI <= 1'b0;
        end
        else begin
            rVI <= wVI_i;
        end
    end
    
    //TODO: implementing buffer...
    assign wVI_o         = rVI;
    assign wVI_READOUT_B = ~wVI_o;
    assign VI_READOUT    = ~wVI_READOUT_B; // next block's V_PRE
    assign wVI_BUSPRE1_B = ~wVI_o;
    assign wVI_BUSPRE1   = ~wVI_BUSPRE1_B;
    assign wVI_BUSPRE2_B = ~wVI_BUSPRE1;
    assign wVI_BUSPRE2   = ~wVI_BUSPRE2_B;
    assign wVI_BUSPRE_B  = ~wVI_BUSPRE2;
    assign VI_BUS        = ~wVI_BUSPRE_B;
    
endmodule // C_VAR_UPD
