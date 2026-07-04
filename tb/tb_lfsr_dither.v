`timescale 1ns/1ps

module tb_lfsr_dither;

    // Sinyal utama testbench
    reg clk = 0;
    reg rst_n = 0;
    reg en = 1;
    reg [2:0] amp = 3'd0;
    wire signed [5:0] dither;

    // Generator clock periode 40ns
    always #20 clk = ~clk;

    // Instansiasi modul LFSR Dither (DUT)
    lfsr_dither #(
        .OUT_W(6), 
        .STEP_N(7)
    ) dut (
        .clk_ref(clk), 
        .rst_n(rst_n), 
        .en(en),
        .cfg_amp_shift(amp), 
        .dither(dither)
    );

    initial begin
        // Setup perekaman file VCD untuk GTKWave
        $dumpfile("lfsr_dither.vcd");
        $dumpvars(0, tb_lfsr_dither);

        // KONDISI AWAL: Aktifkan reset
        rst_n = 0;
        en = 1;
        amp = 3'd0;
        #100;

        // SKENARIO 1: Lepas reset, jalankan amplitudo penuh (amp=0)
        rst_n = 1;
        #2000;

        // SKENARIO 2: Ubah ke amplitudo setengah (amp=1)
        amp = 3'd1;
        #2000;

        // SKENARIO 3: Aktifkan fitur freeze (en=0) untuk mengunci output
        en = 0;
        #500;

        // SKENARIO 4: Lepas freeze (en=1), kembali acak normal
        en = 1;
        #1000;

        $finish;
    end

endmodule