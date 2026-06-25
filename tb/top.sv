`timescale 1ns/1ns
import uvm_pkg::*;
import test_pkg::*;

module top;
  bit clk1;
  bit clk2;

  int baud_cnt;
  bit PRESETn;

  apb_if apb_if_inst(clk1);
  uart_if uart_if_inst(clk2);

  uart_16550 dut(
    .PCLK  (clk1),
    .PRESETn  (apb_if_inst.PRESETn),
    .PADDR     (apb_if_inst.PADDR),
    .PWDATA   (apb_if_inst.PWDATA),
    .PRDATA    (apb_if_inst.PRDATA),
    .PWRITE   (apb_if_inst.PWRITE),
    .PENABLE   (apb_if_inst.PENABLE),
    .PSEL      (apb_if_inst.PSEL),
    .PREADY     (apb_if_inst.PREADY),
    .PSLVERR     (apb_if_inst.PSLVERR),
    .IRQ   (apb_if_inst.IRQ),
    .TXD   (uart_if_inst.rx),
    .RXD  (uart_if_inst.tx),
    .baud_o   ()
);

always #5 clk2 = ~clk2;
always #10 clk1 = ~clk1;

localparam int clk_freq = 100000000;
localparam int sample = 16;
localparam int baud_rate = 115200;
localparam int divisor = clk_freq /(sample*baud_rate);

  initial 
    begin
      clk1 =0;
      clk2 =0;
      PRESETn = 0;
      #100 PRESETn = 1;
    end 

    always @(posedge clk2 or negedge PRESETn)  begin
    if(!PRESETn)  begin
      baud_cnt <= 0;
      uart_if_inst.baud_o <=0 ;
    end
    else if (baud_cnt == divisor)begin
      uart_if_inst.baud_o <= 1;
      baud_cnt <= 0;
    end 
    else begin
      uart_if_inst.baud_o <= 0;
      baud_cnt <= baud_cnt +1;
    end
    end

  initial begin
    uvm_config_db#(virtual apb_if)::set(null,"*","vif",apb_if_inst);
    uvm_config_db#(virtual uart_if)::set(null,"*","vif",uart_if_inst);

    run_test();
    end
endmodule

