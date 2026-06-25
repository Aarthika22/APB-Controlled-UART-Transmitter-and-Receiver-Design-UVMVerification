class uart_mon extends uvm_monitor;
  `uvm_component_utils(uart_mon)

  uart_config uart_cfg;
  virtual uart_if vif;
  bit[7:0] lcr;
  uart_xtn xtn;
  uvm_analysis_port#(uart_xtn)mon_port;

  function new(string name = "uart_mon",uvm_component parent);
    super.new(name,parent);
    mon_port = new("mon_port",this);
    xtn = uart_xtn::type_id::create("xtn");

  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(uart_config)::get(this," ","uart_config",uart_cfg))
      `uvm_fatal("UART_MON","cannot get")

    if(!uvm_config_db#(bit[7:0])::get(this," ","lcr",lcr))
      `uvm_fatal("UART_MON","cannot get")

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    vif = uart_cfg.vif;
  endfunction

  task run_phase(uvm_phase phase);
    bit rx_busy, tx_busy;
    fork
      forever begin
        if(rx_busy ==0) begin
          rx_busy =1;
          collect(vif.rx,xtn.rx,xtn.parity);
          rx_busy = 0;
        end
        else
          @(posedge vif.baud_o);
      end

      forever begin
      if(tx_busy ==0) begin
        tx_busy =1;
        collect(vif.tx, xtn.tx, xtn.parity);
        tx_busy = 0;
      end
      else
        @(posedge vif.baud_o);
      end
    join_none
  endtask

  task collect(ref logic line, ref bit[7:0] data,ref bit parity);
    int bits;
    bits = lcr[1:0]+5;
    @(negedge line);
    $display("start bits detected");

    repeat(24) @(posedge vif.baud_o);

    for(int i=0; i<bits; i++)
    begin
      $display("bit sample");
      data[i] =line;
      repeat(16) @(posedge vif.baud_o);
    end

    if(lcr[3])
      begin
        parity = line ;
        $display("parity bit sampled");
        repeat(16) @(posedge vif.baud_o);

      end

      line = xtn.stop_bit;
      repeat(16) @(posedge vif.baud_o);

      mon_port.write(xtn);
      `uvm_info("uart_mon","sampling done",UVM_MEDIUM)
      xtn.print();
  endtask

endclass
