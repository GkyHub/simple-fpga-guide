//=============================================================================
// File Name    : axis_register.v
// Created On   : 2020-07-01 10:00
// Last Modified: 2020-07-01 13:53
// Author       : Kaiyuan Guo
// Description  : A module to split 1 axi-stream to 4 slaves according to tid.
//=============================================================================

module axis_split4 #(
    parameter   DATA_W  = 32
    )(
    input   clk,
    input   rst_n,

    input   [DATA_W -1 : 0] s_axis_tdata,
    input   [2      -1 : 0] s_axis_tid,
    input                   s_axis_tvalid,
    output                  s_axis_tready,

    output  [DATA_W*4   -1 : 0] m_axis_tdata,
    output  [4          -1 : 0] m_axis_tvalid,
    input   [4          -1 : 0] m_axis_tready
    );

    //----------stream split logic-----------//
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin: LANE
            reg     [DATA_W -1 : 0] m_axis_tdata_r;
            reg                     m_axis_tvalid_r;
            assign  m_axis_tdata[DATA_W * (i + 1) -1 : DATA_W * i] = m_axis_tdata_r;
            assign  m_axis_tvalid[i] = m_axis_tvalid_r;

            always @ (posedge clk) begin
                if (~rst_n) begin
                    m_axis_tdata_r <= 0;
                    m_axis_tvalid_r <= 1'b0;
                end
                else if (m_axis_tready[i]) begin
                    if (s_axis_tid == i && s_axis_tvalid) begin
                        m_axis_tdata_r  <= s_axis_tdata;
                        m_axis_tvalid_r <= 1'b1;
                    end
                    else begin
                        m_axis_tdata_r  <= 0;
                        m_axis_tvalid_r <= 1'b0;
                    end
                end
            end
        end
    endgenerate

    assign s_axis_tready = m_axis_tready[s_axis_tid];

endmodule