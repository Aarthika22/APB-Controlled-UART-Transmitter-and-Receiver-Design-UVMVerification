class uart_seq extends uvm_sequence#(uart_xtn);
  `uvm_object_utils(uart_seq)

  bit [7:0] lcr;
  function new(string name = "uart_seq");
    super.new(name);
  endfunction

  task body();
    if(!uvm_config_db#(bit[7:0])::get(null,get_full_name(),"lcr",lcr))
      `uvm_fatal("UART_SEQ","cannot get")
  endtask
endclass

class uart_half_duplex_seq extends uart_seq;
        `uvm_object_utils(uart_half_duplex_seq)
        function new(string name = " uart_half_duplex_seq");
                super.new(name);
        endfunction

        task body();
                
                req = uart_xtn::type_id::create("req");

                req.lcr = lcr; // assigning the value of lcr which we got from config db to transaction variable lcr

                start_item(req);
                assert(req.randomize() with {stop_bit==1;});
                finish_item(req);
        endtask
endclass

class uart_full_duplex_seq extends uart_seq;
        `uvm_object_utils(uart_full_duplex_seq)
        function new(string name = "uart_full_duplex_seq");
                super.new(name);
        endfunction

        task body();
            
                req = uart_xtn::type_id::create("req");

                req.lcr = lcr;

                start_item(req);
                assert(req.randomize() with {stop_bit == 1;});
                finish_item(req);
        endtask
endclass

class uart_parity_seq extends uart_seq;
        `uvm_object_utils(uart_parity_seq)
        function new(string name = "uart_parity_seq");
                super.new(name);
        endfunction

        task body();
            
                req = uart_xtn::type_id::create("req");

                // we need to assign values to variables(lcr, bad_parity) in our transaction class
                req.lcr = lcr;
                req.bad_parity = 1; // to inject parity error

                start_item(req);
                assert(req.randomize() with {stop_bit ==1;});
                finish_item(req);
        endtask
endclass


class uart_framing_seq extends uart_seq;
        `uvm_object_utils(uart_framing_seq)
        function new(string name = "uart_framing_seq");
                super.new(name);
        endfunction

        task body();

                req = uart_xtn::type_id::create("req");

                req.lcr = lcr;

                start_item(req);
                assert(req.randomize() with {stop_bit ==0;});
                finish_item(req);
        endtask
endclass


class uart_break_seq extends uart_seq;
        `uvm_object_utils(uart_break_seq)
        function new(string name = "uart_break_seq");
                super.new(name);
        endfunction

        task body();
            
                req = uart_xtn::type_id::create("req");

                req.lcr = lcr;  //break interupt enable

                start_item(req);
                assert(req.randomize() with {stop_bit ==0; tx==0;});
                finish_item(req);
        endtask
endclass


class uart_overrun_seq extends uart_seq;
        `uvm_object_utils(uart_overrun_seq)
        function new(string name = "uart_overrun_seq");
                super.new(name);
        endfunction

        task body();
            
                req = uart_xtn::type_id::create("req");

                req.lcr = lcr;

                repeat(17) begin
                        start_item(req);
                        assert(req.randomize() with {stop_bit ==1;});
                        finish_item(req);
                end
        endtask
endclass

class uart_thr_empty_seq extends uart_seq;
        `uvm_object_utils(uart_thr_empty_seq)
        function new(string name = "uart_thr_empty_seq");
                super.new(name);
        endfunction

        task body();
            
                req = uart_xtn::type_id::create("req");

                req.lcr = lcr;

                start_item(req);
                assert(req.randomize() with {tx ==0; stop_bit ==1;});
                finish_item(req);
        endtask
endclass

class uart_timeout_seq extends uart_seq;
        `uvm_object_utils(uart_timeout_seq)
        function new(string name = "uart_timeout_seq ");
                super.new(name);
        endfunction

        task body();
            
                req = uart_xtn::type_id::create("req");

                req.lcr = lcr;

                start_item(req);
                assert(req.randomize() with {tx ==0; stop_bit ==1;});
                finish_item(req);
        endtask
endclass

