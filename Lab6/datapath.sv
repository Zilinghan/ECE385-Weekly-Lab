module datapath(
    input logic Clk, Reset,
    input logic [15:0] MDR_In,
    input logic LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_CC, LD_REG, LD_PC, LD_LED,			
	input logic GatePC, GateMDR, GateALU, GateMARMUX,	
	input logic [1:0] PCMUX,
	input logic DRMUX, SR1MUX, SR2MUX, ADDR1MUX,
	input logic [1:0] ADDR2MUX, ALUK,
	input logic MIO_EN,
	output logic BEN,
	output logic [15:0] MAR, MDR, IR, PC,
	output logic [11:0] LED
);

logic [15:0] Bus;
logic n,z,p;
logic [2:0] DR, SR1, SR2;
logic [15:0] SR1_OUT, SR2_Out;
logic [15:0] A, B, ALU_Out;
logic [15:0] ADDR1MUX_Out, ADDR2MUX_Out, ADDR_Out;
logic [15:0] PCMUX_Out;

// Registers
RegFile RegFile_inst(.*);
IR IR_inst(.*);
PC PC_inst(.*);
nzp nzp_inst(.*);
BEN BEN_inst(.*,.IR_11_9(IR[11:9]));
MAR MAR_inst(.*);
MDR MDR_inst(.*);
LEDs LEDs_inst(.*,.IR_11_0(IR[11:0]));

// ALU
ALU ALU_inst(.*);

// Datapath, including MUX
always_comb
begin
	// ALU_A
	A = SR1_OUT;
	// ALU_B
    unique case (SR2MUX)
        1'b0: B = SR2_Out;
        1'b1: B = {{11{IR[4]}},IR[4:0]};
	endcase

	// SR1
	unique case (SR1MUX)
		1'b0: SR1 = IR[11:9];
		1'b1: SR1 = IR[8:6];
	endcase
	// SR2
	SR2 = IR[2:0];
	// DR
	unique case (DRMUX)
		1'b0: DR = IR[11:9];
		1'b1: DR = 3'b111;
	endcase

	// ADDR1MUX
    unique case (ADDR1MUX)
        1'b0: ADDR1MUX_Out = PC;
        1'b1: ADDR1MUX_Out = SR1_OUT;
	endcase

	// ADDR2MUX
	unique case (ADDR2MUX)
		2'b00: ADDR2MUX_Out = 16'h0;
		2'b01: ADDR2MUX_Out = {{10{IR[5]}},IR[5:0]};
		2'b10: ADDR2MUX_Out = {{7{IR[8]}},IR[8:0]};
		2'b11: ADDR2MUX_Out = {{5{IR[10]}},IR[10:0]};
	endcase

	// ADDRMUX
	ADDR_Out = ADDR1MUX_Out + ADDR2MUX_Out;

	// PCMUX
	unique case (PCMUX)
		2'b00: PCMUX_Out = PC + 1'b1;
		2'b10: PCMUX_Out = ADDR_Out;
		2'b01: PCMUX_Out = Bus;
		default: PCMUX_Out = 16'b0;
	endcase

end

// Gate
always_comb
begin
	unique case({GatePC, GateMDR, GateALU, GateMARMUX})
		4'b1000: Bus = PC;
		4'b0100: Bus = MDR;
		4'b0010: Bus = ALU_Out;
		4'b0001: Bus = ADDR_Out;
		default: Bus = 16'b0;				
	endcase
end

endmodule