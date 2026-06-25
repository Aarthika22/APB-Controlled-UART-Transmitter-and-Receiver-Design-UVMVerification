class apb_mon extends uvm_monitor;
  `uvm_component_utils(apb_mon)
  apb_xtn xtn;
  apb_config apb_cfg;
  virtual apb_if.apb_mon_mp vif;
  uvm_analysis_port#(apb_xtn)mon_port;

  function new(string name = "apb_mon",uvm_component parent);
    super.new(name,parent);
    mon_port = new("mon_port",this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(apb_config)::get(this," ","apb_config",apb_cfg))
      `uvm_fatal("APB_MON","cannot get")

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    vif = apb_cfg.vif;
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      $display("sample");
      collect();
    end
  endtask

  task collect();
    xtn = apb_xtn::type_id::create("xtn");
    $display("sample");
    @(vif.apb_mon_cb);

    $display("sample");
    while(!vif.apb_mon_cb.PENABLE)
    @(vif.apb_mon_cb);
    $display("sample");
    while(!vif.apb_mon_cb.PREADY)
    @(vif.apb_mon_cb);

    xtn.PADDR = vif.apb_mon_cb.PADDR;
    xtn.PWRITE = vif.apb_mon_cb.PWRITE;
    xtn.PREADY = vif.apb_mon_cb.PREADY;
    xtn.PSLVERR = vif.apb_mon_cb.PSLVERR;
    xtn.IRQ= vif.apb_mon_cb.IRQ;
    xtn.PENABLE = vif.apb_mon_cb.PENABLE;
    xtn.PSEL = vif.apb_mon_cb.PSEL;
    xtn.PRESETn = vif.apb_mon_cb.PRESETn;

    if(vif.apb_mon_cb.PWRITE == 1)
        xtn.PWDATA = vif.apb_mon_cb.PWDATA;
    else
        xtn.PRDATA = vif.apb_mon_cb.PRDATA;

    if(xtn.PADDR == 32'hc && xtn.PWRITE ==1 )
        xtn.lcr = xtn.PWDATA;
    if(xtn.PADDR == 32'h4 && xtn.PWRITE == 1)
        xtn.ier = xtn.PWDATA;
    if(xtn.PADDR == 32'h8  && xtn.PWRITE == 1)
        xtn.fcr = xtn.PWDATA;

    if(xtn.PADDR == 32'h8 && xtn.PWRITE ==0 )
    begin
      while(!vif.apb_mon_cb.IRQ)
      @(vif.apb_mon_cb);
      xtn.iir = vif.apb_mon_cb.PRDATA;
    end

    if(xtn.PADDR == 32'h1c   && xtn.PWRITE == 1)
    begin
      xtn.div[7:0] = xtn.PWDATA;
      xtn.dl_access = 1;
    end
  
    if(xtn.PADDR == 32'h1c   && xtn.PWRITE == 1)
    begin
      xtn.div[7:0] = xtn.PWDATA;
      xtn.dl_access = 1;
    end

    if(xtn.PADDR == 32'h20  && xtn.PWRITE ==1 )
    begin
      xtn.div[15:8] = xtn.PWDATA;
      xtn.dl_access = 1;
    end

    if(xtn.PADDR == 32'h0   && xtn.PWRITE ==1 )
    begin
      xtn.thr.push_back(xtn.PWDATA[7:0]);
      xtn.data_in_thr = 1;
    end

    if(xtn.PADDR == 32'h0   && xtn.PWRITE ==0 )
    begin
      xtn.rbr.push_back(xtn.PWDATA[7:0]);
      xtn.data_in_rbr = 1;
    end

    if(xtn.PADDR == 32'h10   && xtn.PWRITE ==1'b1 )
    begin
      xtn.mcr = xtn.PWDATA;
      xtn.print();
      `uvm_info("APB_MON",$sformatf("%s",xtn.sprint()),UVM_MEDIUM)

      mon_port.write(xtn);
    end
  endtask

endclass
        
