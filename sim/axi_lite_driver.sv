// axi_lite_driver.sv
class axi_lite_driver;

    virtual axi_lite_if.master_mp axi_if;

    function new(virtual axi_lite_if.master_mp axi_if);
        this.axi_if = axi_if;
    endfunction

    task write(axi_lite_transaction trans);
        // Write address
        axi_if.AWADDR  <= trans.addr;
        axi_if.AWVALID <= 1;
        @(posedge axi_if.ACLK);
        while (!axi_if.AWREADY) @(posedge axi_if.ACLK);
        axi_if.AWVALID <= 0;

        // Write data
        axi_if.WDATA  <= trans.data;
        axi_if.WSTRB  <= trans.strb;
        axi_if.WVALID <= 1;
        @(posedge axi_if.ACLK);
        while (!axi_if.WREADY) @(posedge axi_if.ACLK);
        axi_if.WVALID <= 0;

        // Wait for write response
        @(posedge axi_if.ACLK);
        while (!axi_if.BVALID) @(posedge axi_if.ACLK);
        trans.resp = axi_if.BRESP;
        axi_if.BREADY <= 1;
        @(posedge axi_if.ACLK);
        axi_if.BREADY <= 0;
    endtask

    task read(axi_lite_transaction trans);
        // Read address
        axi_if.ARADDR  <= trans.addr;
        axi_if.ARVALID <= 1;
        @(posedge axi_if.ACLK);
        while (!axi_if.ARREADY) @(posedge axi_if.ACLK);
        axi_if.ARVALID <= 0;

        // Wait for read data
        @(posedge axi_if.ACLK);
        while (!axi_if.RVALID) @(posedge axi_if.ACLK);
        trans.data = axi_if.RDATA;
        trans.resp = axi_if.RRESP;
        axi_if.RREADY <= 1;
        @(posedge axi_if.ACLK);
        axi_if.RREADY <= 0;
    endtask

endclass
