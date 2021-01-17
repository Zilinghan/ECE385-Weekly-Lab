module ALU(
    input logic [15:0] A, B,
    input logic [1:0] ALUK,
    output logic [15:0] ALU_Out
);

    always_comb
    begin
        unique case (ALUK)
            2'b00: ALU_Out = A+B;
            2'b01: ALU_Out = A&B;
            2'b10: ALU_Out = ~A;
            2'b11: ALU_Out = A;
        endcase
    end

endmodule