module B_VPE_SLAVE(
    input        CLK,
    input        RESET_N,
    input [59:0] V,
    input [59:0] WL_SW,
    input        WL_SIGN,
    input [7:0]  BL_EN,
    input [31:0] BL_SI,
    input [31:0] BL_SL,
    input [31:0] BL_SR,
    input        VUL_EN,
    input        SRAM_STATE,
    input        VAR_STATE,
    input        V_PRE,
    input        SATISFY_UP,
    input        SATISFY_LEFT,
    input        MERGE,
    output       VI_READOUT,
    output       VI_BUS,
    output [6:0] SUM_OUT,
    output       SATISFY
);

    wire        wCLK;
    wire        wRESET_N;
    wire [59:0] wV;
    wire [59:0] wWL_SW;
    wire        wWL_SIGN;
    wire [7:0]  wBL_EN;
    wire [31:0] wBL_SI, wBL_SL, wBL_SR;
    wire        wVUL_EN;
    wire        wSRAM_STATE;
    wire        wVAR_STATE;
    wire        wV_PRE;
    wire        wSATISFY_UP;
    wire        wSATISFY_LEFT;
    wire        wVI_READOUT;
    wire        wVI_BUS;
    
    wire [31:0] wC0, wC1;
    wire [6:0]  wSUM;
    wire        wMERGE;
    wire [31:0] wSATISFY_CLAUSE;
    
    assign wCLK          = CLK;
    assign wRESET_N      = RESET_N;
    assign wV            = V;
    assign wWL_SW        = WL_SW;
    assign wWL_SIGN      = WL_SIGN;
    assign wBL_EN        = BL_EN;
    assign wBL_SI        = BL_SI;
    assign wBL_SL        = BL_SL;
    assign wBL_SR        = BL_SR;
    assign wVUL_EN       = VUL_EN;
    assign wSRAM_STATE   = SRAM_STATE;
    assign wVAR_STATE    = VAR_STATE;
    assign wV_PRE        = V_PRE;
    assign wSATISFY_UP   = SATISFY_UP;
    assign wSATISFY_LEFT = SATISFY_LEFT;
    assign wMERGE        = MERGE;
    assign VI_READOUT    = wVI_READOUT;
    assign VI_BUS        = wVI_BUS; //garbage data @unified_mode
    
    genvar i;
    generate // 123*32=3936bit SRAM
        for (i = 0; i < 32; i = i + 1) begin : CLAUSE32
            C_CLAUSE U_C_CLAUSE ( //Clause Column
            /*input       */ .CLK       (wCLK       ),
            /*input       */ .RESET_N   (wRESET_N   ),
            /*input [59:0]*/ .V         (wV         ),
            /*input [59:0]*/ .WL_SW     (wWL_SW     ),
            /*input       */ .WL_SIGN   (wWL_SIGN   ),
            /*input       */ .BL_EN     (wBL_EN[i/4]), //0~3은 wYIDX_SEL[0],4~7은 wYIDX_SEL[1],8~11은 wYIDX_SEL[2],...,28~31은 wYIDX_SEL[7]
            /*input       */ .BL_SI     (wBL_SI[i]  ),
            /*input       */ .BL_SL     (wBL_SL[i]  ),
            /*input       */ .BL_SR     (wBL_SR[i]  ),
            /*input       */ .SRAM_STATE(wSRAM_STATE),
            /*output      */ .C0        (wC0[i]     ),
            /*output      */ .C1        (wC1[i]     )
            );
        end
    endgenerate
    
    assign wSATISFY_CLAUSE = (~wC0) | (wC1 ^ {32{wVI_BUS}});
    //assign SATISFY = &wSATISFY_CLAUSE;
    assign SATISFY = wMERGE ? 1'b1 : &wSATISFY_CLAUSE & wSATISFY_UP & wSATISFY_LEFT; //systolic array
    
    C_ADDER_TREE U_C_ADDER_TREE (
    /*input signed  [31:0]*/ .C0 (wC0 ),
    /*input signed  [31:0]*/ .C1 (wC1 ),
    /*output signed [6:0] */ .SUM(wSUM)
    );
    assign SUM_OUT = wSUM;
    
    C_VAR_UPD U_C_VAR_UPD (
    /*input      */ .CLK       (wCLK       ),
    /*input      */ .RESET_N   (wRESET_N   ),
    /*input [6:0]*/ .SUM       (wSUM       ),
    /*input      */ .EN        (wVUL_EN    ),
    /*input      */ .VAR_STATE (wVAR_STATE ),
    /*input      */ .V_PRE     (wV_PRE     ),
    /*output     */ .VI_READOUT(wVI_READOUT),
    /*output     */ .VI_BUS    (wVI_BUS    )
    );
    
endmodule // B_VPE_SLAVE
