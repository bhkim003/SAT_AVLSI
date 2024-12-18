module C_CLK_DRV(
    input         CLK,
    input         RESET_N,
    input         SRAM_STATE,
    input         VAR_STATE,
    input         PROC_STATE,
    input         SHUFFLE,
    output        CLKD,
    output        RESET_ND,
    output        SRAM_STATED,
    output        VAR_STATED,
    output [11:0] VUL_EN
);

    reg [11:0]  rCUR_VPE;
    wire [11:0] wSHF_VPE;
    wire wCLKB;
    wire wCLKD;
    wire wRESET_NB;
    wire wRESET_ND;
    wire wSRAM_STATE;
    wire wSRAM_STATEB;
    wire wSRAM_STATED;
    wire wVAR_STATE;
    wire wVAR_STATEB;
    wire wVAR_STATED;
    wire wPROC_STATE;
    wire wPROC_STATEB;
    wire wPROC_STATED;
    wire wSHUFFLE;
    
    assign wCLKB        = ~CLK;
    assign wRESET_NB    = ~RESET_N;
    assign wRESET_ND    = ~wRESET_NB;
    assign RESET_ND     =  wRESET_ND;
    assign wSRAM_STATE  =  SRAM_STATE;
    assign wSRAM_STATEB = ~wSRAM_STATE;
    assign wSRAM_STATED = ~wSRAM_STATEB;
    assign wVAR_STATE   =  VAR_STATE;
    assign wVAR_STATEB  = ~wVAR_STATE;
    assign wVAR_STATED  = ~wVAR_STATEB;
    assign wPROC_STATE  =  PROC_STATE;
    assign wPROC_STATEB = ~wPROC_STATE;
    assign wPROC_STATED = ~wPROC_STATEB;
    assign wSHUFFLE     =  SHUFFLE;
    
    always @(posedge wCLKB or negedge wRESET_ND) begin
        if (!wRESET_ND) begin
            rCUR_VPE <= 12'b001;
        end
        else if (wPROC_STATED) begin
            rCUR_VPE <= {rCUR_VPE[10:0], rCUR_VPE[11]};
        end
    end
    
    assign wSHF_VPE = wSHUFFLE ? {rCUR_VPE[6],  rCUR_VPE[5],  rCUR_VPE[7],  rCUR_VPE[4],
                                  rCUR_VPE[8],  rCUR_VPE[3],  rCUR_VPE[9],  rCUR_VPE[2],
                                  rCUR_VPE[10], rCUR_VPE[1],  rCUR_VPE[11], rCUR_VPE[0]}
                               :  rCUR_VPE;
    
    assign wCLKD       =~wCLKB;
    assign CLKD        = wCLKD;
    assign SRAM_STATED = wSRAM_STATED;
    assign VAR_STATED  = wVAR_STATED;
    assign VUL_EN      = wSRAM_STATE ? 12'h000 : 
                         wVAR_STATE  ? 12'hFFF : 
                                       wSHF_VPE;
    
endmodule // C_CLK_DRV
