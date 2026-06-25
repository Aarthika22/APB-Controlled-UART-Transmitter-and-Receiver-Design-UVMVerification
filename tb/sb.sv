class sb extends uvm_scoreboard;
        `uvm_component_utils(sb)
        bit [7:0] reg_lcr;
        bit[7:0] reg_ier;
        bit[7:0] reg_iir;
        bit[7:0] reg_mcr;
        bit[7:0] reg_fcr;
        bit[7:0] reg_lsr;

        bit[7:0] pwdata;

        env_config env_cfg;
        apb_xtn apb_xtn_h;
        uart_xtn uart_xtn_h;

        apb_xtn apb_iir_xtn_h;
        apb_xtn apb_cov;

        int thrlsize, rbrlsize;
        uvm_tlm_analysis_fifo#(apb_xtn) apb_fifo;   //apb write trans
        uvm_tlm_analysis_fifo#(uart_xtn) uart_fifo; //uart read trans

     

        uvm_status_e  status;

        covergroup apb_signals_cov;
                option.per_instance = 1;
                ADDRESS : coverpoint apb_cov.PADDR{
                        bins addr_0 = {32'h0};
                        bins addr_4 = {32'h4};
                        bins addr_8 = {32'h8};
                        bins addr_c = {32'hc};
                        bins addr_1c = {32'h1c};
                        bins addr_20 = {32'h20};
                }
                WRITE : coverpoint apb_cov.PWRITE {
                        bins write = {1};
                        bins read = {0};
                }
                DATA : coverpoint apb_cov.PWDATA {


                        bins data_0 = {[0:255]};
                }
        endgroup
        covergroup apb_ier_cov;
                option.per_instance = 1;
                RECIVE_DATA_INT : coverpoint apb_cov.ier[0] {
                        bins rec_data_int_disabled = {0};
                        bins rec_data_int_enabled = {1};
                }
                THR_EMPTY_INT : coverpoint apb_cov.ier[1] {
                        bins thr_empty_int_disabled = {0};
                        bins thr_empty_int_enabled = {1};
                }
                LINE_STATUS_INT : coverpoint apb_cov.ier[2] {
                        bins line_status_int_disabled = {0};
                        bins line_status_int_enabled = {1};
                }
                IER_RST : coverpoint apb_cov.ier {
                        bins ier_reset = {0};
                }
        endgroup

         covergroup apb_fcr_cov;
                option.per_instance = 1;

                RX_FIFO_RST : coverpoint apb_cov.fcr[1] {
                        bins rx_fifo_not_rst = {0};
                        bins rx_fifo_rst = {1};
                }
                TX_FIFO_RST : coverpoint apb_cov.fcr[2] {
                        bins tx_fifo_not_rst = {0};
                        bins tx_fifo_rst = {1};
                }
                FIFO_TRIGGER_LEVEL : coverpoint apb_cov.fcr[7:6] {
                        bins level_1_byte = {2'b00};
                        bins level_4_byte = {2'b01};
                        bins level_8_byte = {2'b10};
                        bins level_14_byte = {2'b11};
                }
        endgroup

        covergroup apb_iir_cov;
                option.per_instance = 1;

                LINE_STATUS_INT: coverpoint apb_cov.ier {
                        bins line_status_int = {3'b110};
                }
                REC_DATA_INT: coverpoint apb_cov.ier {
                        bins rec_data_int = {3'b100};
                }
                THR_EMPTY_INT: coverpoint apb_cov.ier {
                        bins thr_empty_int = {3'b010};
                }
                TIMEOUT_INT: coverpoint apb_cov.ier {
                        bins timeout_int = {8'h0c};
                }

        endgroup

        covergroup apb_lcr_cov;
                option.per_instance = 1;
                CHAR_SIZE : coverpoint apb_cov.lcr[1:0] {
                        bins five = {2'b00};
                        bins eight = {2'b11};
                }

                STOP_BIT : coverpoint apb_cov.lcr[2] {
                        bins one_stop_bit = {0};
                        bins two_stop_bit = {1};
                }

                PARITY_ENABLE: coverpoint apb_cov.lcr[3] {
                        bins parity_disabled = {0};
                        bins parity_enabled = {1};
                }

                EVEN_ODD_PARITY: coverpoint apb_cov.lcr[4] {
                        bins even_parity = {1};
                        bins odd_parity = {0};
                }
        endgroup


         covergroup apb_lsr_cov;
                option.per_instance = 1;

                DATA_READY: coverpoint apb_cov.lsr[0] {
                        bins data_not_ready = {0};
                        bins data_ready = {1};
                }
                THR_EMPTY: coverpoint apb_cov.lsr[5] {
                        bins thr_not_empty = {0};
                        bins thr_empty = {1};
                }
                 OVR_ERR: coverpoint apb_cov.lsr[1] {
                        bins no_overrun_error = {0};
                        bins overrun_error = {1};
                }
                 PARITY_ERR: coverpoint apb_cov.lsr[2] {
                        bins no_parity_error = {0};
                        bins parity_error = {1};
                }
                 FRM_ERR: coverpoint apb_cov.lsr[3] {
                        bins no_framing_error = {0};
                        bins framing_error = {1};
                }
                 BRK_INT: coverpoint apb_cov.lsr[4] {
                        bins no_break_interrupt = {0};
                        bins break_interrupt = {1};
                }
        endgroup

        function new(string name = "",uvm_component parent);
                super.new(name,parent);
                apb_fifo = new("apb_fifo", this);
                uart_fifo = new("uart_fifo", this);
                apb_signals_cov = new();
                apb_lcr_cov = new();
                apb_ier_cov = new();
                apb_fcr_cov = new();
                apb_iir_cov = new();
                apb_lsr_cov = new();

        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                env_cfg = env_config::type_id::create("env_cfg");

                if(env_cfg==null)
                        `uvm_fatal("FATAL", "null")
                if(!uvm_config_db#(env_config)::get(this,"","env_config",env_cfg))
                        `uvm_fatal("FATAL", "SB : env conf getting failed")
                


        endfunction

         task run_phase(uvm_phase phase);
           fork
                forever begin
                        apb_fifo.get(apb_xtn_h); //uart1
                        apb_cov = apb_xtn_h;
                        //$display(" ################  SCORE BOARD #######################################################################################3#");
                       // apb_xtn_h.print();
                        apb_signals_cov.sample(); // covergroup sampling
                        apb_lcr_cov.sample();
                        apb_ier_cov.sample();
                        apb_fcr_cov.sample();
                        apb_iir_cov.sample();
                        apb_lsr_cov.sample();

                        thrlsize = apb_xtn_h.thr.size();
                        rbrlsize = apb_xtn_h.rbr.size();

                        if(apb_xtn_h.mcr[4])
                                begin
                                 if(apb_xtn_h.PADDR == 32'h0 && apb_xtn_h.PWRITE==1)
                                        pwdata = apb_xtn_h.PWDATA[7:0];
                                 $display(" pwdata when loopback is active : %0d", pwdata);
                                end
                        `uvm_info("SB", "PRINTING APB TRANSACTION IN SCOREBOARD", UVM_LOW)
                        apb_xtn_h.print();

                end

                forever begin
                        uart_fifo.get(uart_xtn_h);//uart2
                        `uvm_info("SB", "PRINTING UART TRANSACTION IN SCOREBOARD", UVM_LOW)
                        uart_xtn_h.print();
                    
                end
           join_none
        endtask
        
         function void check_phase(uvm_phase phase); // this will run after run phase and hence takes the value of last trasaction only
                if(apb_xtn_h == null) begin
                 `uvm_error("SB","apb_xtn_h is null")
                  return;
                end

                if(uart_xtn_h == null) begin
                        `uvm_error("SB","uart_xtn_h is null")
                        return;
                end
                super.check_phase(phase);
                 `uvm_info("SB", $sformatf("size of thr : %0d", thrlsize), UVM_LOW)
                 `uvm_info("SB", $sformatf("data in thr : %0d", apb_xtn_h.data_in_thr), UVM_LOW)
                `uvm_info("SB", $sformatf("size of rbr : %0d", rbrlsize), UVM_LOW)
                `uvm_info("SB", $sformatf(" APB : PRDATA : %0d", apb_xtn_h.PRDATA[7:0]), UVM_LOW)
                `uvm_info("SB", $sformatf(" APB : PWDATA : %0d", apb_xtn_h.PWDATA[7:0]), UVM_LOW)
                `uvm_info("SB", $sformatf("values send by UART1(APB)| thr : %p", apb_xtn_h.thr), UVM_LOW)

                `uvm_info("SB", $sformatf("values received by UART1(APB) | rbr : %p", apb_xtn_h.rbr), UVM_LOW)
                `uvm_info("SB", $sformatf("values of iir register : %b", apb_xtn_h.iir), UVM_LOW)



                if(apb_xtn_h.iir[3:1] == 3'b010)  begin   //check whether receiver data interupt is there
                   if(apb_xtn_h.mcr[4]==0)
                       begin

                                 `uvm_info("SB", $sformatf("values sent by UART2(UART) | tx : %p", uart_xtn_h.tx), UVM_LOW)
                                 `uvm_info("SB", $sformatf("values received by UART2(UART) | rx : %p", uart_xtn_h.rx), UVM_LOW)
                        if(thrlsize==0) begin  // thr should ne empty
                                if((apb_xtn_h.PWDATA[7:0] == uart_xtn_h.rx) || (uart_xtn_h.tx==apb_xtn_h.PRDATA[7:0]))
                                      begin
                                        $display("\n******************************************************************************************************");
                                        `uvm_info("SB", "half duplex comparision is successful", UVM_LOW)
                                        $display("********************************************************************************************************");
                                       end

                                else
                                        begin
                                        $display("\nxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
                                        `uvm_error("SB", "half duplex comparision failed")
                                        $display("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
                                        end
                        end

                        else begin
                              if((apb_xtn_h.PWDATA[7:0] == uart_xtn_h.rx) || (uart_xtn_h.tx==apb_xtn_h.PRDATA[7:0]))
                                begin
                                        $display("\n******************************************************************************************************");
                                        `uvm_info("SB", "full duplex comparision is successful", UVM_LOW)
                                        $display("********************************************************************************************************");
                                end

                                else
                                        begin
                                        $display("\nxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
                                        `uvm_error("SB", "full duplex comparision failed")
                                        $display("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
                                        end
                        end

                        end

                   else
                        begin
                                if((pwdata==apb_xtn_h.PRDATA[7:0]))
                                begin
                                        $display("\n******************************************************************************************************");
                                          `uvm_info("SB","\n in score board loop back comparission passed",UVM_LOW)
                                        $display("\n******************************************************************************************************");
                                end
                                else begin
                                         $display("---------------------------------------------------------------------------");
                                         `uvm_info("SB","\n in score board loop back comparision failed",UVM_LOW)
                                         $display("---------------------------------------------------------------------------");

                                 end
                        end
                end

                if(apb_xtn_h.iir[3:1] == 3) begin   //check whether transmitter empty interupt is there
                        if(apb_xtn_h.lsr[1] == 1)   // check whether transmitter is empty or not
                                `uvm_info("SB", "overrun error occured", UVM_LOW)
                        if(apb_xtn_h.lsr[2]==1)    // check whether transmitter is empty or not
                                `uvm_info("SB", "parity error occured", UVM_LOW)
                        if(apb_xtn_h.lsr[3]==1)    // check whether transmitter is empty or not
                                `uvm_info("SB", "framing error occured", UVM_LOW)
                        if(apb_xtn_h.lsr[4]==1)    // check whether transmitter is empty or not
                                `uvm_info("SB", "break interrupt occured", UVM_LOW)
                end

                if(apb_xtn_h.iir[3:1] == 3'b110)    //check whether line status interupt is there
                         `uvm_info("SB", "time out error occured", UVM_LOW)
                 if(apb_xtn_h.iir[3:1] == 3'b001)    //check whether line status interupt is there
                         `uvm_info("SB", "thr empty error occured", UVM_LOW)

        endfunction

        
endclass
