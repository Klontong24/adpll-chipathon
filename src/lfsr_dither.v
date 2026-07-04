// CHIPATHON 2026
//! @title LFSR Generator for Dithering
//! @author Muhammad Shofuwan Anwar, Ferhad Zulfas, Hardian Tri Pamungkas, Maulidan Imtinan Ahmada

`timescale 1ns/1ps

module lfsr_dither #(
    parameter integer OUT_W  = 6,         // must match dlf_pi DITHER_W
    parameter integer STEP_N = 7,         // 65535
    parameter [15:0]  SEED   = 16'hACE1   // initial any nonzero value
)(
    input  wire                     clk_ref,
    input  wire                     rst_n,
    input  wire                     en,             // 0 = hold (freeze)
    input  wire [2:0]               cfg_amp_shift,  // amplitude, see table
    output wire signed [OUT_W-1:0]  dither
);

    function [15:0] lfsr_step(input [15:0] s);
        lfsr_step = {s[14:0], s[15] ^ s[14] ^ s[12] ^ s[3]};
    endfunction

    reg  [15:0] state;
    reg  [15:0] nxt;

    integer i;
    always @(*) begin
        nxt = state;
        for (i = 0; i < STEP_N; i = i + 1)
            nxt = lfsr_step(nxt);
    end

    always @(posedge clk_ref or negedge rst_n) begin
        if (!rst_n)  
            state <= SEED;      
        else if (en) 
            state <= nxt;
    end

    wire signed [OUT_W-1:0] raw = state[OUT_W-1:0];
    assign dither = (raw <<< cfg_amp_shift) >>> cfg_amp_shift;

endmodule