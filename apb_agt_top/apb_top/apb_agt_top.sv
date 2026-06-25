class apb_agt_top extends uvm_env;
`uvm_component_utils(apb_agt_top);

apb_agt apb_agt_h;

  function new(string name ="apb_agt_top",uvm_component parent);
      super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      apb_agt_h = apb_agt::type_id::create("apb_agt_h",this);
  endfunction

endclass
