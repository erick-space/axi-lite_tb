`timescale 1ns/1ps

`include "axi_lite_pkg.sv"
`include "axi_lite_transaction.sv"
class axi_lite_agent;

    axi_lite_driver    driver;
    axi_lite_sequencer sequencer;
    axi_lite_monitor   monitor;
    virtual axi_lite_if axi_if;

    function new(virtual axi_lite_if axi_if);
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

    task driver_run();
        axi_lite_transaction trans;
        forever begin
            sequencer.trans_mbx.get(trans);
            case (trans.cmd)
                WRITE: driver.write(trans);
                READ : driver.read(trans);
            endcase
        end
    endtask

endclass
