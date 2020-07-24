module axis_line_buffer#(
    parameter DATA_W    = 8,
    parameter MAX_WIDTH = 131,
    parameter WIN_H     = 3,
    parameter WIN_W     = 3
    )(
    input   clk,
    input   rst_n,

    input                   config_pulse,
    input   [16     -1 : 0] config_width,
    input   [16     -1 : 0] config_height,
    output                  done,

    input   [DATA_W -1 : 0] s_axis_pix_tdata,
    input                   s_axis_pix_tvalid,
    output                  s_axis_pix_tready,

    output  [WIN_H * WIN_W * DATA_W -1 : 0]
                            m_axis_win_tdata,
    output                  m_axis_win_tvalid,
    input                   m_axis_win_tready
    );

    wire    pipeline_enable;
    assign  pipeline_enable = s_axis_pix_tvalid && s_axis_pix_tready;

    //---------------- configuration ----------------//
    reg     [16 -1 : 0] img_width_r;    // image width -1
    reg     [16 -1 : 0] img_height_r;   // image height -1

    always @ (posedge clk) begin
        if (!rst_n) begin
            img_width_r     <= 0;
            img_height_r    <= 0;
        end
        else if (done && config_pulse) begin
            img_width_r     <= config_width - 1;
            img_height_r    <= config_height - 1;
        end
    end

    //-------------- status & counter ---------------//
    reg     [16 -1 : 0] w_cnt_r;
    reg     [16 -1 : 0] h_cnt_r;

    always @ (posedge clk) begin
        if (!rst_n) begin
            w_cnt_r <= 0;
            h_cnt_r <= 0;
        end
        else if (done && config_pulse) begin
            w_cnt_r <= 0;
            h_cnt_r <= 0;
        end
        else if (pipeline_enable) begin
            if (w_cnt_r == img_width_r) begin
                h_cnt_r <= (h_cnt_r == img_height_r) ? 0 : h_cnt_r + 1;
                w_cnt_r <= 0;
            end
            else begin
                h_cnt_r <= h_cnt_r;
                w_cnt_r <= w_cnt_r + 1;
            end
        end
    end

    reg     done_r;
    assign  done = done_r;

    always @ (posedge clk) begin
        if (!rst_n) begin
            done_r <= 1'b1;
        end
        else if (config_pulse && done) begin
            done_r <= 1'b0;
        end
        else if (pipeline_enable && (w_cnt_r == img_width_r) &&
            (h_cnt_r == img_height_r)) begin
            done_r <= 1'b1;
        end
    end

    //------------------ data path ------------------//
    genvar iw, ih;
    generate
        for (ih = 0; ih < WIN_H; ih = ih + 1) begin: GEN_ROW
            wire    [DATA_W -1 : 0] row_in;
            wire    [DATA_W -1 : 0] row_out;
            reg     [(WIN_W - 1) * DATA_W   -1 : 0] row_data_r;

            // get input for each row from the previous row or input data
            assign  row_in = (ih > 0) ? GEN_ROW[ih - 1].row_out : s_axis_pix_tdata;

            // window registers
            if (WIN_W == 2) begin: W2
                always @ (posedge clk) begin
                    if (pipeline_enable) begin
                        row_data_r <= row_in;
                    end
                end
            end
            else begin: WW
                always @ (posedge clk) begin
                    if (pipeline_enable) begin
                        row_data_r <= {row_in, row_data_r[(WIN_W - 1) * DATA_W -1 : DATA_W]};
                    end
                end
            end

            // buffer a line except for the last row of window
            if (ih < WIN_H - 1) begin: TOP_ROW
                cycle_buffer #(
                    .DEPTH          (MAX_WIDTH - WIN_W      ),
                    .DATA_W         (DATA_W                 )
                ) buffer_inst (
                    .clk            (clk                    ),
                    .rst_n          (rst_n                  ),
                    .config_pulse   (config_pulse && done   ),
                    .config_step    (config_width - WIN_W -1),
                    .data_i         (row_data_r[DATA_W-1 :0]),
                    .enable         (pipeline_enable        ),
                    .data_o         (row_out                )
                );
            end

            // set output data
            wire    [WIN_W * DATA_W -1 : 0] m_axis_row_tdata;
            assign  m_axis_row_tdata[DATA_W * WIN_W - 1 -: WIN_W] = row_in;
            assign  m_axis_row_tdata[DATA_W * (WIN_W - 1) -1 : 0] = row_data_r;
            assign  m_axis_win_tdata[(WIN_H - ih - 1) * (WIN_W * DATA_W) -1 
                -: (WIN_W * DATA_W)] = m_axis_row_tdata;
        end
    endgenerate

    //---------------- valid and ready control ----------------//
    reg     win_valid_r;
    always @ (posedge clk) begin
        if (!rst_n) begin
            win_valid_r <= 1'b0;
        end
        else if (pipeline_enable) begin
            if ((w_cnt_r == WIN_W - 2) && (h_cnt_r > WIN_H - 2)) begin
                win_valid_r <= 1'b1;
            end
            else if (w_cnt_r == img_width_r) begin
                win_valid_r <= 1'b0;
            end
        end
    end

    assign  m_axis_win_tvalid = win_valid_r && s_axis_pix_tvalid;
    assign  s_axis_pix_tready = m_axis_win_tready || !win_valid_r;

endmodule

module cycle_buffer #(
    parameter   DEPTH   = 128,
    parameter   DATA_W  = 8
    )(
    input   clk,
    input   rst_n,

    input                   config_pulse,
    input   [16     -1 : 0] config_step,

    input   [DATA_W -1 : 0] data_i,
    input                   enable,
    output  [DATA_W -1 : 0] data_o
    );

    reg     [16 -1 : 0] wr_addr_r;
    reg     [16 -1 : 0] rd_addr_r;

    always @ (posedge clk) begin
        if (!rst_n) begin
            wr_addr_r <= 0;
            rd_addr_r <= 0;
        end
        else if (config_pulse) begin
            wr_addr_r <= config_step;
            rd_addr_r <= 0;
        end
        else if (enable) begin
            // move the read and write pointer when a valid data comes
            wr_addr_r <= (wr_addr_r == DEPTH - 1) ? 0 : wr_addr_r + 1;
            rd_addr_r <= (rd_addr_r == DEPTH - 1) ? 0 : rd_addr_r + 1;
        end
    end

    // read and write buffer logic
    reg     [DATA_W -1 : 0] buffer[0:DEPTH-1];
    reg     [DATA_W -1 : 0] data_o_r;
    assign  data_o = data_o_r;

    always @ (posedge clk) begin
        if (enable) begin
            data_o_r <= buffer[rd_addr_r];
        end
    end

    always @ (posedge clk) begin
        if (enable) begin
            buffer[wr_addr_r] <= data_i;
        end
    end

endmodule