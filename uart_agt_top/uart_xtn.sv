class uart_xtn extends uvm_sequence_item;
  `uvm_object_utils(uart_xtn)

    rand bit [7:0] tx;
    bit [7:0] rx;
    bit parity;
    rand bit stop_bit;
    bit bad_parity;

    bit[7:0] lcr; // will be configured directly from test class
    int bits;

  function new(string name = "uart_xtn");
      super.new(name);
  endfunction
function void do_print(uvm_printer printer);
                printer.print_field("TX", this.tx, 8, UVM_DEC);
                printer.print_field("RX", this.rx, 8, UVM_DEC);
                printer.print_field("Parity", this.parity, 1, UVM_DEC);
                printer.print_field("Stop Bit", this.stop_bit, 1, UVM_DEC);
                printer.print_field("Bad Parity", this.bad_parity, 1, UVM_DEC);
                printer.print_field("LCR", this.lcr, 8, UVM_BIN);
        endfunction


        function void post_randomize();
                bits = lcr[1:0]+5; // calculating the number of bits to be transmitted based on the value of lcr register
                                   // we are not considering lcr bit 4 and bit 5 while calculating parity why?
                if(bad_parity == 0)     begin
                        if(lcr[3]) begin
                        parity=0;
                        for(int i=0; i<bits; i++) begin
                                parity = parity ^ tx[i]; // calculating parity bit based on the value of tx and number of bits to be transmitted
                        end                             // xor --> 1 (odd ones)    xor --> 0 (even ones)
                end
                end

                else begin      parity = ~parity; end   //what will be default parity? if is 0 then it will be 1
        endfunction

endclass
