package test_pkg;
import uvm_pkg::*;

`include "uvm_macros.svh"
`include "apb_xtn.sv"
`include "uart_xtn.sv"

`include "apb_config.sv"
`include "uart_config.sv"
`include "env_config.sv"

`include "apb_seq.sv"
`include "apb_seqr.sv"
`include "apb_drv.sv"
`include "apb_mon.sv"
`include "apb_agt.sv"
`include "apb_agt_top.sv"

`include "uart_seq.sv"
`include "uart_seqr.sv"
`include "uart_drv.sv"
`include "uart_mon.sv"
`include "uart_agt.sv"
`include "uart_agt_top.sv"

`include "sb.sv"
`include "env.sv"

`include "test.sv"

endpackage
