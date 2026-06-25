class env_config extends uvm_object;
 `uvm_object_utils(env_config)

   function new(string name ="");
     super.new(name);
   endfunction

  uart_config uart_cfg;
 apb_config apb_cfg;
endclass
