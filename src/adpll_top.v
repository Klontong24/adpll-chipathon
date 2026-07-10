// CHIPATHON 2026
//! @title ADPLL Top-Level Module
//! @author Muhammad Shofuwan Anwar, Ferhad Zulfas, Hardian Tri Pamungkas, Maulidan Imtinan Ahmada
//! @brief Structural top-level wrapper integrating BBPD, DLF, Dither, DCO, and Divider for the ADPLL system.

module adpll_top #(
    parameter integer DCO_W = 10,       
    parameter integer DIV_W = 8         
)(
    input  wire               clk_ref,  
    input  wire               rst_n,    
    input  wire               en,       
    
    input  wire [DIV_W-1:0]   div_ratio,
    input  wire [15:0]        kp,       
    input  wire [15:0]        ki,       
    
    output wire               clk_out   
);

    // Internal Interconnections 
    wire               clk_div;       
    wire               te_raw;        
    wire [DCO_W-1:0]   dco_code;      
    wire [5:0]         dither_val;    
    wire               te_sync_nc;    // No-connect wire for te_sync output

    // 1. Bang-Bang Phase Detector (BBPD)
    bbpd u_bbpd (
        .tref       (clk_ref),
        .tdiv       (clk_div),
        .rst_n      (rst_n),
        .te         (te_raw)
    );

    // 2. LFSR Dither Generator
    lfsr_dither u_lfsr_dither (
        .clk_ref        (clk_ref),
        .rst_n          (rst_n),
        .en             (en),
        .cfg_amp_shift  (3'd0),         // Default configuration (0 shift)
        .dither         (dither_val)
    );

    // 3. Digital Loop Filter (DLF - PI)
    dlf_pi #(
        .DCO_W(DCO_W)
    ) u_dlf_pi (
        .clk_ref    (clk_ref),
        .rst_n      (rst_n),
        .te_raw     (te_raw),           // Phase error mapping
        .kp         (kp[3:0]),          // Safe pruning to 4-bit
        .ki         (ki[3:0]),          // Safe pruning to 4-bit
        .dither_en  (en),               // Enable dither follows main EN signal
        .dither     (dither_val),       // Valid 6-bit width
        .dco_code   (dco_code),
        .te_sync    (te_sync_nc)
    );

    // 4. Digitally Controlled Ring Oscillator (DCRO)
    dco #(
        .DCO_W(DCO_W)
    ) u_dco (
        .en         (en),
        .dco_code   (dco_code),
        .clk_out    (clk_out)       
    );

    // 5. Programmable Clock Divider
    clk_divider #(
        .DIV_W(DIV_W)
    ) u_clk_divider (
        .clk_in     (clk_out),      
        .rst_n      (rst_n),
        .div_ratio  (div_ratio),    
        .clk_out    (clk_div)       
    );

endmodule




