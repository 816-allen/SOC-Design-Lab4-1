module user_proj_example #(
    parameter BITS = 32,
    parameter DELAYS=10
)(
`ifdef USE_POWER_PINS
    inout vccd1, // User area 1 1.8V supply
    inout vssd1, // User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output reg wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);

    reg [3:0] counter, _counter;
    reg bram_en;
    always@*begin
        if(counter==DELAYS+1)begin
            _counter = 0;
        end
        else begin
            if(wbs_cyc_i&wbs_stb_i)begin
                _counter = counter + 1;
            end
            else begin
                _counter = 0;
            end
        end
    end
    always @(*) begin
        wbs_ack_o = 0;
        bram_en = 0;
        case (counter)
            DELAYS: begin
                bram_en = 1;
            end
            DELAYS+1:begin
                wbs_ack_o = 1;
                bram_en = 1;
            end
        endcase
    end
    
    always@(posedge wb_clk_i)begin
        if(wb_rst_i)begin
            counter <= 0;
        end
        else begin
            counter <= _counter;
        end
    end
 
 
    bram user_bram (
        .CLK(wb_clk_i),
        .WE0(wbs_sel_i&{4{wbs_we_i}}),//wbs_sel_i-->[1111]indicates 4bytes can write data into bram,[1110]indicates //3bytes can write data into bram
        .EN0(bram_en),
        .Di0(wbs_dat_i),
        .Do0(wbs_dat_o),
        .A0(wbs_adr_i&32'h0000ffff)
    );

endmodule


