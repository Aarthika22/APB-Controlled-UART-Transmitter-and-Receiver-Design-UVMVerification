class uart_agt_top extends uvm_env;
  `uvm_component_utils(uart_agt_top);

  uart_agt uart_agt_h;

  function new(string name ="uart_agt_top",uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    uart_agt_h = uart_agt::type_id::create("uart_agt_h",this);

  endfunction

endclass
