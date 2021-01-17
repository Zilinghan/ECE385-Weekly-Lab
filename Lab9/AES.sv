/************************************************************************
AES Decryption Core Logic

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

module AES (
	input	 logic CLK,
	input  logic RESET,
	input  logic AES_START,
	output logic AES_DONE,
	input  logic [127:0] AES_KEY,
	input  logic [127:0] AES_MSG_ENC,
	output logic [127:0] AES_MSG_DEC
);

// in testbench simulation, KeyExpansion complete 180ns (9 clocks, 50MHz)

	// Key Expansion
	// Counter for Key Expansion Delay
	logic [3:0] Counter_Key, Counter_Key_Next;
	logic Increase_Counter_Key, Clear_Counter_Key;

	always_ff @ (posedge CLK)
	begin
		Counter_Key <= Counter_Key_Next;
	end	

	always_comb
	begin
		Counter_Key_Next = Counter_Key;
		if (RESET)
			Counter_Key_Next = 4'b0;
		else if (Clear_Counter_Key)
			Counter_Key_Next = 4'b0;
		else if (Increase_Counter_Key)
			Counter_Key_Next = Counter_Key + 1'b1;
	end

	logic [1407:0] KeySchedule;
	KeyExpansion KeyExpansion_inst(.clk(CLK),.Cipherkey(AES_KEY),.KeySchedule(KeySchedule));
	
	// Counter for the main loop
	logic [3:0] Counter_Loop, Counter_Loop_Next;
	logic Increase_Counter_Loop, Clear_Counter_Loop;

	always_ff @ (posedge CLK)
	begin
		Counter_Loop <= Counter_Loop_Next;
	end	

	always_comb
	begin
		Counter_Loop_Next = Counter_Loop;
		if (RESET)
			Counter_Loop_Next = 4'b0;
		else if (Clear_Counter_Loop)
			Counter_Loop_Next = 4'b0;
		else if (Increase_Counter_Loop)
			Counter_Loop_Next = Counter_Loop + 1'b1;
	end

	// Counter for InvMixColumns
	logic [1:0] Counter_Mix, Counter_Mix_Next;
	logic Increase_Counter_Mix, Clear_Counter_Mix;

	always_ff @ (posedge CLK)
	begin
		Counter_Mix <= Counter_Mix_Next;
	end	

	always_comb
	begin
		Counter_Mix_Next = Counter_Mix;
		if (RESET)
			Counter_Mix_Next = 2'b0;
		else if (Clear_Counter_Mix)
			Counter_Mix_Next = 2'b0;
		else if (Increase_Counter_Mix)
			Counter_Mix_Next = Counter_Mix + 1'b1;
	end
	
	// Calculate the next state
	logic [127:0] State_128, State_128_Next;
	logic [127:0] State_128_Shift, State_128_Sub, State_128_Adder_Out;
	logic [127:0] State_128_Adder;
	logic [31:0] State_32_Mix_In, State_32_Mix_Out;
	logic [127:0] State_128_Mix_Out;
	logic LD_MSG_ENC, LD_Adder_0, LD_Adder_Loop, LD_Mix_Loop;

	// (Calculate the next state) InvShiftRows(state); InvSubBytes(state); AddRoundKey(state,w+16*round);
	always_comb
	begin
		unique case (Counter_Loop)
			4'd0: State_128_Adder = KeySchedule[127:0];
			4'd1: State_128_Adder = KeySchedule[255:128];
			4'd2: State_128_Adder = KeySchedule[383:256];
			4'd3: State_128_Adder = KeySchedule[511:384];
			4'd4: State_128_Adder = KeySchedule[639:512];
			4'd5: State_128_Adder = KeySchedule[767:640];
			4'd6: State_128_Adder = KeySchedule[895:768];
			4'd7: State_128_Adder = KeySchedule[1023:896];
			4'd8: State_128_Adder = KeySchedule[1151:1024];
			4'd9: State_128_Adder = KeySchedule[1279:1152];
			4'd10: State_128_Adder = KeySchedule[1407:1280];
		endcase
	end

	InvShiftRows InvShiftRows_inst(.data_in(State_128),.data_out(State_128_Shift));
	InvSubBytes InvSubBytes_inst[15:0](.clk(CLK),.in(State_128_Shift),.out(State_128_Sub));
	assign State_128_Adder_Out = State_128_Sub ^ State_128_Adder;

	// (Calculate the next state) InvMixColumns(state);
	always_comb
	begin
		unique case (Counter_Mix)
			2'd0: State_32_Mix_In = State_128[31:0];
			2'd1: State_32_Mix_In = State_128[63:32];
			2'd2: State_32_Mix_In = State_128[95:64];
			2'd3: State_32_Mix_In = State_128[127:96];
		endcase
	end

	InvMixColumns InvMixColumns_inst(.in(State_32_Mix_In),.out(State_32_Mix_Out));

	always_comb
	begin
		unique case (Counter_Mix)
			2'd0: State_128_Mix_Out = {State_128[127:32],State_32_Mix_Out};
			2'd1: State_128_Mix_Out = {State_128[127:64],State_32_Mix_Out,State_128[31:0]};
			2'd2: State_128_Mix_Out = {State_128[127:96],State_32_Mix_Out,State_128[63:0]};
			2'd3: State_128_Mix_Out = {State_32_Mix_Out,State_128[95:0]};
		endcase
	end

	// (Calculate the next state) Store
	always_ff @ (posedge CLK)
	begin
		State_128 <= State_128_Next;
	end

	always_comb
	begin
		State_128_Next = State_128;
		if (RESET)
			State_128_Next = 128'b0;
		else if (LD_MSG_ENC)
			State_128_Next = AES_MSG_ENC;
		else if (LD_Adder_0)
			State_128_Next = State_128 ^ KeySchedule[127:0];
		else if (LD_Adder_Loop)
			State_128_Next = State_128_Adder_Out;
		else if (LD_Mix_Loop)
			State_128_Next = State_128_Mix_Out;
	end

	// Output decrypted message
	assign AES_MSG_DEC = State_128;	
	
	// State Machine
	enum logic [2:0] {
		Wait,
		KeyExpansion,
		Adder_0,
		Adder_Loop,
		Mix,
		Done } State, Next_State;

	always_ff @ (posedge CLK)
	begin
		if (RESET)
			State <= Wait;
		else
			State <= Next_State;
	end

	always_comb
	begin 
		Next_State = State;

		case (State)
			Wait:
				begin
					if (AES_START) 
						Next_State = KeyExpansion;
				end
			KeyExpansion:
				begin
					if (4'd8==Counter_Key)
						Next_State = Adder_0;
				end
			Adder_0:
				begin
					Next_State = Adder_Loop;
				end
			Adder_Loop:
				begin
					Next_State = Mix;
					if (4'd10==Counter_Loop)
						Next_State = Done;
				end
			Mix:
				begin
					if (2'd3==Counter_Mix)
						Next_State = Adder_Loop;
				end
			Done:
				begin
					if (~AES_START)
					Next_State = Wait;
				end
		endcase
	end

	always_comb
	begin
		AES_DONE = 1'b0;

		Increase_Counter_Key = 1'b0;
		Clear_Counter_Key = 1'b1;

		Increase_Counter_Loop = 1'b0;
		Clear_Counter_Loop = 1'b1;

		Increase_Counter_Mix = 1'b0;
		Clear_Counter_Mix = 1'b1;

		LD_MSG_ENC = 1'b0;
		LD_Adder_0 = 1'b0;
		LD_Adder_Loop = 1'b0;
		LD_Mix_Loop = 1'b0;

		case (State)
			KeyExpansion:
				begin
					Increase_Counter_Key = 1'b1;
					Clear_Counter_Key = 1'b0;
					LD_MSG_ENC = 1'b1;
				end
			Adder_0:
				begin
					Increase_Counter_Loop = 1'b1;
					Clear_Counter_Loop = 1'b0;
					LD_Adder_0 = 1'b1;
				end
			Adder_Loop:
				begin
					Increase_Counter_Loop = 1'b1;
					Clear_Counter_Loop = 1'b0;
					LD_Adder_Loop = 1'b1;					
				end
			Mix:
				begin
					Clear_Counter_Loop = 1'b0;
					Increase_Counter_Mix = 1'b1;
					Clear_Counter_Mix = 1'b0;
					LD_Mix_Loop = 1'b1;					
				end
			Done:
				begin
					AES_DONE = 1'b1;
				end
		endcase
	end

endmodule
