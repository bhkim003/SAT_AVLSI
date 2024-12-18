module C_ADDER_TREE(
    input [31:0] C0,
    input [31:0] C1,
    output [6:0] SUM
);

    wire [47:0] wLEV1; // 16개의 3비트 값을 1차원 벡터로 선언 (16 * 3 = 48비트)
    wire [31:0] wLEV2; // 8개의 4비트 값을 1차원 벡터로 선언 (8 * 4 = 32비트)
    wire [19:0] wLEV3; // 4개의 5비트 값을 1차원 벡터로 선언 (4 * 5 = 20비트)
    wire [11:0] wLEV4; // 2개의 6비트 값을 1차원 벡터로 선언 (2 * 6 = 12비트)
    
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : LEV1_GEN
            assign wLEV1[(3*i) +: 3] = {{1{C1[2*i]}},     C1[2*i],     C0[2*i]} + 
                                       {{1{C1[2*i + 1]}}, C1[2*i + 1], C0[2*i + 1]};
        end
    endgenerate
    
    generate
        for (i = 0; i < 8; i = i + 1) begin : LEV2_GEN
            assign wLEV2[(4*i) +: 4] = {{1{wLEV1[(3*(2*i + 1)) + 2]}}, wLEV1[(3*(2*i + 1)) +: 3]} +
                                       {{1{wLEV1[(3*2*i) + 2]}},       wLEV1[(3*2*i) +: 3]};
        end
    endgenerate
    
    generate
        for (i = 0; i < 4; i = i + 1) begin : LEV3_GEN
            assign wLEV3[(5*i) +: 5] = {{1{wLEV2[(4*(2*i + 1)) + 3]}}, wLEV2[(4*(2*i + 1)) +: 4]} +
                                       {{1{wLEV2[(4*2*i) + 3]}},       wLEV2[(4*2*i) +: 4]};
        end
    endgenerate
    
    generate
        for (i = 0; i < 2; i = i + 1) begin : LEV4_GEN
            assign wLEV4[(6*i) +: 6] = {{1{wLEV3[(5*(2*i + 1)) + 4]}}, wLEV3[(5*(2*i + 1)) +: 5]} +
                                       {{1{wLEV3[(5*2*i) + 4]}},       wLEV3[(5*2*i) +: 5]};
        end
    endgenerate
    
    assign SUM = {{1{wLEV4[11]}}, wLEV4[11:6]} + {{1{wLEV4[5]}}, wLEV4[5:0]};
    
endmodule // C_ADDER_TREE