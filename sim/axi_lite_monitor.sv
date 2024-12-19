// axi_lite_monitor.sv
class axi_lite_monitor;

    virtual axi_lite_if.slave_mp axi_if;
    mailbox #(axi_lite_transaction) trans_mbx;

    function new(virtual axi_lite_if.slave_mp axi_if);
        this.axi_if = axi_if;
        trans_mbx = new();
    endfunction

    task run();
        axi_lite_transaction trans;
        forever begin
            // Implement monitoring logic to capture transactions
            // Example: Monitor write responses
            @(posedge axi_if.ACLK);
            if (axi_if.BVALID && axi_if.BREADY) begin
                trans = new();
                trans.resp = axi_if.BRESP;
                trans_mbx.put(trans);
            end
            // Similar logic for read data can be added
        end
    endtask

endclass
