// axi_lite_transaction.sv

`include "axi_lite_pkg.sv"
class axi_lite_transaction;

    //typedef enum {READ, WRITE} axi_lite_cmd_t;

    axi_lite_cmd_t      cmd;
    logic [31:0]        addr;
    logic [31:0]        data;
    logic [(32/8)-1:0]  strb;
    logic [1:0]         resp;

    function new();
        strb = 'hF; // Default byte enable
    endfunction

endclass
