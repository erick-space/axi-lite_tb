`timescale 1ns/1ps

`include "axi_lite_transaction.sv"
`include "axi_lite_driver.sv"
`include "axi_lite_monitor.sv"
`include "axi_lite_sequencer.sv"
`include "axi_stream_transaction.sv"
`include "axi_stream_driver.sv"
`include "axi_stream_monitor.sv"
`include "axi_stream_sequencer.sv"

module testbench;

    logic ACLK;
    logic ARESETn;

    // Clock generation
    always #5 ACLK = ~ACLK;

    initial begin
        ACLK = 1'b0;
        ARESETn = 1'b0;
        #20 ARESETn = 1'b1;
    end

    // Instantiate AXI Lite and AXI Stream interfaces
    axi_lite_if #(32,32) axi_lite_if_inst(.ACLK(ACLK), .ARESETn(ARESETn));
    axi_stream_if #(32)  axi_stream_if_inst(.ACLK(ACLK), .ARESETn(ARESETn));

    // Instantiate DUT
    dut #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .FIFO_DEPTH(16)
    ) u_dut (
        .ACLK(ACLK),
        .ARESETn(ARESETn),

        // AXI Lite
        .s_axi_awaddr(axi_lite_if_inst.AWADDR),
        .s_axi_awvalid(axi_lite_if_inst.AWVALID),
        .s_axi_awready(axi_lite_if_inst.AWREADY),
        .s_axi_wdata(axi_lite_if_inst.WDATA),
        .s_axi_wstrb(axi_lite_if_inst.WSTRB),
        .s_axi_wvalid(axi_lite_if_inst.WVALID),
        .s_axi_wready(axi_lite_if_inst.WREADY),
        .s_axi_bresp(axi_lite_if_inst.BRESP),
        .s_axi_bvalid(axi_lite_if_inst.BVALID),
        .s_axi_bready(axi_lite_if_inst.BREADY),
        .s_axi_araddr(axi_lite_if_inst.ARADDR),
        .s_axi_arvalid(axi_lite_if_inst.ARVALID),
        .s_axi_arready(axi_lite_if_inst.ARREADY),
        .s_axi_rdata(axi_lite_if_inst.RDATA),
        .s_axi_rresp(axi_lite_if_inst.RRESP),
        .s_axi_rvalid(axi_lite_if_inst.RVALID),
        .s_axi_rready(axi_lite_if_inst.RREADY),

        // AXI Stream
        .s_axis_tdata(axi_stream_if_inst.TDATA),
        .s_axis_tvalid(axi_stream_if_inst.TVALID),
        .s_axis_tready(axi_stream_if_inst.TREADY),
        .s_axis_tlast(axi_stream_if_inst.TLAST)
    );

    // Create Agents
    axi_lite_agent    axi_lite_agent_inst = new(axi_lite_if_inst);
    //axi_stream_agent  axi_stream_agent_inst = new(axi_stream_if_inst);
    axi_lite_transaction axi_trans_reset = new();
    axi_lite_transaction axi_trans_read = new();

    initial begin
        // Start agents
        fork
            axi_lite_agent_inst.run();
            //axi_stream_agent_inst.run();
        join_none

        // Wait for reset deassertion
        wait(ARESETn == 1);
        #100;

        // 1) Reset FIFO via AXI Lite
   
        axi_trans_reset.cmd  = axi_lite_transaction::WRITE;
        axi_trans_reset.addr = 32'h0000_0000; // Control Reg
        axi_trans_reset.data = 32'h0000_0001; // Set FIFO reset bit
        axi_lite_agent_inst.sequencer.send(axi_trans_reset);

        #100;

        // 2) Send multiple data words via AXI Stream
        // Let's send 5 words
        for (int i = 0; i < 5; i++) begin
            //axi_stream_transaction stream_trans = new($random, i == 4); // last = 1 for last word
            //axi_stream_agent_inst.driver.send(stream_trans);
        end

        #100;

        // 3) Read status register to verify occupancy
        
        axi_trans_read.cmd  = axi_lite_transaction::READ;
        axi_trans_read.addr = 32'h0000_0004; // Status Reg
        axi_lite_agent_inst.sequencer.send(axi_trans_read);

        // Wait some cycles and then end simulation
        #500;
        $display("TEST COMPLETE");
        $finish;
    end

endmodule
