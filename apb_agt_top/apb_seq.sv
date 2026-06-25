class apb_seq extends uvm_sequence#(apb_xtn);
`uvm_object_utils(apb_seq)

function new(string name = "apb_seq");
super.new(name);
endfunction
endclass

class apb_half_duplex_seq extends apb_seq;

    `uvm_object_utils(apb_half_duplex_seq)

    function new(string name = "apb_half_duplex_seq");
            super.new(name);
    endfunction

    task body();
        req = apb_xtn::type_id::create("req");

        //divisor latch MSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h20; PWRITE==1; PWDATA==0;});
        finish_item(req);

        //divisor latch LSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h1c; PWRITE==1; PWDATA==27;});
        finish_item(req);

        //line control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'hc; PWRITE==1; PWDATA==8'b00000011;});
        finish_item(req);

        //fifo control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h08; PWRITE==1; PWDATA==8'b00000110;});
        finish_item(req);

        //interupt enable register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h04; PWRITE==1; PWDATA==8'b00000101;});
        finish_item(req);

    endtask
endclass

class apb_read_seq extends apb_seq;  

    `uvm_object_utils(apb_read_seq)

    function new(string name = "apb_read_seq");
            super.new(name);
    endfunction

    task body();
        req = apb_xtn::type_id::create("req");

        start_item(req);
        assert(req.randomize() with {PADDR == 32'h08; PWRITE==0;}); //IIR register

        finish_item(req);
        get_response(req);    // getting the response from driver after reading IIR register and storing the value of IIR register in req item

        if(req.iir[3:0] == 4) // receiver data available interupt
        begin
            start_item(req);
            assert(req.randomize() with {PADDR == 32'h00; PWRITE==0;}); //Read from receiver buffer register
            finish_item(req);
        end

        if(req.iir[3:0] == 6)
        begin
            start_item(req);
            assert(req.randomize() with {PADDR == 32'h14; PWRITE==0;}); //Read from line status register
            finish_item(req);
        end
    endtask
endclass


//=============================================================================================================
class apb_loop_back_seq extends apb_seq;

    `uvm_object_utils(apb_loop_back_seq)

    function new(string name = "apb_loop_back_seq");
            super.new(name);
    endfunction

    task body();
        req = apb_xtn::type_id::create("req");

        //divisor latch MSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h20; PWRITE==1; PWDATA==0;});
        finish_item(req);

        //divisor latch LSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h1c; PWRITE==1; PWDATA==27;});
        finish_item(req);

        //line control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'hc; PWRITE==1; PWDATA==8'b00000011;});
        finish_item(req);

        //fifo control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h08; PWRITE==1; PWDATA==8'b00000110;});
        finish_item(req);

        //interupt enable register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h04; PWRITE==1; PWDATA==8'b00000101;});
        finish_item(req);

        //mcr
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h10; PWRITE==1; PWDATA==8'b00010000;});
        finish_item(req);

        //transmitter holding register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h00; PWRITE==1;});
        finish_item(req);

    endtask
endclass

class apb_full_duplex_seq extends apb_seq;
        apb_read_seq read_seq_h;

    `uvm_object_utils(apb_full_duplex_seq)

    function new(string name = "apb_full_duplex_seq");
            super.new(name);
    endfunction

    task body();
       req = apb_xtn::type_id::create("req"); 
        read_seq_h = apb_read_seq::type_id::create("read_seq_h");

        start_item(req);
        assert(req.randomize() with {PADDR == 32'h20; PWRITE==1; PWDATA==0;});
        finish_item(req);

        //divisor latch LSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h1c; PWRITE==1; PWDATA==27;});
        finish_item(req);

        //line control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'hc; PWRITE==1; PWDATA==8'b00000011;});
        finish_item(req);

        //fifo control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h08; PWRITE==1; PWDATA==8'b00000110;});
        finish_item(req);

        //interupt enable register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h04; PWRITE==1; PWDATA==8'b00000101;});
        finish_item(req);

         //transmitter holding register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h00; PWRITE==1;});
        finish_item(req);

       
    endtask
endclass

class apb_parity_error_seq extends apb_seq; // to inject parity error and to verify whether it is getting reflected

     apb_read_seq read_seq_h;

    `uvm_object_utils(apb_parity_error_seq)

    function new(string name = "apb_parity_error_seq");
            super.new(name);
    endfunction

    task body();
        req = apb_xtn::type_id::create("req"); 
        read_seq_h = apb_read_seq::type_id::create("read_seq_h");

        //divisor latch MSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h20; PWRITE==1; PWDATA==0;});
        finish_item(req);

        //divisor latch LSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h1c; PWRITE==1; PWDATA==27;});
        finish_item(req);

        //line control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'hc; PWRITE==1; PWDATA==8'b00001011;});  //parity enabled and odd parity
        finish_item(req);

        //fifo control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h08; PWRITE==1; PWDATA==8'b00000110;});
        finish_item(req);

        //interupt enable register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h04; PWRITE==1; PWDATA==8'b00000101;}); //line status interupt should be enabled to check parity error in line status register
        finish_item(req);

        //transmitter holding register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h00; PWRITE==1;});
        finish_item(req);


        read_seq_h.start(m_sequencer);

    endtask
endclass

