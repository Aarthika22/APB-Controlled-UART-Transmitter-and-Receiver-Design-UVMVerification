class apb_xtn extends uvm_sequence_item;
`uvm_object_utils(apb_xtn)

function new(string name = "apb_xtn");
super.new(name);
endfunction
   bit PRESETn;
    bit PENABLE;
    bit PSEL;
    rand bit [31:0] PADDR;
    rand bit [31:0] PWDATA;
    bit [31:0] PRDATA;
    bit PREADY;
    rand bit PWRITE;
    bit PSLVERR;
    bit IRQ;

    bit dl_access;
    bit data_in_thr;
    bit data_in_rbr;
    bit[7:0] lcr;
    bit[7:0] ier;
    bit[7:0] fcr;
    bit[15:0] div;
    bit[7:0] thr[$];
    bit[7:0] rbr[$];
    bit[7:0] iir;
    bit[7:0] lsr;
    bit[7:0] mcr;
        constraint data_range{ PWDATA inside {[0:255]};}

    function void do_print(uvm_printer printer);
        printer.print_field("Penable", this.PENABLE, 1, UVM_DEC);
        printer.print_field("Presetn", this.PRESETn, 1, UVM_DEC);
        printer.print_field("Psel", this.PSEL, 1, UVM_DEC);
        printer.print_field("Paddr", this.PADDR, 32,UVM_HEX);
        printer.print_field("Pwdata", this.PWDATA, 32, UVM_DEC);
        printer.print_field("PRdata", this.PRDATA, 32, UVM_DEC);
        printer.print_field("Pready", this.PREADY, 1,UVM_DEC);
        printer.print_field("Pwrite", this.PWRITE, 1, UVM_DEC);
        printer.print_field("PSLVERR", this.PSLVERR, 1, UVM_DEC);

        printer.print_field("LCR", this.lcr, 8, UVM_BIN);
        printer.print_field("IER", this.ier, 8, UVM_BIN);
        printer.print_field("FCR", this.fcr, 8, UVM_BIN);
        printer.print_field("DIV", this.div, 16, UVM_DEC);
        printer.print_field("THR", this.thr[thr.size()-1], 8, UVM_DEC); // printing the last value in thr array
        printer.print_field("RBR", this.rbr[rbr.size()-1], 8, UVM_DEC); // printing the last value in rhr array
        printer.print_field("IIR", this.iir, 8, UVM_BIN);
        printer.print_field("LSR", this.lsr, 8, UVM_BIN);
        printer.print_field("MCR", this.mcr, 8, UVM_BIN);
    endfunction

endclass

