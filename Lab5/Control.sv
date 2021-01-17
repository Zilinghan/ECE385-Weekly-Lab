module control
(
    input logic Clk, Reset, Run, ClearA_LoadB, B1, B0,
    output logic fn, shift, loadXA, loadB, clearXA, clearB
);

    enum logic [4:0] {init, run, clear_load, delay, reset,
        add0, shift0, add1, shift1, add2, shift2, add3, shift3,
        add4, shift4, add5, shift5, add6, shift6, add7, shift7} curr_state, next_state; 

	//updates flip flop, current state is the only one
    always_ff @ (posedge Clk)  
    begin
        if (Reset)
            curr_state <= reset;
        else 
            curr_state <= next_state;
    end

    // Assign outputs based on state
	always_comb
    begin        
		next_state  = curr_state;	//required because I haven't enumerated all possibilities below
        unique case (curr_state) 
            init:   if(ClearA_LoadB)
                        next_state=clear_load;
                    else if(Run)
                        next_state=run;
                    else
                        next_state=init;
            clear_load: next_state=init;
            reset:      next_state=init;
            run:    if(B0)
                        next_state=add0;
                    else
                        next_state=shift0;
            add0:       next_state=shift0;
            shift0: if(B1)
                        next_state=add1;
                    else
                        next_state=shift1;
            add1:       next_state=shift1;
            shift1: if(B1)
                        next_state=add2;
                    else
                        next_state=shift2;
            add2:       next_state=shift2;
            shift2: if(B1)
                        next_state=add3;
                    else
                        next_state=shift3;
            add3:       next_state=shift3;
            shift3: if(B1)
                        next_state=add4;
                    else
                        next_state=shift4;							  
            add4:       next_state=shift4;
            shift4: if(B1)
                        next_state=add5;
                    else
                        next_state=shift5;
            add5:       next_state=shift5;
            shift5: if(B1)
                        next_state=add6;
                    else
                        next_state=shift6;
            add6:       next_state=shift6;
            shift6: if(B1)
                        next_state=add7;
                    else
                        next_state=shift7;
            add7:       next_state=shift7;
            shift7:     next_state=delay;
            delay:  if(!Run)
                        next_state=init;
                    else
                        next_state=delay;
        endcase
   
		// Assign outputs based on ‘state’
        fn=0;
        shift=0;
        loadXA=0;
        loadB=0;
        clearXA=0;
        clearB=0;
        case (curr_state)
            run:
                begin
                    clearXA=1;
                end
            clear_load:
                begin
                    loadB=1;
                    clearXA=1;
                end
            reset:
                begin
                    clearXA=1;
                    clearB=1;
                end
	   	    shift0:
                begin
                    shift=1;
                end
	   	    shift1:
                begin
                    shift=1;
                end            
	   	    shift2:
                begin
                    shift=1;
                end
	   	    shift3:
                begin
                    shift=1;
                end
	   	    shift4:
                begin
                    shift=1;
                end
	   	    shift5:
                begin
                    shift=1;
                end
	   	    shift6:
                begin
                    shift=1;
                end
	   	    shift7:
                begin
                    shift=1;
                end
	   	    add0:
		        begin
                    loadXA=1;
		        end
	   	    add1:
		        begin
                    loadXA=1;
		        end
	   	    add2:
		        begin
                    loadXA=1;
		        end
	   	    add3:
		        begin
                    loadXA=1;
		        end
	   	    add4:
		        begin
                    loadXA=1;
		        end
	   	    add5:
		        begin
                    loadXA=1;
		        end
	   	    add6:
		        begin
                    loadXA=1;
		        end
	   	    add7:
		        begin
                    loadXA=1;
                    fn=B0;
		        end
	   	    default:
		        begin
                    fn=0;
                    shift=0;
                    loadXA=0;
                    loadB=0;
                    clearXA=0;
		        end
        endcase
    end

endmodule
