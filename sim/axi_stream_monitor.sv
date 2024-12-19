`timescale 1ns/1ps

class axi_stream_monitor;

    // This monitor observes the AXI Stream interface from the slave perspective
    // (i.e., it sees transactions that the driver (master) sends).
    virtual axi_stream_if.slave_mp axi_if;
    mailbox #(axi_stream_transaction) mon_mbx;

    function new(virtual axi_stream_if.slave_mp axi_if);
        this.axi_if = axi_if;
        mon_mbx = new();
    endfunction

    task run();
        axi_stream_transaction trans;
        forever begin
            @(posedge axi_if.ACLK);
            if (axi_if.TVALID && axi_if.TREADY) begin
                // Capture a transaction whenever TVALID and TREADY are both high
                trans = new();
                trans.data = axi_if.TDATA;
                trans.last = axi_if.TLAST;
                mon_mbx.put(trans);
            end
        end
    endtask

endclass
