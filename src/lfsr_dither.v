// CHIPATHON 2026
//! @title LFSR Generator for Dithering
//! @author Muhammad Shofuwan Anwar, Ferhad Zulfas, Hardian Tri Pamungkas, Maulidan Imtinan Ahmada

module lfsr_dither #(
    parameter integer OUT_W  = 6,         //! Output width
    parameter integer STEP_N = 7         //! Steps per clock
)(
    input  wire                     clk_ref,        //! Reference clock
    input  wire                     rst_n,          //! Async reset
    input  wire                     en,             //! Enable/freeze
    input  wire [2:0]               cfg_amp_shift,  //! Amplitude control
    output wire signed [OUT_W-1:0]  dither          //! Dither output
);

    localparam [15:0] SEED = 16'hACE1;   //! Initial state

    //! One LFSR step
    function [15:0] lfsr_step(input [15:0] s);
        lfsr_step = {s[14:0], s[15] ^ s[14] ^ s[12] ^ s[3]};
    endfunction

    reg  [15:0] state;  //! Current state
    reg  [15:0] nxt;    //! Next state

    integer i;
    always @(*) begin : compute_next
        nxt = state;
        for (i = 0; i < STEP_N; i = i + 1)
            nxt = lfsr_step(nxt);
    end

    always @(posedge clk_ref or negedge rst_n) begin : update_state
        if (!rst_n)  
            state <= SEED;      
        else if (en) 
            state <= nxt;
    end

    wire signed [OUT_W-1:0] raw; //! LFSR_bits

    assign raw = state[OUT_W-1:0];

    assign dither = raw >>> cfg_amp_shift;

endmodule