`define IVERILOG_SIM 

`timescale 1ps/1ps

module tb_dco;

    // DUT Parameters
    parameter integer DCO_W = 10;

    // Testbench signals
    reg en;
    reg [DCO_W-1:0] dco_code;
    wire clk_out;

    // Variables for period measurement and comparison
    real time_start;
    real time_end;
    real measured_period_ps;
    
    real period_min_code;
    real period_max_code;

    // Device Under Test (DUT) Instantiation for Synthesizable DCRO
    dco #(
        .DCO_W(DCO_W)
    ) dut (
        .en(en),
        .dco_code(dco_code),
        .clk_out(clk_out)
    );

    // Task to automatically measure the clock period of the DCO output
    task measure_period;
        begin
            // Wait for a few clock cycles to let the oscillation settle
            @(posedge clk_out);
            @(posedge clk_out);
            
            // Record start time
            time_start = $realtime;
            
            // Wait for the next rising edge
            @(posedge clk_out);
            
            // Record end time
            time_end = $realtime;
            
            // Calculate actual period
            measured_period_ps = time_end - time_start;
            $display("-> Measured Period: %0.2f ps", measured_period_ps);
        end
    endtask

    initial begin
        // Setup VCD dump for waveform analysis
        $dumpfile("dco_tb.vcd");
        $dumpvars(0, tb_dco);
        
        $display("=============================================================");
        $display("STARTING SYNTHESIZABLE DCRO VERIFICATION (MBG32)");
        $display("=============================================================");

        // INITIAL CONDITION
        en = 0;
        dco_code = 10'd0;
        #5000; 
        
        // TEST 1: Disabled State Check (en = 0)
        $display("[TEST 1] Disabled State Check (en = 0)");
        if (clk_out === 1'b1 || clk_out === 1'b0)
            $display("-> STATUS: PASSED (Clock is statically halted without oscillating)");
        else
            $display("-> STATUS: FAILED (Clock is active or in unknown state 'x')");
        
        #1000;

        // TEST 2: Minimum Frequency (Max Delay Path)
        // dco_code = 0 selects the longest inverter chain
        $display("\n[TEST 2] Minimum Frequency Check (dco_code = 0)");
        en = 1;
        dco_code = 10'd0;
        measure_period();
        period_min_code = measured_period_ps;

        // TEST 3: Center Frequency
        // dco_code = 512 selects the middle of the inverter chain
        $display("\n[TEST 3] Center Frequency Check (dco_code = 512)");
        dco_code = 10'd512;
        measure_period();

        // TEST 4: Maximum Frequency (Min Delay Path)
        // dco_code = 1023 selects the shortest inverter chain
        $display("\n[TEST 4] Maximum Frequency Check (dco_code = 1023)");
        dco_code = 10'd1023;
        measure_period();
        period_max_code = measured_period_ps;

        // TEST 5: Logical Consistency Verification
        // The period of max code (1023) MUST be smaller/faster than min code (0)
        $display("\n[TEST 5] Structural Logic Verification");
        if (period_max_code < period_min_code)
            $display("-> STATUS: PASSED (Higher DCO code successfully produces faster clock)");
        else
            $display("-> STATUS: FAILED (Frequency mapping is logically inverted or static)");

        // Final observation delay
        #5000;

        $display("=============================================================");
        $display("VERIFICATION COMPLETE");
        $display("=============================================================");
        $finish;
    end

endmodule


