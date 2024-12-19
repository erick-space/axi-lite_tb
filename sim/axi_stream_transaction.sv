// axi_stream_transaction.sv
class axi_stream_transaction;

    logic [31:0] data;
    logic        last;

    function new(logic [31:0] data = '0, logic last = 0);
        this.data = data;
        this.last = last;
    endfunction

endclass
