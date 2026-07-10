`timescale 1ns/1ps

module tb_lfsr_dither;

    // Main testbench signals
    reg clk = 0;
    reg rst_n = 0;
    reg en = 1;
    reg [2:0] amp = 3'd0;
    wire signed [5:0] dither;

    // Monitor variables for self-checking verification
    integer max_val, min_val;
    reg signed [5:0] frozen_val;

    // Clock generator (40ns period / 25MHz)
    always #20 clk = ~clk;

    // LFSR Dither Device Under Test (DUT) Instantiation
    lfsr_dither #(
        .OUT_W(6), 
        .STEP_N(7)
    ) dut (
        .clk_ref(clk), 
        .rst_n(rst_n), 
        .en(en),
        .cfg_amp_shift(amp), 
        .dither(dither)
    );

    // Monitor block to track maximum and minimum amplitude boundaries
    always @(posedge clk) begin
        if (rst_n && en) begin
            if (dither > max_val) max_val = dither;
            if (dither < min_val) min_val = dither;
        end
    end

    // Task to reset the min/max monitor for the next test scenario
    task reset_monitor;
        begin
            max_val = -999;
            min_val =  999;
        end
    endtask

    initial begin
        // Setup VCD dump for waveform analysis (GTKWave/ModelSim)
        $dumpfile("lfsr_dither_tb.vcd");
        $dumpvars(0, tb_lfsr_dither);
        
        $display("=============================================================");
        $display("STARTING LFSR DITHER VERIFICATION (MBG32)");
        $display("=============================================================");

        // INITIAL CONDITION: Assert reset
        rst_n = 0;
        en = 1;
        amp = 3'd0;
        reset_monitor();
        #100;

        // TEST 1: Full Amplitude (amp = 0)
        $display("[TEST 1] Full Amplitude Mode (amp = 0)");
        rst_n = 1; // Release reset
        #4000;
        $display("-> Observed Range: Min = %0d, Max = %0d", min_val, max_val);

        // TEST 2: Attenuated Mode (amp = 1)
        // Expected behavior: The amplitude range should be halved
        $display("[TEST 2] Attenuated Mode (amp = 1)");
        reset_monitor();
        amp = 3'd1;
        #4000;
        $display("-> Observed Range: Min = %0d, Max = %0d", min_val, max_val);

        // TEST 3: Attenuated Mode (amp = 2)
        // Expected behavior: The amplitude range should be quartered
        $display("[TEST 3] Attenuated Mode (amp = 2)");
        reset_monitor();
        amp = 3'd2;
        #4000;
        $display("-> Observed Range: Min = %0d, Max = %0d", min_val, max_val);

        // TEST 4: Freeze Feature Verification (en = 0)
        $display("[TEST 4] Freeze Feature (en = 0)");
        en = 0;
        frozen_val = dither; // Capture the current state
        #1000;
        if (dither == frozen_val)
            $display("-> PASSED: Output is successfully frozen at %0d", dither);
        else
            $display("-> FAILED: Output changed during freeze!");

        // TEST 5: Unfreeze Feature (en = 1)
        $display("[TEST 5] Unfreeze Feature (en = 1)");
        en = 1;
        #1000;

        $display("=============================================================");
        $display("VERIFICATION COMPLETE");
        $display("=============================================================");
        $finish;
    end

endmodule

