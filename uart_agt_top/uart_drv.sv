class uart_drv extends uvm_driver#(uart_xtn);
  `uvm_component_utils(uart_drv)

  uart_config uart_cfg;
  virtual uart_if vif;
  bit[7:0] lcr;

  function new(string name = "uart_drv",uvm_component parent);
     super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(uart_config)::get(this," ","uart_config",uart_cfg))
      `uvm_fatal("UART_DRV","cannot get")

    if(!uvm_config_db#(bit[7:0])::get(this," ","lcr",lcr))
      `uvm_fatal("UART_DRV","cannot get")
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    vif = uart_cfg.vif;
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      `uvm_info("UART_DRV","driving",	UVM_MEDIUM)
      req.print();
      drive(req);
      seq_item_port.item_done();
    end
  endtask

  task drive(uart_xtn req);
    repeat(16)
    @(posedge vif.baud_o);

    send_tx(1'b0);

    for(int i = 0; i< req.bits; i++)
      send_tx(req.tx[i]);

        if(lcr[3])
          send_tx(req.parity);

          send_tx(req.stop_bit);

        if(lcr[2] ==1)begin
          if(lcr[1:0] ==2'b00) begin
             repeat(8) @(posedge vif.baud_o);
            end
        end
  endtask

  task send_tx(bit data_bit);
      vif.tx <= data_bit;
      repeat(16);
        @(posedge vif.baud_o);
  endtask

endclass


