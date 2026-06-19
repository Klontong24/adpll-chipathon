module bbpd_tb;
    reg tref = 0;
    reg tdiv = 0;
    reg rst_n = 1;
    wire te;

    bbpd bbpd0(.tref(tref), .tdiv(tdiv), .rst_n(rst_n), .te(te));

    integer x;
    initial begin
        $dumpfile("bbpd_tb.vcd");
        $dumpvars(0, bbpd_tb);
        
        #10 rst_n <= 0;
        #10 rst_n <= 1;

        for (x=0; x<5; x=x+1) begin
            #10 tref <= ~tref;
            #11 tdiv <= ~tref;
        end

        for (x=0; x<5; x=x+1) begin
            #11 tref <= ~tref;
            #10 tdiv <= ~tref;
        end
    end
endmodule



