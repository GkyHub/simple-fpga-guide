//=============================================================================
// File Name    : axis_register.v
// Created On   : 2020-07-01 10:00
// Last Modified: 2020-07-01 13:53
// Author       : Kaiyuan Guo
// Description  : A module to insert a register into an axi-stream pipeline.
//=============================================================================

module axis_register#(
    parameter   DATA_W  = 32
    )(
    input   clk,
    input   rst_n,

    input   [DATA_W -1 : 0] s_axis_tdata,
    input                   s_axis_tvalid,
    output                  s_axis_tready,

    output  [DATA_W -1 : 0] m_axis_tdata,
    output                  m_axis_tvalid,
    input                   m_axis_tready
    );

    reg     [DATA_W -1 : 0] m_axis_tdata_r;
    reg                     m_axis_tvalid_r;
    reg                     s_axis_tready_r;

    assign  s_axis_tready = s_axis_tready_r;
    assign  m_axis_tvalid = m_axis_tvalid_r;
    assign  m_axis_tdata  = m_axis_tdata_r;

    always @ (posedge clk) begin
        if (!rst_n) begin
            s_axis_tready_r <= 1'b1;
        end
        else if (s_axis_tvalid && s_axis_tready_r && !m_axis_tready) begin
            // if the register receive a data and output is not ready
            // then the register will not receive the next data
            s_axis_tready_r <= 1'b0;
        end
        else if (m_axis_tvalid_r && m_axis_tready) begin
            // if a transfer to output is done
            // then the register is ready to receive a new data
            s_axis_tready_r <= 1'b1;
        end
    end

    always @ (posedge clk) begin
        if (!rst_n) begin
            m_axis_tvalid_r <= 1'b0;
        end
        else if (s_axis_tvalid && s_axis_tready_r) begin
            // if a transfer from input is done
            // then the register is valid
            m_axis_tvalid_r <= 1'b1;
        end
        else if (m_axis_tvalid_r && m_axis_tready) begin
            // otherwise if a transfer to output is done
            // the register is not valid
            m_axis_tvalid_r <= 1'b0;
        end
    end

    // we do not reset tdata
    always @ (posedge clk) begin
        if (s_axis_tvalid && s_axis_tready_r) begin
            m_axis_tdata_r <= s_axis_tdata;
        end
    end

endmodule