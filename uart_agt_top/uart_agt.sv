class uart_agt extends uvm_agent;
  `uvm_component_utils(uart_agt)

  function new(string name ="uart_agt",uvm_component parent);
    super.new(name,parent);
  endfunction

  uart_drv uart_drv_h;
  uart_mon uart_mon_h;
  uart_seqr uart_seqr_h;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    uart_drv_h = uart_drv::type_id::create("uart_drv_h",this);
    uart_mon_h = uart_mon::type_id::create("uart_mon_h",this);
    uart_seqr_h = uart_seqr::type_id::create("uart_seqr_h",this);

  endfunction 
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    uart_drv_h.seq_item_port.connect(uart_seqr_h.seq_item_export);
  endfunction
endclass
