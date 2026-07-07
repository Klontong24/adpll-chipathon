// CHIPATHON 2026
//! @title Gear-Shifting Digital Loop Filter (DLF)
//! @author Muhammad Shofuwan Anwar, Ferhad Zulfas, Hardian Tri Pamungkas, Maulidan Imtinan Ahmada
//! @brief Proportional-Integral (PI) loop filter featuring an adaptive gear-shifting mechanism for fast frequency acquisition and optimal jitter reduction.

module gshift_dlf(
    input wire te,          //! e[k] direction reference from BB-PD (1: speed up, 0: slow down)
    input wire clk,         //! Main system clock
    input wire rst_n,       //! Asynchronous active-low reset

    output reg [15:0] tune  //! 16-bit tuning word output to the Digitally Controlled Oscillator (DCO)
);

    reg [4:0] lock_count;           //! 5-bit saturating counter to track consecutive direction changes (0 to 16)
    reg te_prev;                    //! Register to store the previous state of the phase error (te)
    wire dirchg = (te != te_prev);  //! High if the BB-PD changes direction, indicating phase oscillation around the target

    //! This block utilizes a Leaky Bucket algorithm to monitor BB-PD phase oscillations
    always @(posedge clk or negedge rst_n) begin : leaky_bucket_lock_detector
        if (~rst_n) begin
            te_prev <= 1'b0;
            lock_count <= 5'd0;
        end else begin
            te_prev <= te;

            if (dirchg) begin
                if (lock_count < 5'd16)
                    lock_count <= lock_count + 5'd1;
            end else begin
                if (lock_count > 5'd0)
                    lock_count <= lock_count - 5'd1; 
            end
        end
    end

    wire locked = (lock_count == 5'd16); //! Asserts high when the PLL achieves a steady locked state

    reg [3:0] kp_shift; //! Arithmetic right/left shift value representing the Proportional gain
    reg [3:0] ki_shift; //! Arithmetic right/left shift value representing the Integral gain

    //! Dynamically adjusts the PI gains based on the PLL lock status
    always @(posedge clk or negedge rst_n) begin : gear_shifting_fsm
        if (~rst_n) begin
            kp_shift <= 4'd0;
            ki_shift <= 4'd0;
        end else begin
            if (!locked) begin
                kp_shift <= 4'd4;
                ki_shift <= 4'd2;
            end else begin
                kp_shift <= 4'd2;
                ki_shift <= 4'd0;
            end
        end
    end

    wire signed [1:0] te_signed = (te == 1'b1) ? 2'sd1 : -2'sd1;  //! Convert the 1-bit binary error signal (0 or 1) into a 2-bit signed integer (-1 or +1)
    
    wire signed [15:0] proportional_net = te_signed <<< kp_shift; //! Apply Proportional gain using arithmetic bit-shifting for hardware efficiency
    wire signed [15:0] integral_net = te_signed <<< ki_shift;     //! Apply Integral gain using arithmetic bit-shifting for hardware efficiency

    reg signed [15:0] integral_reg; //! 16-bit accumulator register for the Integral path

    //! Integral accumulator block executing the core arithmetic integration
    always @(posedge clk or negedge rst_n) begin : integral_accumulator
        if (~rst_n)
            integral_reg <= 16'sd0;
        else
            integral_reg <= integral_reg + integral_net; 
    end

    //! Tuning word synthesis by summing Proportional and Integral paths
    always @(posedge clk or negedge rst_n) begin : tuning_word_synthesis
        if (~rst_n)
            tune <= 16'd0;
        else
            tune <= proportional_net + integral_reg;
    end

endmodule


