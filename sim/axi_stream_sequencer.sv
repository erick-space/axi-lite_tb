`timescale 1ns/1ps

class axi_stream_sequencer;

    // The sequencer holds transactions and provides them to the driver as needed.
    mailbox #(axi_stream_transaction) trans_mbx;

    function new();
        trans_mbx = new();
    endfunction

    // The send task places a transaction into the mailbox.
    // The driver will retrieve and execute these transactions.
    task send(axi_stream_transaction trans);
        trans_mbx.put(trans);
    endtask

endclass
