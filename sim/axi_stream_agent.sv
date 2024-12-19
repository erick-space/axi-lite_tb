`timescale 1ns/1ps

// Include external class files

class axi_stream_agent;

    axi_stream_driver    driver;
    axi_stream_sequencer sequencer;
    axi_stream_monitor   monitor;
    virtual axi_stream_if axi_if;

    function new(virtual axi_stream_if axi_if);
        this.axi_if = axi_if;
        driver    = new(axi_if.master_mp);
        sequencer = new();
        monitor   = new(axi_if.slave_mp);
    endfunction

    task run();
        fork
            driver_run();
            monitor.run();
        join_none
    endtask
    
    axi_stream_transaction trans;
    task driver_run();
        
        forever begin
            sequencer.trans_mbx.get(trans);
            driver.send(trans);
        end
    endtask

endclass
