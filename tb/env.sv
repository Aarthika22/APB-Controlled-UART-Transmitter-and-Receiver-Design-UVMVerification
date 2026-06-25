class env extends uvm_env;

  `uvm_component_utils(env)

  apb_agt_top apb_agt_top_h;
  uart_agt_top uart_agt_top_h;
  sb sbh;
  env_config env_cfg;
  apb_config apb_cfg;
  uart_config uart_cfg;

  function new(string name="env",uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    apb_agt_top_h = apb_agt_top::type_id::create("apb_agt_top_h",this);
    uart_agt_top_h = uart_agt_top::type_id::create("uart_agt_top_h",this);
    sbh = sb::type_id::create("sbh",this);
    env_cfg = env_config::type_id::create("env_cfg",this);
    apb_cfg = apb_config::type_id::create("apb_cfg",this);
    uart_cfg = uart_config::type_id::create("uart_cfg",this);

    if(!uvm_config_db#(env_config)::get(this," ","env_config",env_cfg))
      `uvm_fatal("evn","cannot get")

      apb_cfg = env_cfg.apb_cfg;
      uart_cfg= env_cfg.uart_cfg;

//set

      uvm_config_db#(apb_config)::set(this,"apb_agt_top_h*","apb_config",apb_cfg);

      uvm_config_db#(uart_config)::set(this,"uart_agt_top_h*","uart_config",uart_cfg);

  endfunction

endclass
