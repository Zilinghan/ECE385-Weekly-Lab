module lab5_toplevel
(
    input logic[7:0] S,
    input logic Clk, Reset, Run, ClearA_LoadB,
    output logic[6:0] AhexU, AhexL, BhexU, BhexL,
    output logic[7:0] Aval, Bval,
    output logic X
);

    logic[6:0] AhexU_comb, AhexL_comb, BhexU_comb, BhexL_comb;
    logic[8:0] adder;
    logic AB_shift;
    logic fn,shift,loadXA,loadB,clearXA,clearB;
    logic Reset_sync,Run_sync,ClearA_LoadB_sync;

    add_sub9 add_sub9_inst(.A(Aval),.B(S),.fn(fn),.S(adder));

    reg_8 reg_A(.Clk(Clk),.Reset(clearXA),.Shift_In(X),.Load(loadXA),.Shift_En(shift),.D(adder[7:0]),.Shift_Out(AB_shift),.Data_Out(Aval));
    reg_8 reg_B(.Clk(Clk),.Reset(clearB),.Shift_In(AB_shift),.Load(loadB),.Shift_En(shift),.D(S),.Shift_Out(),.Data_Out(Bval));
    extend_bit extend_bit_X(.Clk(Clk),.ld(loadXA),.Reset(clearXA),.D(adder[8]),.Q(X));

    control control_unit(.Clk(Clk),.Reset(Reset_sync),.Run(Run_sync),.ClearA_LoadB(ClearA_LoadB_sync),.B1(Bval[1]),.B0(Bval[0]),.fn(fn),.shift(shift),.loadXA(loadXA),.loadB(loadB),.clearXA(clearXA),.clearB(clearB));

    always_ff @(posedge Clk)
    begin        
        AhexU <= AhexU_comb;
        AhexL <= AhexL_comb;
        BhexU <= BhexU_comb;
        BhexL <= BhexL_comb;   
    end

    HexDriver AhexU_inst(.In0(Aval[7:4]),.Out0(AhexU_comb));
    HexDriver AhexL_inst(.In0(Aval[3:0]),.Out0(AhexL_comb));
    HexDriver BhexU_inst(.In0(Bval[7:4]),.Out0(BhexU_comb));
    HexDriver BhexL_inst(.In0(Bval[3:0]),.Out0(BhexL_comb));

    sync Reset_Sync(.Clk(Clk),.d(!Reset),.q(Reset_sync));
    sync Run_Sync(.Clk(Clk),.d(!Run),.q(Run_sync));
    sync ClearA_LoadB_Sync(.Clk(Clk),.d(!ClearA_LoadB),.q(ClearA_LoadB_sync));

endmodule
