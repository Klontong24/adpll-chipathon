`timescale 1ns/1ps

module bbpd_tb;

    // Stimulus and response signals
    reg tref;
    reg tdiv;
    reg rst_n;
    wire te;

    // DUT Instantiation
    bbpd bbpd0 (
        .tref(tref),
        .tdiv(tdiv),
        .rst_n(rst_n),
        .te(te)
    );

    initial begin
        // Initialize inputs
        tref  = 0;
        tdiv  = 0;
        rst_n = 0;
        
        // Waveform dump setup for GTKWave/ModelSim
        $dumpfile("bbpd_tb.vcd");
        $dumpvars(0, bbpd_tb);
        
        $display("=============================================================");
        $display("STARTING COMPREHENSIVE BBPD VERIFICATION FOR CHIPATHON 2026");
        $display("=============================================================");

        // Test Case 1: Asynchronous System Reset Release
        #10;
        rst_n = 1;
        #5;
        $display("[STATUS] System released from reset.");

        // Test Case 2: Tref leads Tdiv (Narrow Pulse, Width = 0.5 ns)
        $display("[TEST 1] Testing Narrow Pulse: Tref Leads Tdiv by 2.0 ns");
        repeat(5) begin
            tref = 1;       
            #0.5 tref = 0;  
            #1.5;           
            tdiv = 1;       
            #0.5 tdiv = 0;  
            #7.5;           // Remainder of the 10 ns period
        end
        $display("[RESULT 1] Observed Output te = %b (Expected: 1)", te);

        #20; 

        // Test Case 3: Tdiv leads Tref (Narrow Pulse, Width = 0.5 ns)
        $display("[TEST 2] Testing Narrow Pulse: Tdiv Leads Tref by 2.0 ns");
        repeat(5) begin
            tdiv = 1;       
            #0.5 tdiv = 0; 
            #1.5;           
            tref = 1;       
            #0.5 tref = 0;
            #7.5;           // Remainder of the 10 ns period
        end
        $display("[RESULT 2] Observed Output te = %b (Expected: 0)", te);

        #20;

        // Test Case 4: Extreme Edge Race (Tref leads Tdiv by only 50 ps)
        $display("[TEST 3] Critical Timing: Tref Leads Tdiv by only 50 ps (0.05 ns)");
        repeat(5) begin
            tref = 1;
            #0.05;          
            tdiv = 1;
            #0.5;           
            tref = 0;
            tdiv = 0;
            #9.45;          // Remainder of the 10 ns period
        end
        $display("[RESULT 3] Observed Output te = %b (Expected: 1)", te);

        #20;

        // Test Case 5: Extreme Edge Race (Tdiv leads Tref by only 50 ps)
        $display("[TEST 4] Critical Timing: Tdiv Leads Tref by only 50 ps (0.05 ns)");
        repeat(5) begin
            tdiv = 1;
            #0.05;
            tref = 1;
            #0.5;
            tdiv = 0;
            tref = 0;
            #9.45;          // Remainder of the 10 ns period
        end
        $display("[RESULT 4] Observed Output te = %b (Expected: 0)", te);

        // End of Simulation
        $display("=============================================================");
        $display("VERIFICATION COMPLETE");
        $display("=============================================================");
        #50;
        $finish;
    end

endmodule