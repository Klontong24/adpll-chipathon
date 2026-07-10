`timescale 1ns/1ps

module tb_clk_divider;

    // DUT Parameters
    parameter integer DIV_W = 8;

    // Testbench signals
    reg clk_in;
    reg rst_n;
    reg [DIV_W-1:0] div_ratio;
    wire clk_out;

    // Variables for period measurement
    real time_start;
    real time_end;
    real measured_period_ns;
    real expected_period_ns;
    real clk_in_period = 2.0; // 500 MHz input clock

    // Device Under Test (DUT) Instantiation
    clk_divider #(
        .DIV_W(DIV_W)
    ) dut (
        .clk_in(clk_in),
        .rst_n(rst_n),
        .div_ratio(div_ratio),
        .clk_out(clk_out)
    );

    // High-frequency clock generation (500 MHz)
    initial begin
        clk_in = 0;
        forever #(clk_in_period / 2.0) clk_in = ~clk_in;
    end

    // Task to measure output clock period automatically
    task measure_period;
        input real expected_ratio;
        begin
            expected_period_ns = expected_ratio * clk_in_period;
            
            // Wait for a few clock cycles to stabilize
            @(posedge clk_out);
            @(posedge clk_out);
            
            // Record start time
            time_start = $realtime;
            
            // Wait for next rising edge
            @(posedge clk_out);
            
            // Record end time
            time_end = $realtime;
            
            // Calculate actual period
            measured_period_ns = time_end - time_start;
            
            $display("-> Expected Period: %0.2f ns (Ratio: %0.0f)", expected_period_ns, expected_ratio);
            $display("-> Measured Period: %0.2f ns", measured_period_ns);
            
            // Tolerance check
            if ((measured_period_ns >= expected_period_ns - 0.1) && (measured_period_ns <= expected_period_ns + 0.1))
                $display("-> STATUS: PASSED\n");
            else
                $display("-> STATUS: WARNING/FAILED (Odd division may truncate)\n");
        end
    endtask

    initial begin
        // Setup VCD dump for GTKWave
        $dumpfile("clk_div_tb.vcd");
        $dumpvars(0, tb_clk_divider);
        
        $display("=============================================================");
        $display("STARTING PROGRAMMABLE CLK_DIVIDER VERIFICATION (MBG32)");
        $display("=============================================================");

        // INITIAL CONDITION (RESET)
        rst_n = 0;
        div_ratio = 8'd4;
        #10;
        rst_n = 1;
        
        // TEST 1: Safety Check for Invalid Division (N = 0)
        $display("[TEST 1] Safety Check (div_ratio = 0)");
        div_ratio = 8'd0;
        #20;
        if (clk_out === 1'b0)
            $display("-> STATUS: PASSED (Clock is safely halted for N=0)\n");
        else
            $display("-> STATUS: FAILED (Clock is toggling for N=0)\n");

        // TEST 2: Safety Check for Invalid Division (N = 1)
        $display("[TEST 2] Safety Check (div_ratio = 1)");
        div_ratio = 8'd1;
        #20;
        if (clk_out === 1'b0)
            $display("-> STATUS: PASSED (Clock is safely halted for N=1)\n");
        else
            $display("-> STATUS: FAILED (Clock is toggling for N=1)\n");

        // TEST 3: Even Division (N = 4)
        $display("[TEST 3] Even Division (div_ratio = 4)");
        div_ratio = 8'd4;
        measure_period(4.0);

        // TEST 4: Even Division (N = 10)
        $display("[TEST 4] Even Division (div_ratio = 10)");
        div_ratio = 8'd10;
        measure_period(10.0);

        // TEST 5: Odd Division (N = 5)
        // Note: Simple integer dividers using `>> 1` round down odd numbers.
        // N=5 will effectively behave like N=4 in a simple 50% duty cycle toggle logic.
        $display("[TEST 5] Odd Division Behavior (div_ratio = 5)");
        div_ratio = 8'd5;
        measure_period(4.0); // Expecting 4.0 due to integer truncation

        // TEST 6: Asynchronous Reset During Operation
        $display("[TEST 6] Asynchronous Reset Mid-Operation");
        div_ratio = 8'd4;
        #7; // Wait random time mid-cycle
        rst_n = 0; // Trigger reset
        #5;
        if (clk_out === 1'b0)
            $display("-> STATUS: PASSED (Reset forces output to 0 immediately)\n");
        else
            $display("-> STATUS: FAILED (Output did not reset)\n");
        rst_n = 1;

        #50;
        $display("=============================================================");
        $display("VERIFICATION COMPLETE");
        $display("=============================================================");
        $finish;
    end

endmodule


