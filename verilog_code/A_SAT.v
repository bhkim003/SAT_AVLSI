module A_SAT(
    input         CLK,
    input         RESET_N,
    input         SRAM_STATE,
    input         VAR_STATE,
    input         PROC_STATE,
    input         SHUFFLE,
    input         MERGE,
    input  [2:0]  VPE_XIDX,
    input  [5:0]  SW_IN_VPE,
    input  [3:0]  VPE_YIDX,
    input  [2:0]  CLAUSE_IDX,
    input  [3:0]  DIN_SI,
    input  [3:0]  DIN_SL,
    input  [3:0]  DIN_SR,
    input  [4:0]  INIT_VAR,
    output [4:0]  READ_VAR,
    output        SATISFY_ALL
);

    wire         wCLK;
    wire         wRESET_N;
    wire         wSRAM_STATE;
    wire         wVAR_STATE;
    wire         wPROC_STATE;
    wire         wSHUFFLE;
    wire         wMERGE;
    wire [2:0]   wVPE_XIDX;
    wire [5:0]   wSW_IN_VPE;
    wire [3:0]   wVPE_YIDX;
    wire [2:0]   wCLAUSE_IDX;
    wire [3:0]   wDIN_SI;
    wire [3:0]   wDIN_SL;
    wire [3:0]   wDIN_SR;
    
    wire         wCLKD;
    wire         wRESET_ND;
    wire [59:0]  wV;
    wire [299:0] wWL_SW; //60x5
    wire [4:0]   wWL_SIGN;
    wire [95:0]  wBL_EN;
    wire [383:0] wBL_SI, wBL_SL, wBL_SR; //32x12
    wire [11:0]  wVUL_EN;
    wire         wSRAM_STATED;
    wire         wVAR_STATED;
    wire         wPROC_STATED;
    
    wire [4:0]   wINIT_VAR;
    wire [4:0]   wINIT_VARD;
    wire [59:0]  wV_PRE;
    wire [59:0]  wVI_READOUT;
    wire [4:0]   wREAD_VAR;
    wire [6:0]   wSUM_SLAVE;
    wire [59:0]  wSATISFY;
    
    //0:north PAD, 1_1:east PAD, 1_2~3:south PAD, 2_:west PAD
    assign wCLK          = CLK;        //0.clk
    assign wRESET_N      = RESET_N;    //0.reset
    assign wSRAM_STATE   = SRAM_STATE; //0.phase1:sram_write_mode (input variable: DIN_S*)
    assign wVAR_STATE    = VAR_STATE;  //0.phase2:var_shift_mode (input variable: wINIT_VAR)
    assign wPROC_STATE   = PROC_STATE; //0.phase3:process_mode
    assign wSHUFFLE      = SHUFFLE;    //0.shuffle in proc_state
    assign wMERGE        = MERGE;      //0.merge 0&12th VPE in proc_state
    assign wVPE_XIDX     = VPE_XIDX;   //1_1.SRAM_XSEL
    assign wSW_IN_VPE    = SW_IN_VPE;  //1_1.SRAM_XSEL
    assign wVPE_YIDX     = VPE_YIDX;   //1_2.SRAM_YSEL
    assign wCLAUSE_IDX   = CLAUSE_IDX; //1_2.SRAM_YSEL
    assign wDIN_SI       = DIN_SI;     //1_2.SRAM_DATA
    assign wDIN_SL       = DIN_SL;     //1_2.SRAM_DATA
    assign wDIN_SR       = DIN_SR;     //1_2.SRAM_DATA
    assign wINIT_VAR     = INIT_VAR;   //2.input variable
    
    C_CLK_DRV U_C_CLK_DRV(
    /*input        */ .CLK        (wCLK),
    /*input        */ .RESET_N    (wRESET_N),
    /*input        */ .SRAM_STATE (wSRAM_STATE),
    /*input        */ .VAR_STATE  (wVAR_STATE),
    /*input        */ .PROC_STATE (wPROC_STATE),
    /*input        */ .SHUFFLE    (wSHUFFLE),
    /*output       */ .CLKD       (wCLKD),
    /*output       */ .RESET_ND   (wRESET_ND),
    /*output       */ .SRAM_STATED(wSRAM_STATED), //2.sram_write mode (input variable: DIN_S*)
    /*output       */ .VAR_STATED (wVAR_STATED),  //2.var_shift mode (input variable: wINIT_VAR)
    /*output [11:0]*/ .VUL_EN     (wVUL_EN)       //3.column-by-column enable signal
    );
    
    C_WL_DEC U_C_WL_DEC (
    /*input  [2:0]  */ .VPE_XIDX (wVPE_XIDX), //all high: disable
    /*input  [5:0]  */ .SW_IN_VPE(wSW_IN_VPE), //all high: disable
    /*output [299:0]*/ .WL_SW    (wWL_SW),
    /*output [4:0]  */ .WL_SIGN  (wWL_SIGN)
    );
    
    C_BL_DRV U_C_BL_DRV ( //max pad num: 23 -> input must be equal or less than 23
    /*input  [3:0]  */ .VPE_YIDX  (wVPE_YIDX), //all high: disable
    /*input  [2:0]  */ .CLAUSE_IDX(wCLAUSE_IDX),
    /*input  [3:0]  */ .DIN_SI    (wDIN_SI),
    /*input  [3:0]  */ .DIN_SL    (wDIN_SL),
    /*input  [3:0]  */ .DIN_SR    (wDIN_SR),
    /*output [95:0] */ .BL_EN     (wBL_EN),
    /*output [383:0]*/ .BL_SI     (wBL_SI),
    /*output [383:0]*/ .BL_SL     (wBL_SL),
    /*output [383:0]*/ .BL_SR     (wBL_SR)
    );
    
    //TODO: implementing buffer...
    C_SI_DRV U_C_SI_DRV (
    /*input  [4:0]*/ .IN (wINIT_VAR),
    /*output [4:0]*/ .OUT(wINIT_VARD)
    );
    assign wV_PRE[0]     = wINIT_VARD[0];
    assign wV_PRE[12]    = wINIT_VARD[1];
    assign wV_PRE[24]    = wINIT_VARD[2];
    assign wV_PRE[36]    = wINIT_VARD[3];
    assign wV_PRE[48]    = wINIT_VARD[4];
    
    assign wV_PRE[11: 1] = wVI_READOUT[10: 0];
    assign wV_PRE[23:13] = wVI_READOUT[22:12];
    assign wV_PRE[35:25] = wVI_READOUT[34:24];
    assign wV_PRE[47:37] = wVI_READOUT[46:36];
    assign wV_PRE[59:49] = wVI_READOUT[58:48];
    
    genvar i;
    generate
        for (i = 0; i < 60; i = i + 1) begin : VPE60
            if (i == 0) begin
                B_VPE_MASTER U_B_VPE_MASTER (
                /*input       */ .CLK         (wCLKD                            ),
                /*input       */ .RESET_N     (wRESET_ND                        ),
                /*input [59:0]*/ .V           (wV                               ),
                /*input [59:0]*/ .WL_SW       (wWL_SW[(i/12+1)*60-1:(i/12)*60]  ), 
                /*input       */ .WL_SIGN     (wWL_SIGN[i/12]                   ), 
                /*input [7:0] */ .BL_EN       (wBL_EN[(i%12+1)*8-1:(i%12)*8]    ), 
                /*input [31:0]*/ .BL_SI       (wBL_SI[(i%12+1)*32-1:(i%12)*32]  ), 
                /*input [31:0]*/ .BL_SL       (wBL_SL[(i%12+1)*32-1:(i%12)*32]  ), 
                /*input [31:0]*/ .BL_SR       (wBL_SR[(i%12+1)*32-1:(i%12)*32]  ), 
                /*input       */ .VUL_EN      (wVUL_EN[i % 12]                  ), 
                /*input       */ .SRAM_STATE  (wSRAM_STATED                     ),
                /*input       */ .VAR_STATE   (wVAR_STATED                      ),
                /*input       */ .V_PRE       (wV_PRE[i]                        ),
                /*input       */ .SATISFY_UP  (1'b1                             ),
                /*input       */ .SATISFY_LEFT(1'b1                             ),
                /*input       */ .MERGE       (wMERGE                           ),
                /*input [6:0] */ .SUM_SLAVE   (wSUM_SLAVE                       ),
                /*output      */ .VI_READOUT  (wVI_READOUT[i]                   ),
                /*output      */ .VI_BUS      (wV[i]                            ),
                /*output      */ .SATISFY     (wSATISFY[i]                      )
                );
            end else if (i == 12) begin
                B_VPE_SLAVE U_B_VPE_SLAVE (
                /*input       */ .CLK         (wCLKD                            ),
                /*input       */ .RESET_N     (wRESET_ND                        ),
                /*input [59:0]*/ .V           (wV                               ),
                /*input [59:0]*/ .WL_SW       (wWL_SW[(i/12+1)*60-1:(i/12)*60]  ), 
                /*input       */ .WL_SIGN     (wWL_SIGN[i/12]                   ), 
                /*input [7:0] */ .BL_EN       (wBL_EN[(i%12+1)*8-1:(i%12)*8]    ), 
                /*input [31:0]*/ .BL_SI       (wBL_SI[(i%12+1)*32-1:(i%12)*32]  ), 
                /*input [31:0]*/ .BL_SL       (wBL_SL[(i%12+1)*32-1:(i%12)*32]  ), 
                /*input [31:0]*/ .BL_SR       (wBL_SR[(i%12+1)*32-1:(i%12)*32]  ), 
                /*input       */ .VUL_EN      (wVUL_EN[i % 12]                  ), 
                /*input       */ .SRAM_STATE  (wSRAM_STATED                     ),
                /*input       */ .VAR_STATE   (wVAR_STATED                      ),
                /*input       */ .V_PRE       (wV_PRE[i]                        ),
                /*input       */ .SATISFY_UP  (wSATISFY[0]                      ),
                /*input       */ .SATISFY_LEFT(1'b1                             ),
                /*input       */ .MERGE       (wMERGE                           ),
                /*output      */ .VI_READOUT  (wVI_READOUT[i]                   ),
                /*output      */ .VI_BUS      (wV[i]                            ),
                /*output [6:0]*/ .SUM_OUT     (wSUM_SLAVE                       ),
                /*output      */ .SATISFY     (wSATISFY[i]                      )
                );
            end else begin
                B_VPE U_B_VPE (
                /*input       */ .CLK         (wCLKD                            ),
                /*input       */ .RESET_N     (wRESET_ND                        ),
                /*input [59:0]*/ .V           (wV                               ),
                /*input [59:0]*/ .WL_SW       (wWL_SW[(i/12+1)*60-1:(i/12)*60]  ), //0~11은 wWL_SW[59:0], 12~23은 wWL_SW[119:60],...,48~59은 wWL_SW[299:240]
                /*input       */ .WL_SIGN     (wWL_SIGN[i/12]                   ), //0~11은 wWL_SIGN[0], 12~23은 wWL_SIGN[1],...,48~59은 wWL_SIGN[4]
                /*input [7:0] */ .BL_EN       (wBL_EN[(i%12+1)*8-1:(i%12)*8]    ), //0,12,24,...은 wBL_EN[7:0], 1,13,25,...은 wBL_EN[15:8], 11,23,35,...은 wBL_EN[95:88]
                /*input [31:0]*/ .BL_SI       (wBL_SI[(i%12+1)*32-1:(i%12)*32]  ), //0,12,24,...은 wSI[31:0], 1,13,25,...은 wSI[63:32], 11,23,35,...은 wSI[383:352]
                /*input [31:0]*/ .BL_SL       (wBL_SL[(i%12+1)*32-1:(i%12)*32]  ), //0,12,24,...은 wSL[31:0], 1,13,25,...은 wSL[63:32], 11,23,35,...은 wSL[383:352]
                /*input [31:0]*/ .BL_SR       (wBL_SR[(i%12+1)*32-1:(i%12)*32]  ), //0,12,24,...은 wSR[31:0], 1,13,25,...은 wSR[63:32], 11,23,35,...은 wSR[383:352]
                /*input       */ .VUL_EN      (wVUL_EN[i % 12]                  ), //0,12,24,36,48은 wVUL_EN[0], 1,13,25,37,49은 wVUL_EN[1],...,11,23,35,47,59은 wVUL_EN[11]
                /*input       */ .SRAM_STATE  (wSRAM_STATED                     ),
                /*input       */ .VAR_STATE   (wVAR_STATED                      ),
                /*input       */ .V_PRE       (wV_PRE[i]                        ),
                /*input       */ .SATISFY_UP  (i<12 ? 1'b1 : wSATISFY[(i+48)%60]),
                /*input       */ .SATISFY_LEFT(i%12==0 ? 1'b1 : wSATISFY[i-1]   ),
                /*output      */ .VI_READOUT  (wVI_READOUT[i]                   ),
                /*output      */ .VI_BUS      (wV[i]                            ),
                /*output      */ .SATISFY     (wSATISFY[i]                      )
                );
            end
        end
    endgenerate
    
    assign wREAD_VAR[0] = wVI_READOUT[11];
    assign wREAD_VAR[1] = wVI_READOUT[23];
    assign wREAD_VAR[2] = wVI_READOUT[35];
    assign wREAD_VAR[3] = wVI_READOUT[47];
    assign wREAD_VAR[4] = wVI_READOUT[59];
    assign SATISFY_ALL  = wSATISFY[59];
    C_SO_DRV U_C_SO_DRV ( //output variable
    /*input  [4:0]*/ .IN (wREAD_VAR),
    /*output [4:0]*/ .OUT(READ_VAR)
    );
    
endmodule // A_SAT