class apb_framing_error_seq extends apb_seq; // to inject framing error and to verify whether it is getting reflected

     apb_read_seq read_seq_h;

    `uvm_object_utils(apb_framing_error_seq)

    function new(string name = "apb_framing_error_seq");
            super.new(name);
    endfunction

    task body();
        read_seq_h = apb_read_seq::type_id::create("read_seq_h");
        //divisor latch MSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h20; PWRITE==1; PWDATA==0;});
        finish_item(req);

        //divisor latch LSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h1c; PWRITE==1; PWDATA==27;});
        finish_item(req);

        //line control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'hc; PWRITE==1; PWDATA==8'b00000111;});  //stop bit is made 1
        finish_item(req);

        //fifo control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h08; PWRITE==1; PWDATA==8'b00000110;});
        finish_item(req);

        //interupt enable register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h04; PWRITE==1; PWDATA==8'b00000101;}); //line status interupt should be enabled to check parity error in line status register
        finish_item(req);

        //transmitter holding register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h00; PWRITE==1;});
        finish_item(req);

        

    endtask
endclass

class apb_break_error_seq extends apb_seq;

     apb_read_seq read_seq_h;

    `uvm_object_utils(apb_break_error_seq)

    function new(string name = "apb_break_error_seq");
            super.new(name);
    endfunction

    task body();
        read_seq_h = apb_read_seq::type_id::create("read_seq_h");

        //divisor latch MSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h20; PWRITE==1; PWDATA==0;});
        finish_item(req);

        //divisor latch LSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h1c; PWRITE==1; PWDATA==27;});
        finish_item(req);

        //line control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'hc; PWRITE==1; PWDATA==8'b01000011;});  //break control enabled (7th bit)
        finish_item(req);

        //fifo control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h08; PWRITE==1; PWDATA==8'b00000110;});
        finish_item(req);

        //interupt enable register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h04; PWRITE==1; PWDATA==8'b00000101;}); //line status interupt should be enabled to check parity error in line status register
        finish_item(req);

        //transmitter holding register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h00; PWRITE==1;});
        finish_item(req);

        read_seq_h.start(m_sequencer);

    endtask
endclass

class apb_overrun_error_seq extends apb_seq;

     apb_read_seq read_seq_h;

    `uvm_object_utils(apb_overrun_error_seq)

    function new(string name = "apb_overrun_error_seq");
            super.new(name);
    endfunction

    task body();
        read_seq_h = apb_read_seq::type_id::create("read_seq_h");

        //divisor latch MSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h20; PWRITE==1; PWDATA==0;});
        finish_item(req);

        //divisor latch LSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h1c; PWRITE==1; PWDATA==27;});
        finish_item(req);

        //line control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'hc; PWRITE==1; PWDATA==8'b01000011;});  //break control enabled (7th bit)
        finish_item(req);

        //fifo control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h08; PWRITE==1; PWDATA==8'b00000110;});
        finish_item(req);

        //interupt enable register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h04; PWRITE==1; PWDATA==8'b00000101;}); //line status interupt should be enabled to check parity error in line status register
        finish_item(req);

        //transmitter holding register
        repeat(17) begin
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h00; PWRITE==1;});
        finish_item(req);
        end

        read_seq_h.start(m_sequencer);

    endtask
endclass


class apb_thr_empty_error_seq extends apb_seq; //dont configure thr and flush tx fifo

     apb_read_seq read_seq_h;

    `uvm_object_utils(apb_thr_empty_error_seq)

    function new(string name = "apb_thr_empty_error_seq");
            super.new(name);
    endfunction

    task body();
        read_seq_h = apb_read_seq::type_id::create("read_seq_h");
        //divisor latch MSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h20; PWRITE==1; PWDATA==0;});
        finish_item(req);

        //divisor latch LSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h1c; PWRITE==1; PWDATA==27;});
        finish_item(req);

        //line control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'hc; PWRITE==1; PWDATA==8'b01000011;});  //break control enabled (7th bit)
        finish_item(req);

        //fifo control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h08; PWRITE==1; PWDATA==8'b00000110;});
        finish_item(req);

        //interupt enable register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h04; PWRITE==1; PWDATA==8'b00000111;}); //trasmitter empty interupt enabled
        finish_item(req);

        read_seq_h.start(m_sequencer);

    endtask
endclass


class apb_timeout_error_seq extends apb_seq;

     apb_read_seq read_seq_h;

    `uvm_object_utils(apb_timeout_error_seq)

    function new(string name = "apb_timeout_error_seq");
            super.new(name);
    endfunction

    task body();
        read_seq_h = apb_read_seq::type_id::create("read_seq_h");
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h20; PWRITE==1; PWDATA==0;});
        finish_item(req);

        //divisor latch LSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h1c; PWRITE==1; PWDATA==27;});
        finish_item(req);

        //line control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'hc; PWRITE==1; PWDATA==8'b01000011;});  //break control enabled (7th bit)
        finish_item(req);

        //fifo control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h08; PWRITE==1; PWDATA==8'b11000110;}); // threshold 4 bytes
        finish_item(req);

        //interupt enable register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h04; PWRITE==1; PWDATA==8'b00000111;}); //trasmitter empty interupt enabled
        finish_item(req);

        read_seq_h.start(m_sequencer);

    endtask
endclass

