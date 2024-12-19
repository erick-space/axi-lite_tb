// axi_lite_sequencer.sv
class axi_lite_sequencer;

    mailbox #(axi_lite_transaction) trans_mbx;

    function new();
        trans_mbx = new();
    endfunction

    task send(axi_lite_transaction trans);
        trans_mbx.put(trans);
    endtask

endclass
