module C_VAR_UPD(
    input       CLK,
    input       RESET_N,
    input [5:0] SUM_UP,
    input [5:0] SUM_DOWN,
    input       EN,
    input       VAR_STATE,
    input       V_PRE,
    input       STOCHASTIC_MODE,
    output      VI_READOUT,
    output      VI_BUS
);

    reg rVI;
    reg [1:0] rLFSR;
    
    wire [5:0] wSUM_UP;
    wire [5:0] wSUM_DOWN;
    wire wVAR_STATE, wV_PRE, wEN, wCLK;
    wire wSTOCHASTIC_MODE;
    
    wire wVI_oB, wUPDATE_VAL;
    wire wVI_i, wCLKD;
    wire wVI_o, wVI_READOUT_B, wVI_BUSPRE1_B, wVI_BUSPRE1, wVI_BUSPRE2_B, wVI_BUSPRE2, wVI_BUSPRE_B;
    

    wire [5:0] wSTO_SUM_UP_GATE;
    wire [5:0] wSTO_SUM_DOWN_GATE;
    wire [7:0] wSTO_DOWN_POWER;
    wire [5:0] wSTO_UP_PLUS_DOWN; // using 6bit (enough)
    wire [7:0] wSTO_UP_POWER;
    wire wSTO_POWER_SAME;
    wire wSTO_UP_WIN;


    assign wSUM_UP      = SUM_UP;
    assign wSUM_DOWN    = SUM_DOWN;
    assign wVAR_STATE   = VAR_STATE;
    assign wV_PRE       = V_PRE;
    assign wSTOCHASTIC_MODE       = STOCHASTIC_MODE;

    assign wZERO_DET    = (wSUM_UP == wSUM_DOWN);
    assign wSUM_UP_WIN = (wSUM_UP > wSUM_DOWN);
    
    assign wVI_oB       = ~wVI_o;
    
    assign wCLKD        = CLK & EN;
    assign wCLKD_STO        = wCLKD & wSTOCHASTIC_MODE & ~wZERO_DET;

    assign wSTO_SUM_UP_GATE = wSTOCHASTIC_MODE ? wSUM_UP : 6'b0;
    assign wSTO_SUM_DOWN_GATE = wSTOCHASTIC_MODE ? wSUM_DOWN : 6'b0;
    assign wSTO_DOWN_POWER = (wSTO_SUM_UP_GATE<<2);
    assign wSTO_UP_PLUS_DOWN = wSTO_SUM_UP_GATE + wSTO_SUM_DOWN_GATE;
    assign wSTO_UP_POWER = wSTO_UP_PLUS_DOWN * rLFSR;
    assign wSTO_POWER_SAME = (wSTO_UP_POWER == wSTO_DOWN_POWER);
    assign wSTO_UP_WIN = (wSTO_UP_POWER > wSTO_DOWN_POWER);
    
    assign wUPDATE_VAL  = wZERO_DET ? wVI_oB : wSTOCHASTIC_MODE ?  wSTO_POWER_SAME?wVI_oB:wSTO_UP_WIN  : wSUM_UP_WIN;
    assign wVI_i        = wVAR_STATE ? wV_PRE : wUPDATE_VAL;

    always @(posedge wCLKD or negedge RESET_N) begin
        if (!RESET_N) begin
            rVI <= 1'b0;
        end
        else begin
            rVI <= wVI_i;
        end
    end


    //LFSR
    always @(posedge wCLKD_STO or negedge RESET_N) begin
        if (!RESET_N) begin
            rLFSR <= 2'b11;
        end
        else begin
            rLFSR <= {rLFSR[0], rLFSR[1]^rLFSR[0]};
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
