// CHIPATHON 2026
//! @title DLF-PI Controller
//! @author Muhammad Shofuwan Anwar, Ferhad Zulfas, Hardian Tri Pamungkas, Maulidan Imtinan Ahmada

module dlf_pi #(
    parameter integer DCO_W = 10,   //! DCO control word width
    parameter integer FRAC  = 8     //! fractional bits (sub-LSB integral)
)(
    input  wire                clk_ref,      //! reference clock
    input  wire                rst_n,        //! async reset, active low
    input  wire                te_raw,       //! e[k] from bbpd
    input  wire [3:0]          kp,           //! beta  = 2^kp
    input  wire [3:0]          ki,           //! alpha = 2^-ki
    input  wire                dither_en,    //! enable dither
    input  wire signed [5:0]   dither,       //! signed dither, LSB units
    output reg  [DCO_W-1:0]    dco_code,     //! word to DCO
    output wire                te_sync       //! te sync
);

    localparam integer GUARD = 4;
    localparam integer AW    = DCO_W + FRAC + GUARD;

    localparam signed [AW-1:0]   ACC_MAX  = ((1 <<< (DCO_W-1)) - 1) <<< FRAC;
    localparam signed [AW-1:0]   ACC_MIN  = -ACC_MAX;
    localparam signed [AW+1:0]   CODE_MAX = (1 <<< DCO_W) - 1;
    localparam signed [AW+1:0]   CODE_MID = (1 <<< (DCO_W-1));

    reg                  te_ff;        //! te flip flop
    reg  signed [AW-1:0] acc;          //! integral accumulator

    wire [4:0]           kp_sh;        //! clamped proportional
    wire [4:0]           ki_sh;        //! clamped integral
    wire signed [AW-1:0] prop_mag;     //! proportional step magnitude (beta)
    wire signed [AW-1:0] prop_step;    //! signed proportional step (+/- beta)
    wire signed [AW-1:0] integ_mag;    //! integral step magnitude (alpha)
    wire signed [AW-1:0] integ_step;   //! signed integral step (+/- alpha)
    wire signed [AW:0]   acc_next;     //! accumulator next value (1 bit wider)
    wire                 acc_over;     //! acc_next above upper saturation limit
    wire                 acc_under;    //! acc_next below lower saturation limit
    wire signed [AW+1:0] dith_val;     //! dither shifted to DCO-LSB alignment
    wire signed [AW+1:0] pi_sum;       //! integral + proportional
    wire signed [AW+1:0] full_sum;     //! pi_sum + dither
    wire signed [AW+1:0] code_val;     //! DCO before clamp

    always @(posedge clk_ref or negedge rst_n) begin : sync_te
        if (!rst_n) 
            te_ff <= 1'b0;
        else        
            te_ff <= te_raw;
    end

    assign te_sync   = te_ff;

    assign kp_sh     = (kp > (DCO_W+GUARD-2)) ? (DCO_W+GUARD-2) : kp;
    assign ki_sh     = (ki > FRAC)            ? FRAC            : ki;

    assign prop_mag  = $signed(1) <<< (FRAC + kp_sh);
    assign prop_step = te_ff ? prop_mag : -prop_mag;

    assign integ_mag  = $signed(1) <<< (FRAC - ki_sh);
    assign integ_step = te_ff ? integ_mag : -integ_mag;

    assign acc_next  = acc + integ_step;

    always @(posedge clk_ref or negedge rst_n) begin : integrator
        if (!rst_n)
            acc <= 0;
        else if (acc_next > ACC_MAX)  
            acc <= ACC_MAX;
        else if (acc_next < ACC_MIN) 
            acc <= ACC_MIN;
        else                
            acc <= acc_next;
    end

    assign dith_val  = dither_en ? (dither <<< FRAC) : 0;

    assign pi_sum    = acc + prop_step;
    assign full_sum  = pi_sum + dith_val;
    assign code_val  = (full_sum >>> FRAC) + CODE_MID;


    always @(posedge clk_ref or negedge rst_n) begin : output_reg
        if (!rst_n)
            dco_code <= CODE_MID[DCO_W-1:0];
        else if (code_val < 0)  
            dco_code <= 0;
        else if (code_val > CODE_MAX) 
            dco_code <= CODE_MAX[DCO_W-1:0];
        else                
            dco_code <= code_val[DCO_W-1:0];
    end

endmodule