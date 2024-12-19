// axi_stream_driver.sv
class axi_stream_driver;

    virtual axi_stream_if.master_mp axi_if;

    function new(virtual axi_stream_if.master_mp axi_if);
        this.axi_if = axi_if;
    endfunction

    task send(axi_stream_transaction trans);
        axi_if.TDATA  <= trans.data;
        axi_if.TLAST  <= trans.last;
        axi_if.TVALID <= 1;
        @(posedge axi_if.ACLK);
        while (!axi_if.TREADY) @(posedge axi_if.ACLK);
        axi_if.TVALID <= 0;
    endtask

endclass
