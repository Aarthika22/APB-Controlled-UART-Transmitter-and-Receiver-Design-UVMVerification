class uart_config extends uvm_object;
  `uvm_object_utils(uart_config)

  function new(string name ="uart_config");
    super.new(name);
  endfunction

  virtual uart_if vif;

endclass
