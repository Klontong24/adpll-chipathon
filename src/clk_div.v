// CHIPATHON 2026
//! @title Programmable Feedback Clock Divider
//! @author Muhammad Shofuwan Anwar, Ferhad Zulfas, Hardian Tri Pamungkas, Maulidan Imtinan Ahmada
//! @brief Counter-based programmable frequency divider for the ADPLL feedback loop.

module clk_divider #(
    parameter integer DIV_W = 8 // Width of the divider control word
)(
    input  wire               clk_in,       // High-frequency input clock (from DCO)
    input  wire               rst_n,        // Asynchronous active-low reset
    input  wire [DIV_W-1:0]   div_ratio,    // Division factor (N)
    
    output reg                clk_out       // Divided output clock (tdiv)
);

    // Internal counter register
    reg [DIV_W-1:0] counter;

    // Calculate the threshold for toggling the clock to maintain a ~50% duty cycle
    wire [DIV_W-1:0] toggle_threshold = (div_ratio >> 1);

    always @(posedge clk_in or negedge rst_n) begin : counter_logic
        if (~rst_n) begin
            counter <= {DIV_W{1'b0}};
            clk_out <= 1'b0;
        end else begin
            // Safety mechanism: Avoid toggling if division factor is invalid (N < 2)
            if (div_ratio < 2) begin
                counter <= {DIV_W{1'b0}};
                clk_out <= 1'b0;
            end 
            // Toggle the output clock and reset counter when threshold is reached
            else if (counter >= (toggle_threshold - 1)) begin
                counter <= {DIV_W{1'b0}};
                clk_out <= ~clk_out;
            end 
            // Otherwise, increment the counter
            else begin
                counter <= counter + 1'b1;
            end
        end
    end

endmodule


