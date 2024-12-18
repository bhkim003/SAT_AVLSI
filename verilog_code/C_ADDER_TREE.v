module C_ADDER_TREE(
    input [31:0] C0,
    input [31:0] C1,
    output [5:0] SUM_UP,
    output [5:0] SUM_DOWN
);
    wire [31:0] wLEV1_DOWN; // 16개의 2비트 값을 1차원 벡터로 선언 (16 * 2 = 32비트)
    wire [23:0] wLEV2_DOWN; // 8개의 3비트 값을 1차원 벡터로 선언 (8 * 3 = 24비트)
    wire [15:0] wLEV3_DOWN; // 4개의 4비트 값을 1차원 벡터로 선언 (4 * 4 = 16비트)
    wire [9:0] wLEV4_DOWN; // 2개의 5비트 값을 1차원 벡터로 선언 (2 * 5 = 10비트)

    wire [31:0] wLEV1_UP; // 16개의 2비트 값을 1차원 벡터로 선언 (16 * 2 = 32비트)
    wire [23:0] wLEV2_UP; // 8개의 3비트 값을 1차원 벡터로 선언 (8 * 3 = 24비트)
    wire [15:0] wLEV3_UP; // 4개의 4비트 값을 1차원 벡터로 선언 (4 * 4 = 16비트)
    wire [9:0] wLEV4_UP; // 2개의 5비트 값을 1차원 벡터로 선언 (2 * 5 = 10비트)
    
    genvar g_i;
    generate
        for (g_i = 0; g_i < 16; g_i = g_i + 1) begin : LEV1_GEN
            assign wLEV1_UP[(2*g_i) +: 2] = (~C1[2*g_i] & C0[2*g_i]) + (~C1[(2*g_i) + 1] & C0[(2*g_i) + 1]);
            assign wLEV1_DOWN[(2*g_i) +: 2] = C1[2*g_i] + C1[(2*g_i) + 1];
        end
    endgenerate
    
    genvar g_j;
    generate
        for (g_j = 0; g_j < 8; g_j = g_j + 1) begin : LEV2_GEN
            assign wLEV2_UP[(3*g_j) +: 3] = wLEV1_UP[(2*(2*g_j + 1)) +: 2] + wLEV1_UP[(2*(2*g_j)) +: 2];
            assign wLEV2_DOWN[(3*g_j) +: 3] = wLEV1_DOWN[(2*(2*g_j + 1)) +: 2] + wLEV1_DOWN[(2*(2*g_j)) +: 2];
        end
    endgenerate
    
    genvar g_k;
    generate
        for (g_k = 0; g_k < 4; g_k = g_k + 1) begin : LEV3_GEN
            assign wLEV3_UP[(4*g_k) +: 4] = wLEV2_UP[(3*(2*g_k + 1)) +: 3] + wLEV2_UP[(3*(2*g_k)) +: 3];
            assign wLEV3_DOWN[(4*g_k) +: 4] = wLEV2_DOWN[(3*(2*g_k + 1)) +: 3] + wLEV2_DOWN[(3*(2*g_k)) +: 3];
        end
    endgenerate
    
    genvar g_l;
    generate
        for (g_l = 0; g_l < 2; g_l = g_l + 1) begin : LEV4_GEN
            assign wLEV4_UP[(5*g_l) +: 5] = wLEV3_UP[(4*(2*g_l + 1)) +: 4] + wLEV3_UP[(4*(2*g_l)) +: 4];
            assign wLEV4_DOWN[(5*g_l) +: 5] = wLEV3_DOWN[(4*(2*g_l + 1)) +: 4] + wLEV3_DOWN[(4*(2*g_l)) +: 4];
        end
    endgenerate
    
    assign SUM_DOWN = wLEV4_DOWN[9:5] + wLEV4_DOWN[4:0];
    assign SUM_UP = wLEV4_UP[9:5] + wLEV4_UP[4:0];
    
endmodule // C_ADDER_TREE