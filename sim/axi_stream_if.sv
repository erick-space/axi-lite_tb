// axi_stream_if.sv
interface axi_stream_if #(parameter DATA_WIDTH = 32)(input logic ACLK, input logic ARESETn);

    logic [DATA_WIDTH-1:0] TDATA;
    logic                  TVALID;
    logic                  TREADY;
    logic                  TLAST;

    modport master_mp (
        output TDATA, TVALID, TLAST,
        input  TREADY
    );

    modport slave_mp (
        input  TDATA, TVALID, TLAST,
        output TREADY
    );

endinterface
