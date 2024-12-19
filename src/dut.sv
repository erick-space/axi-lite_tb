`timescale 1ns/1ps

module dut #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter FIFO_DEPTH = 16
)(
    input  logic                  ACLK,
    input  logic                  ARESETn,

    // AXI Lite Slave Interface
    input  logic [ADDR_WIDTH-1:0] s_axi_awaddr,
    input  logic                  s_axi_awvalid,
    output logic                  s_axi_awready,

    input  logic [DATA_WIDTH-1:0] s_axi_wdata,
    input  logic [(DATA_WIDTH/8)-1:0] s_axi_wstrb,
    input  logic                  s_axi_wvalid,
    output logic                  s_axi_wready,

    output logic [1:0]            s_axi_bresp,
    output logic                  s_axi_bvalid,
    input  logic                  s_axi_bready,

    input  logic [ADDR_WIDTH-1:0] s_axi_araddr,
    input  logic                  s_axi_arvalid,
    output logic                  s_axi_arready,

    output logic [DATA_WIDTH-1:0] s_axi_rdata,
    output logic [1:0]            s_axi_rresp,
    output logic                  s_axi_rvalid,
    input  logic                  s_axi_rready,

    // AXI Stream Slave Interface (to FIFO)
    input  logic [DATA_WIDTH-1:0] s_axis_tdata,
    input  logic                  s_axis_tvalid,
    output logic                  s_axis_tready,
    input  logic                  s_axis_tlast
);

    //--------------------------------------------
    // Internal Registers for AXI Lite
    //--------------------------------------------
    // Register Map:
    // 0x00: Control Register (bit 0: FIFO reset)
    // 0x04: Status Register (bit[15:0] = FIFO occupancy)

    logic [31:0] control_reg;
    logic [31:0] status_reg;

    //--------------------------------------------
    // FIFO Implementation
    //--------------------------------------------
    logic [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];
    logic [$clog2(FIFO_DEPTH):0] write_ptr;
    logic [$clog2(FIFO_DEPTH):0] read_ptr; // Not used if no read, but kept for completeness
    logic [$clog2(FIFO_DEPTH):0] occupancy;

    // Write logic for FIFO from AXI-Stream
    assign s_axis_tready = (occupancy < FIFO_DEPTH);

    always_ff @(posedge ACLK or negedge ARESETn) begin
        if(!ARESETn) begin
            write_ptr <= '0;
            occupancy <= '0;
        end else begin
            if (control_reg[0]) begin
                // If FIFO reset requested
                write_ptr <= '0;
                occupancy <= '0;
            end else begin
                if (s_axis_tvalid && s_axis_tready) begin
                    fifo_mem[write_ptr] <= s_axis_tdata;
                    write_ptr <= write_ptr + 1;
                    occupancy <= occupancy + 1;
                end
            end
        end
    end

    // Update status register (occupancy)
    always_comb begin
        status_reg = 32'h0;
        status_reg[15:0] = occupancy;
    end

    //--------------------------------------------
    // AXI Lite Slave Logic (Simple Protocol)
    //--------------------------------------------
    // This is a simplified AXI-Lite interface handler.
    // In a real design, you would handle multiple beats, etc.

    // Write Address Handshake
    assign s_axi_awready = 1;
    // Write Data Handshake
    assign s_axi_wready  = 1;

    // Write Response
    reg write_done;
    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            control_reg <= 32'h0;
            write_done  <= 1'b0;
        end else begin
            write_done <= 1'b0;
            if (s_axi_awvalid && s_axi_wvalid && s_axi_bready) begin
                // Decode address
                case (s_axi_awaddr[5:2])
                    4'h0: begin
                        // Control register write
                        control_reg <= s_axi_wdata;
                        // If FIFO reset bit set, clear it immediately after
                        if (s_axi_wdata[0]) begin
                            control_reg[0] <= 1'b0;
                        end
                        write_done <= 1'b1;
                    end
                    default: begin
                        // Writes to other addresses can be ignored or handled
                        write_done <= 1'b1;
                    end
                endcase
            end
        end
    end

    assign s_axi_bvalid = write_done;
    assign s_axi_bresp  = 2'b00; // OKAY response

    // Read Address Handshake
    assign s_axi_arready = 1;

    // Read Data
    reg read_valid;
    always_ff @(posedge ACLK or negedge ARESETn) begin
        if(!ARESETn) begin
            read_valid <= 1'b0;
        end else begin
            read_valid <= 1'b0;
            if (s_axi_arvalid && s_axi_rready) begin
                case (s_axi_araddr[5:2])
                    4'h0: s_axi_rdata <= control_reg;
                    4'h1: s_axi_rdata <= status_reg;
                    default: s_axi_rdata <= 32'hDEAD_BEEF;
                endcase
                read_valid <= 1'b1;
            end
        end
    end

    assign s_axi_rvalid = read_valid;
    assign s_axi_rresp  = 2'b00; // OKAY

endmodule
