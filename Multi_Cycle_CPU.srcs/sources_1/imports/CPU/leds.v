`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module leds(led_clk, ledrst, ledwrite, ledcs, ledaddr,ledwdata, ledout);
    input led_clk;    		    // clock 
    input ledrst; 		        // reset
    input ledwrite;		        // write enable
    input ledcs;		        // generated by memorio module, is the chip select of led
    input[1:0] ledaddr;	        // address[1:0], the lowest two bits of LED address
    input[15:0] ledwdata;	  	// data(16bit) to this module
    output[23:0] ledout;		// data to leds of minisys developing board
  
    reg [23:0] ledout;
    
    always@(posedge led_clk or posedge ledrst) begin
        if(ledrst) begin
            ledout <= 24'h000000;
        end
		else if(ledcs && ledwrite) begin
			if(ledaddr == 2'b00)
				ledout[23:0] <= { ledout[23:16], ledwdata[15:0] };
			else if(ledaddr == 2'b10 )
				ledout[23:0] <= { ledwdata[7:0], ledout[15:0] };
			else
				ledout <= ledout;
        end
		else begin
            ledout <= ledout;
        end
    end
endmodule
