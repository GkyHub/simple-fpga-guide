interface axis#(
    parameter DATA_W = 8,
    parameter USER_W = 4,
    parameter DEST_W = 4
    );
    // simple subset
    logic   [DATA_W -1 : 0] data;
    logic                   valid;
    logic                   ready;
    // full version
    logic   [(DATA_W + 1) / 8 -1 : 0] tkeep;
    logic

endinterface //axis