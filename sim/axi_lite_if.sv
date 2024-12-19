// axi_lite_if.sv
interface axi_lite_if #(parameter ADDR_WIDTH = 32, DATA_WIDTH = 32)(input logic ACLK, input logic ARESETn);

    // Write address channel signals
    logic [ADDR_WIDTH-1:0] AWADDR;
    logic                  AWVALID;
    logic                  AWREADY;

    // Write data channel signals
    logic [DATA_WIDTH-1:0] WDATA;
    logic [(DATA_WIDTH/8)-1:0] WSTRB;
    logic                      WVALID;
    logic                      WREADY;

    // Write response channel signals
    logic [1:0]                BRESP;
    logic                      BVALID;
    logic                      BREADY;

    // Read address channel signals
    logic [ADDR_WIDTH-1:0] ARADDR;
    logic                  ARVALID;
    logic                  ARREADY;

    // Read data channel signals
    logic [DATA_WIDTH-1:0] RDATA;
    logic [1:0]            RRESP;
    logic                  RVALID;
    logic                  RREADY;

    // Master modport (for the driver)
    modport master_mp (
        output AWADDR, AWVALID, WDATA, WSTRB, WVALID, BREADY, ARADDR, ARVALID, RREADY,
        input  AWREADY, WREADY, BRESP, BVALID, ARREADY, RDATA, RRESP, RVALID
    );

    // Slave modport (for the monitor)
    modport slave_mp (
        input  AWADDR, AWVALID, WDATA, WSTRB, WVALID, BREADY, ARADDR, ARVALID, RREADY,
        output AWREADY, WREADY, BRESP, BVALID, ARREADY, RDATA, RRESP, RVALID
    );

endinterface
