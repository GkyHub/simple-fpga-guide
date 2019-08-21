//=============================================================================
// File Name    : adder_tree.v
// Created On   : 2019-08-21 12:53
// Last Modified: 2019-08-21 13:56
// Author       : Kaiyuan Guo
// Description  : A parameterized adder tree design, with axi stream interface
//                to support pipeline stall.
//=============================================================================

module adder_tree #(
    parameter DATA_I_W      = 8,
    parameter DATA_NUM      = 16,
    parameter C_DATA_O_W    = DATA_I_W + $clog2(DATA_NUM)
    )(
    input   clk,
    input   rst_n,

    // 输入数据，axi_stream slave接口
    input   [DATA_I_W * DATA_NUM    -1 : 0] s_axis_din_data,
    input                                   s_axis_din_valid,
    output                                  s_axis_din_ready,

    // 输出数据，axi_stream master接口
    output  [C_DATA_O_W             -1 : 0] m_axis_dout_data,
    output                                  m_axis_dout_valid,
    input                                   m_axis_dout_ready
    );

    localparam PIPE_NUM = C_DATA_O_W - DATA_I_W;

    //----------------- control logic -------------------//
    reg     [PIPE_NUM  -1 : 0] valid_r;
    wire    has_workload = (|valid_r[PIPE_NUM -2 : 0]) || s_axis_din_valid;
    wire    stall = m_axis_dout_valid && !m_axis_dout_ready;

    always @ (posedge clk) begin
        if (~rst_n) begin
            valid_r <= {PIPE_NUM{1'b0}};
        end
        else if (!stall && has_workload) begin
            valid_r <= {valid_r[PIPE_NUM -2 : 0], s_axis_din_valid};
        end
    end

    assign  s_axis_din_ready = !stall;
    assign  m_axis_dout_valid = valid_r[PIPE_NUM - 1];

    //-------------------- datapath ---------------------//
    // we represent the internal results and input with a binary heap
    // so A[i] = A[2 * i] + A[2 * i + 1]
    wire    [C_DATA_O_W * (DATA_NUM) - 1 * 2    -1 : 0] internal_res;

    genvar i;
    generate
        for (i = 0; i < DATA_NUM - 1; i = i + 1) begin: ADDER_ARRAY
            reg     [C_DATA_O_W -1 : 0] sum_r;
            wire    [C_DATA_O_W -1 : 0] op1, op2;

            // connect input and output
            assign  internal_res[C_DATA_O_W * (i + 1) -1 -: C_DATA_O_W] = sum_r;
            assign  op1 = internal_res[C_DATA_O_W * (i * 2 + 2) -1 -: C_DATA_O_W];
            assign  op2 = internal_res[C_DATA_O_W * (i * 2 + 3) -1 -: C_DATA_O_W];

            always @ (posedge clk) begin
                if (!stall && has_workload) begin
                    sum_r <= op1 + op2;
                end
            end
        end: ADDER_ARRAY

        for (i = 0; i < DATA_NUM; i = i + 1) begin: INPUT_ARRAY
            wire    sign;
            assign  sign = s_axis_din_data[(i + 1) * DATA_I_W - 1];
            assign  internal_res[C_DATA_O_W * (DATA_NUM + i) -1 : 0] = {
                {(C_DATA_O_W - DATA_I_W){sign}},    // sign extension
                s_axis_din_data[(i + 1) * DATA_I_W - 1 -: DATA_I_W]
            };
        end: INPUT_ARRAY
    endgenerate

    assign  m_axis_dout_data = internal_res[C_DATA_O_W  -1 : 0];

endmodule