class test extends uvm_test;
  `uvm_component_utils(test)

  apb_config apb_cfg;
  uart_config uart_cfg;
  env_config env_cfg;
  env envh;

  function new(string name = "test",uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env_cfg = env_config::type_id::create("env_cfg",this);
    apb_cfg = apb_config::type_id::create("apb_cfg",this);
    uart_cfg = uart_config::type_id::create("uart_cfg",this);

    if(!uvm_config_db#(virtual apb_if)::get(this," ", "vif", apb_cfg.vif))
      `uvm_fatal("test apb_if","cannot get")

    if(!uvm_config_db#(virtual uart_if)::get(this," ", "vif", uart_cfg.vif))
      `uvm_fatal("test uart_if","cannot get")

    env_cfg.apb_cfg = apb_cfg;
    env_cfg.uart_cfg = uart_cfg;

//set

    uvm_config_db#(bit [7:0])::set(this,"*","lcr",8'b00000001);
    uvm_config_db#(env_config)::set(this,"*","env_config",env_cfg);

    envh = env::type_id::create("envh",this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction

endclass

class half_duplex_test extends test;
        `uvm_component_utils(half_duplex_test)

        apb_half_duplex_seq apb_half_duplex_h;
        uart_half_duplex_seq uart_half_duplex_h;
        apb_read_seq read_seqh;

        function new(string name ="half_duplex_test",uvm_component parent);
                super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                apb_half_duplex_h = apb_half_duplex_seq::type_id::create("apb_half_duplex_h");
                uart_half_duplex_h = uart_half_duplex_seq::type_id::create("uart_half_duplex_h");
                read_seqh = apb_read_seq::type_id::create("read_seqh");
        endfunction

        task run_phase(uvm_phase phase);

                phase.raise_objection(this);
                apb_half_duplex_h.start(envh.apb_agt_top_h.apb_agt_h.apb_seqr_h);
                uart_half_duplex_h.start(envh.uart_agt_top_h.uart_agt_h.uart_seqr_h);
                read_seqh.start(envh.apb_agt_top_h.apb_agt_h.apb_seqr_h);
                phase.drop_objection(this);
        endtask
endclass

class full_duplex_test extends test;
        `uvm_component_utils(full_duplex_test)

        apb_read_seq read_seqh;
        apb_full_duplex_seq apb_full_duplex_h;
        uart_full_duplex_seq uart_full_duplex_h;

        function new(string name ="full_duplex_test",uvm_component parent);
                super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                apb_full_duplex_h = apb_full_duplex_seq::type_id::create("apb_full_duplex_h");
                uart_full_duplex_h = uart_full_duplex_seq::type_id::create("uart_full_duplex_h");
                read_seqh = apb_read_seq::type_id::create("read_seqh");
        endfunction

       task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    // Step 1: Configure DUT first
    apb_full_duplex_h.start(envh.apb_agt_top_h.apb_agt_h.apb_seqr_h);

    // Step 2: Now start UART transmission after DUT is ready
    fork
        uart_full_duplex_h.start(envh.uart_agt_top_h.uart_agt_h.uart_seqr_h);
    join_none

    // Step 3: Read IIR and RBR via APB after UART frame completes
    #200000;  // wait for UART frame
    read_seqh.start(envh.apb_agt_top_h.apb_agt_h.apb_seqr_h);

    #100000;
    phase.drop_objection(this);
endtask
endclass

class loop_back_test extends test;
        `uvm_component_utils(loop_back_test)
        apb_loop_back_seq loop_back_h;
        apb_read_seq read_seqh;

        function new(string name ="loop_back_test",uvm_component parent);
                super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                loop_back_h = apb_loop_back_seq :: type_id:: create("loop_back_h");
                read_seqh = apb_read_seq::type_id::create("read_seqh");
        endfunction

        task run_phase(uvm_phase phase);

                phase.raise_objection(this);
                loop_back_h.start(envh.apb_agt_top_h.apb_agt_h.apb_seqr_h);
                read_seqh.start(envh.apb_agt_top_h.apb_agt_h.apb_seqr_h);
                phase.drop_objection(this);
        endtask
endclass

