// Add this macro to prevent Zero-Delay Loop in DCO when simulated in Icarus Verilog
`define IVERILOG_SIM 
`timescale 1ps/1ps

module tb_adpll_top;

    // Parameters
    parameter integer DCO_W = 10;
    parameter integer DIV_W = 8;
    
    // Testbench Signals
    reg               clk_ref;
    reg               rst_n;
    reg               en;
    reg  [DIV_W-1:0]  div_ratio;
    reg  [15:0]       kp;
    reg  [15:0]       ki;
    wire              clk_out;

    // Measurement Variables
    real time_start;
    real time_end;
    real measured_period_ps;
    real current_freq_mhz;
    
    // Reference Clock Period (25 MHz = 40,000 ps)
    real ref_period_ps = 40000.0;

    // DUT Instantiation
    adpll_top #(
        .DCO_W(DCO_W),
        .DIV_W(DIV_W)
    ) dut (
        .clk_ref(clk_ref),
        .rst_n(rst_n),
        .en(en),
        .div_ratio(div_ratio),
        .kp(kp),
        .ki(ki),
        .clk_out(clk_out)
    );

    // Generate 25 MHz Reference Clock
    initial begin
        clk_ref = 0;
        forever #(ref_period_ps / 2.0) clk_ref = ~clk_ref;
    end

    // =========================================================================
    // X-STATE WATCHDOG: Detects if loop variables become undefined
    // =========================================================================
    always @(dut.dco_code) begin
        if (rst_n === 1'b1 && en === 1'b1 && dut.dco_code === {DCO_W{1'bx}}) begin
            $display("\n=============================================================");
            $display("[WATCHDOG ERROR] dco_code became 'X' at time %0t ps!", $realtime);
            $display("The DCO has stopped oscillating because it received an unknown tuning word.");
            $display("Check your DLF_PI, BBPD, or LFSR_DITHER for uninitialized registers.");
            $display("=============================================================\n");
            #10;
            $finish;
        end
    end

    // Task: Measure Output Frequency
    task measure_output_freq;
        begin
            // Wait for rising edge
            @(posedge clk_out);
            time_start = $realtime;
            @(posedge clk_out);
            time_end = $realtime;
            
            if (time_end > time_start) begin
                measured_period_ps = time_end - time_start;
                current_freq_mhz = 1000000.0 / measured_period_ps;
            end else begin
                current_freq_mhz = 0.0;
            end
        end
    endtask

    // Task: Wait for ADPLL to Lock
    task wait_for_lock;
        input integer timeout_cycles;
        input real target_mhz;
        input real tolerance_mhz;
        integer i;
        reg locked;
        begin
            locked = 0;
            $display("-> Target Frequency: %0.2f MHz (Tolerance: +/- %0.2f MHz)", target_mhz, tolerance_mhz);
            $display("-> Waiting for loop to lock...");
            
            for (i = 0; i < timeout_cycles; i = i + 1) begin
                @(posedge clk_ref);
                measure_output_freq();
                
                // Print progress every 10 reference cycles
                if (i % 10 == 0) begin
                    $display("   [Cycle %0d] Current Freq: %0.2f MHz (dco_code: %0d)", i, current_freq_mhz, dut.dco_code);
                end
                
                // Check if within tolerance
                if ((current_freq_mhz >= (target_mhz - tolerance_mhz)) && 
                    (current_freq_mhz <= (target_mhz + tolerance_mhz))) begin
                    
                    // Wait a few more cycles to ensure it's not a fluke
                    @(posedge clk_ref);
                    measure_output_freq();
                    if ((current_freq_mhz >= (target_mhz - tolerance_mhz)) && 
                        (current_freq_mhz <= (target_mhz + tolerance_mhz))) begin
                        locked = 1;
                        $display("-> STATUS: LOCKED at %0.2f MHz (after %0d ref cycles)\n", current_freq_mhz, i);
                        i = timeout_cycles; // Exit loop
                    end
                end
            end
            
            if (!locked) begin
                $display("-> STATUS: FAILED TO LOCK (Timeout reached). Final Freq: %0.2f MHz\n", current_freq_mhz);
            end
        end
    endtask

    initial begin
        $dumpfile("adpll_top_tb.vcd");
        
        // Note: If simulation is VERY slow, change the '0' below to '1' 
        // to prevent dumping the massive 1024-stage ring oscillator nodes.
        $dumpvars(0, tb_adpll_top);
        
        $display("=============================================================");
        $display("STARTING ADPLL SYSTEM-LEVEL VERIFICATION (MBG32)");
        $display("=============================================================");

        // INITIAL CONDITION
        rst_n = 0;
        en = 0;
        div_ratio = 8'd10;  // 25 MHz * 10 = 250 MHz
        kp = 16'd5; 
        ki = 16'd1; 
        
        #100000; // Hold reset for some time
        
        // TEST 1: Startup & Acquisition (Target 250 MHz)
        $display("[TEST 1] Startup & Frequency Acquisition");
        rst_n = 1;
        en = 1;
        
        wait_for_lock(1500, 250.0, 15.0); 

        $display("[TEST 2] Lock Stability Monitoring (Holding for 500 cycles)...");
        repeat(500) @(posedge clk_ref);
        measure_output_freq();
        $display("-> Frequency after hold: %0.2f MHz\n", current_freq_mhz);

        $display("[TEST 3] Dynamic Frequency Hopping (div_ratio changed to 12)");
        div_ratio = 8'd12; // 25 MHz * 12 = 300 MHz
        wait_for_lock(1500, 300.0, 15.0);
        
        $display("[TEST 4] System Reset Mid-Operation");
        rst_n = 0; // Assert reset
        #50000;
        if (dut.u_clk_divider.clk_out === 1'b0)
            $display("-> STATUS: PASSED (System correctly halted on reset)\n");
        else
            $display("-> STATUS: FAILED (System still running during reset)\n");

        $display("=============================================================");
        $display("SYSTEM VERIFICATION COMPLETE");
        $display("=============================================================");
        $finish;
    end

endmodule



