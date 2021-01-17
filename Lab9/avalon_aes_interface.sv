/************************************************************************
Avalon-MM Interface for AES Decryption IP Core

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department

Register Map:

 0-3 : 4x 32bit AES Key
 4-7 : 4x 32bit AES Encrypted Message
 8-11: 4x 32bit AES Decrypted Message
   12: Not Used
	13: Not Used
   14: 32bit Start Register
   15: 32bit Done Register

************************************************************************/

module avalon_aes_interface (
	// Avalon Clock Input
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,						// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,		// Avalon-MM Byte Enable
	input  logic [3:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,	// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,	// Avalon-MM Read Data
	
	// Exported Conduit
	output logic [31:0] EXPORT_DATA		// Exported Conduit Signal to LEDs
);

	logic [31:0] Reg[16];
	logic [31:0] Reg_Next[16];
	logic AES_DONE;
	logic [127:0] AES_MSG_DE;

    always_ff @ (posedge CLK)
	begin
        for(int i = 0; i < 16; i++)
        begin
            Reg[i] <= Reg_Next[i];
        end		
	end
	
	always_comb
    begin
		for(int i = 0; i < 16; i++)
        begin
            Reg_Next[i] = Reg[i];
        end
		Reg_Next[8] = AES_MSG_DE[127:96];
		Reg_Next[9] = AES_MSG_DE[95:64];
		Reg_Next[10] = AES_MSG_DE[63:32];
		Reg_Next[11] = AES_MSG_DE[31:0];
		Reg_Next[15] = {15'b0,AES_DONE};
		AVL_READDATA = 32'h0;
	 	if (RESET)
            for(int i = 0; i < 16; i++)
            begin
                Reg_Next[i] = 32'h0;
            end
		else if (AVL_CS)
		begin
			if (AVL_READ)
			begin
				AVL_READDATA = Reg[AVL_ADDR];
			end
			if (AVL_WRITE)
			begin
				case (AVL_BYTE_EN)
					4'b1111: Reg_Next[AVL_ADDR] = AVL_WRITEDATA;
					4'b1100: Reg_Next[AVL_ADDR] = {AVL_WRITEDATA[31:16],Reg[AVL_ADDR][15:0]};
					4'b0011: Reg_Next[AVL_ADDR] = {Reg[AVL_ADDR][31:16],AVL_WRITEDATA[15:0]};
					4'b1000: Reg_Next[AVL_ADDR] = {AVL_WRITEDATA[31:24],Reg[AVL_ADDR][23:0]};
					4'b0100: Reg_Next[AVL_ADDR] = {Reg[AVL_ADDR][31:24],AVL_WRITEDATA[23:16],Reg[AVL_ADDR][15:0]};					
					4'b0010: Reg_Next[AVL_ADDR] = {Reg[AVL_ADDR][31:16],AVL_WRITEDATA[15:8],Reg[AVL_ADDR][7:0]};
					4'b0001: Reg_Next[AVL_ADDR] = {Reg[AVL_ADDR][31:8],AVL_WRITEDATA[7:0]};
				endcase
			end
		end
    end

	assign EXPORT_DATA = {Reg[0][31:16],Reg[3][15:0]};

	AES AES_inst(.CLK(CLK),.RESET(RESET),.AES_START(Reg[14][0]),.AES_DONE(AES_DONE),.AES_KEY({Reg[0],Reg[1],Reg[2],Reg[3]}),.AES_MSG_ENC({Reg[4],Reg[5],Reg[6],Reg[7]}),.AES_MSG_DEC(AES_MSG_DE));	

endmodule
