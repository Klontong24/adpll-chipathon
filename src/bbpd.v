// CHIPATHON 2026
//! @title Bang-Bang Phase Detector
//! @author Muhammad Shofuwan Anwar, Ferhad Zulfas, Hardian Tri Pamungkas, Maulidan Imtinan Ahmada

module bbpd(
    input wire tref, //! reference clock
    input wire tdiv, //! clock from clk_div generated from DCO
    input wire rst_n, //! FF reset

    output reg te //! signal output e[k]
);

    reg q_ref, q_div; //! FF output from captured signal
    wire ff_rst; //! combinational reset

    //! This DFF is used to capture the reference signal
    always @(posedge tref or negedge ff_rst) begin: dff_up
        if (~ff_rst)
            q_ref <= 1'b0;
        else
            q_ref <= 1'b1;
    end

    //! This DFF is used to capture the division signal (signal from clk_div)
    always @(posedge tdiv or negedge ff_rst) begin: dff_down
        if (~ff_rst)
            q_div <= 1'b0;
        else
            q_div <= 1'b1;
    end

    //! This DFF act as "priority encoder", which one is more faster, tref or tdiv
    always @(posedge q_div or negedge rst_n) begin: priority_encoder
        if (~rst_n)
            te <= 1'b0;
        else
            te <= q_ref;
    end

    assign ff_rst = ~(~(tref & tdiv) | rst_n); //! NAND and NOR to combine the reset signal

endmodule


