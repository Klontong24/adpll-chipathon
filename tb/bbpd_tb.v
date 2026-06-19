`define DCO_UP      1

module bbpd_tb;
    reg tref = 0;
    reg tdiv = 0;
    reg rst_n = 0;
    wire te;

    bbpd bbpd0(.tref(tref), .tdiv(tdiv), .rst_n(rst_n), .te(te));

`ifdef DCO_UP
    always #5 tref = ~tref;
`else
    always #5 tdiv = ~tdiv;
`endif

    initial begin
        #1;

`ifdef DCO_UP
        forever #5 tdiv = ~tdiv;
`else
        forever #5 tref = ~tref;
`endif
    end

    initial begin
        $dumpfile("bbpd_tb.vcd");
        $dumpvars(0, bbpd_tb);

        #3 rst_n <= 1;

        #100;
        $finish;
    end
endmodule



