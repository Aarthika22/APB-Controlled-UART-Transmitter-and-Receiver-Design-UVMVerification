class apb_drv extends uvm_driver#(apb_xtn);
  `uvm_component_utils(apb_drv)

  apb_config apb_cfg;
  virtual apb_if.apb_drv_mp vif;

  function new(string name = "apb_drv",uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(apb_config)::get(this," ","apb_config",apb_cfg))
      `uvm_fatal("APB_DRV","cannot get")
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    vif = apb_cfg.vif;
  endfunction

  task run_phase(uvm_phase phase);
    @(vif.apb_drv_cb);
    vif.apb_drv_cb.PRESETn <= 0;
    @(vif.apb_drv_cb);
    vif.apb_drv_cb.PRESETn <= 1;

    forever begin
        seq_item_port.get_next_item(req);
        //`uvm_info("APB_DRV","recieved",UVM_MEDIUM)
        //req.print();

        drive(req);
       `uvm_info("APB_Drv",$sformatf("%s",req.sprint()),UVM_MEDIUM)
        seq_item_port.item_done();
    end
  endtask
  
  task drive(apb_xtn req);
    @(vif.apb_drv_cb);
    vif.apb_drv_cb.PADDR <= req.PADDR;
    vif.apb_drv_cb.PWDATA <= req.PWDATA;
    vif.apb_drv_cb.PWRITE <= req.PWRITE;
    vif.apb_drv_cb.PENABLE <= 0;
    vif.apb_drv_cb.PSEL <= 1;

    @(vif.apb_drv_cb);
    vif.apb_drv_cb.PENABLE <= 1;

    @(vif.apb_drv_cb);
    while(!vif.apb_drv_cb.PREADY)
    @(vif.apb_drv_cb);

    if(req.PADDR == 32'h8 && req.PWRITE == 0)
      begin
        while(vif.apb_drv_cb.IRQ ==0)
          @(vif.apb_drv_cb);
          req.iir = vif.apb_drv_cb.PRDATA;

          seq_item_port.put_response(req);

          vif.apb_drv_cb.PENABLE <= 0;
          vif.apb_drv_cb.PSEL <= 0;
      end
  endtask

endclass
        
  
