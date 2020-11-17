module sort_net#(
    parameter   DATA_W      = 8,
    parameter   LOG_SIZE    = 4,
    parameter   SIZE        = 2 ** LOG_SIZE
    )(
    input   clk,
    input   rst_n,

    input   [DATA_W * SIZE  -1 : 0] i_din,
    output  [DATA_W * SIZE  -1 : 0] o_dout
    );

    

endmodule

module merge_2 #(
    parameter   DATA_W      = 8,
    parameter   LOG_SIZE    = 4,
    parameter   SIZE        = 2 ** LOG_SIZE
    )(
    input   clk,
    input   ce,

    input   [DATA_W * SIZE  -1 : 0] i_din,
    output  [DATA_W * SIZE  -1 : 0] o_dout
    );

    genvar i, j;
    generate
        for (i = LOG_SIZE - 1; i >= 0; i = i - 1) begin: LEVEL
            wire    [DATA_W * SIZE  -1 : 0] din;
            wire    [DATA_W * SIZE  -1 : 0] dout;

            for (j = 0; j = j + 1; j++) begin: LEVEL
                
            end
        end
    endgenerate

endmodule

module swap_by_order#(
    parameter   DATA_W  = 8
    )(
    input   clk,
    input   ce,

    input   [DATA_W -1 : 0] i_data_a,
    input   [DATA_W -1 : 0] i_data_b,

    output  [DATA_W -1 : 0] o_data_a,
    output  [DATA_W -1 : 0] o_data_b
    );

    reg     [DATA_W -1 : 0] data_a_r;
    reg     [DATA_W -1 : 0] data_b_r;

    assign  o_data_a = data_a_r;
    assign  o_data_b = data_b_r;

    always @ (posedge clk) begin
        if (ce) begin
            if (i_data_a > i_data_b) begin
                data_a_r <= i_data_a;
                data_b_r <= i_data_b;
            end
            else begin
                data_a_r <= i_data_b;
                data_b_r <= i_data_a;
            end
        end
    end

endmodule