`timescale 1ns/1ps

module tb_dlf_pi;

    // DUT Parameters
    parameter integer DCO_W = 10;
    parameter integer FRAC  = 8;

    // Testbench signals
    reg clk = 0;
    reg rst_n = 0;
    reg te_raw = 0;
    reg [3:0] kp = 0;
    reg [3:0] ki = 0;
    reg dither_en = 0;
    reg signed [5:0] dither = 0;
    
    wire [DCO_W-1:0] dco_code;
    wire te_sync;

    // Clock generator (50MHz reference clock)
    always #10 clk = ~clk;

    // DLF-PI Device Under Test (DUT) Instantiation
    dlf_pi #(
        .DCO_W(DCO_W),
        .FRAC(FRAC)
    ) dut (
        .clk_ref(clk),
        .rst_n(rst_n),
        .te_raw(te_raw),
        .kp(kp),
        .ki(ki),
        .dither_en(dither_en),
        .dither(dither),
        .dco_code(dco_code),
        .te_sync(te_sync)
    );

    initial begin
        // Setup VCD dump for waveform analysis
        $dumpfile("dlf_pi.vcd");
        $dumpvars(0, tb_dlf_pi);
        
        $display("=============================================================");
        $display("STARTING DLF-PI VERIFICATION (MBG32)");
        $display("=============================================================");

        // INITIAL CONDITION: Assert reset
        rst_n = 0;
        te_raw = 0;
        kp = 4'd2; // Moderate Proportional gain
        ki = 4'd4; // Moderate Integral gain
        dither_en = 0;
        dither = 6'd0;
        #100;

        // TEST 1: Reset behavior and initial proportional step check
        // Expected: 512 - 4 = 508 due to instantaneous negative proportional step (te_raw=0)
        $display("[TEST 1] Reset Release & Initial Proportional Step Check");
        rst_n = 1;
        #20;
        if (dco_code == 10'd508)
            $display("-> PASSED: Output correctly stepped to 508 due to BBPD behavior.");
        else
            $display("-> FAILED: Output is %0d (Expected: 508).", dco_code);

        // TEST 2: Positive Phase Error (te_raw = 1) Accumulation
        $display("[TEST 2] Positive Accumulation (te_raw = 1)");
        te_raw = 1;
        #1000;
        $display("-> Current DCO Code after short accumulation: %0d", dco_code);

        // TEST 3: Upper Saturation/Clamping Check
        // Extended delay to allow the slow integrator to reach ACC_MAX
        $display("[TEST 3] Forcing Upper Saturation (Code MAX)");
        kp = 4'd6; 
        ki = 4'd2; // Faster integral step to guarantee saturation
        te_raw = 1;
        #60000; // Increased delay to ensure full accumulator saturation
        if (dco_code == 10'd1023)
            $display("-> PASSED: DCO safely clamped at MAX (1023) without overflow.");
        else
            $display("-> FAILED: DCO code at saturation is %0d (Expected: 1023).", dco_code);

        // TEST 4: Negative Phase Error (te_raw = 0) Accumulation
        $display("[TEST 4] Negative Accumulation (te_raw = 0)");
        te_raw = 0;
        #5000;
        $display("-> Current DCO Code dropping from saturation: %0d", dco_code);

        // TEST 5: Lower Saturation/Clamping Check
        // Extended delay to allow full discharge down to ACC_MIN
        $display("[TEST 5] Forcing Lower Saturation (Code MIN)");
        te_raw = 0;
        #80000; // Increased delay to ensure full accumulator depletion
        if (dco_code == 10'd0)
            $display("-> PASSED: DCO safely clamped at MIN (0) without underflow.");
        else
            $display("-> FAILED: DCO code at saturation is %0d (Expected: 0).", dco_code);

        // TEST 6: Dither Injection test
        $display("[TEST 6] Dither Injection test");
        
        // Reset to center first
        rst_n = 0;
        #50;
        rst_n = 1;
        #50;
        
        dither_en = 1;
        dither = 6'd15; // Inject positive dither
        #50;
        $display("-> Code with +15 Dither injection: %0d", dco_code);
        
        dither = -6'sd10; // Inject negative dither
        #50;
        $display("-> Code with -10 Dither injection: %0d", dco_code);

        $display("=============================================================");
        $display("VERIFICATION COMPLETE");
        $display("=============================================================");
        $finish;
    end

endmodule

