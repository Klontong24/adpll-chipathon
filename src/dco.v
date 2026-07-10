// CHIPATHON 2026
//! @title Digitally Controlled Ring Oscillator (DCRO)
//! @author Muhammad Shofuwan Anwar, Ferhad Zulfas, Hardian Tri Pamungkas, Maulidan Imtinan Ahmada
//! @brief Digitally controlled ring oscillator that modulates output clock frequency using an input tuning word.

module dco #(
    parameter integer DCO_W = 10  //! DCO control word width
)(
    input  wire                 en,         //! Enable oscillator (1: run, 0: stop)
    input  wire [DCO_W-1:0]     dco_code,   //! Tuning word from DLF
    output wire                 clk_out     //! DCO high-frequency clock output
);

    // Number of programmable delay stages based on the control word width
    localparam integer NUM_STAGES = 1024; 

    // Internal nets with synthesis attributes to preserve the physical delay loop
    (* keep = "true" *) (* dont_touch = "true" *) wire [NUM_STAGES-1:0] delay_chain;
    (* keep = "true" *) (* dont_touch = "true" *) wire [NUM_STAGES-1:0] intermediate_nodes;
    (* keep = "true" *) (* dont_touch = "true" *) wire mux_out;
    (* keep = "true" *) (* dont_touch = "true" *) wire feedback;

    // Core gating logic: Stage 0 uses a NAND gate to enable/disable control and provide inversion
    `ifdef IVERILOG_SIM
        assign #1 delay_chain[0] = ~(feedback & en);
    `else
        assign delay_chain[0] = ~(feedback & en);
    `endif

    // Tie-off the unused stage 0 intermediate node to ground to prevent 'X' state in simulation
    assign intermediate_nodes[0] = 1'b0;

    // Structural generation of the non-inverting programmable delay line
    genvar i;
    generate
        for (i = 1; i < NUM_STAGES; i = i + 1) begin : gen_delay_line
            
            // Macro to separate simulation behavior (needs delay) from physical synthesis (no delay)
            `ifdef IVERILOG_SIM
                // First inversion step (Simulation)
                assign #1 intermediate_nodes[i] = ~delay_chain[i-1];
                // Second inversion step (Simulation)
                assign #1 delay_chain[i] = ~intermediate_nodes[i];
            `else
                // First inversion step (Synthesis)
                assign intermediate_nodes[i] = ~delay_chain[i-1];
                // Second inversion step (Synthesis)
                assign delay_chain[i] = ~intermediate_nodes[i];
            `endif

        end
    endgenerate

    // Path selection mechanism based on the digital control code
    wire [DCO_W-1:0] inverted_code = ~dco_code;
    assign mux_out = delay_chain[inverted_code];

    // Closing the oscillator feedback loop
    assign feedback = mux_out;
    
    // Output clock assignment
    assign clk_out = feedback;

endmodule


