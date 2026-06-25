interface apb_if(input logic clk1);
 
logic PRESETn;
logic PENABLE;
logic PSEL;
logic[31:0] PADDR;
logic[31:0] PWDATA;
logic[31:0] PRDATA;
logic PREADY;
logic PWRITE;
logic PSLVERR;
logic IRQ;

clocking apb_drv_cb@(posedge clk1);
output PRESETn;
output PENABLE;
output PSEL;
output PADDR;
output PWDATA;
output PWRITE;
input PRDATA;
input PREADY;
input PSLVERR;
input IRQ;
endclocking

clocking apb_mon_cb@(posedge clk1);
input PRESETn;
input PENABLE;
input PSEL;
input PADDR;
input PWDATA;
input PWRITE;
input PRDATA;
input PREADY;
input PSLVERR;
input IRQ;
endclocking

modport apb_drv_mp(clocking apb_drv_cb);
modport apb_mon_mp(clocking apb_mon_cb);

endinterface

