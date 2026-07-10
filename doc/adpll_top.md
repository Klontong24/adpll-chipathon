
# Entity: adpll_top 
- **File**: adpll_top.v
- **Title:**  ADPLL Top-Level Module
- **Author:**  Muhammad Shofuwan Anwar, Ferhad Zulfas, Hardian Tri Pamungkas, Maulidan Imtinan Ahmada
- **Brief:**  Structural top-level wrapper integrating BBPD, DLF, Dither, DCO, and Divider for the ADPLL system.

## Diagram
![Diagram](adpll_top.svg "Diagram")
## Description


## Generics

| Generic name | Type    | Value | Description |
| ------------ | ------- | ----- | ----------- |
| DCO_W        | integer | 10    |             |
| DIV_W        | integer | 8     |             |

## Ports

| Port name | Direction | Type             | Description |
| --------- | --------- | ---------------- | ----------- |
| clk_ref   | input     | wire             |             |
| rst_n     | input     | wire             |             |
| en        | input     | wire             |             |
| div_ratio | input     | wire [DIV_W-1:0] |             |
| kp        | input     | wire [15:0]      |             |
| ki        | input     | wire [15:0]      |             |
| clk_out   | output    | wire             |             |

## Signals

| Name       | Type             | Description |
| ---------- | ---------------- | ----------- |
| clk_div    | wire             |             |
| te_raw     | wire             |             |
| dco_code   | wire [DCO_W-1:0] |             |
| dither_val | wire [5:0]       |             |
| te_sync_nc | wire             |             |

## Instantiations

- u_bbpd: bbpd
- u_lfsr_dither: lfsr_dither
- u_dlf_pi: dlf_pi
- u_dco: dco
- u_clk_divider: clk_divider
