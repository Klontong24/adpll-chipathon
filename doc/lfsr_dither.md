
# Entity: lfsr_dither 
- **File**: lfsr_dither.v
- **Title:**  LFSR Generator for Dithering
- **Author:**  Muhammad Shofuwan Anwar, Ferhad Zulfas, Hardian Tri Pamungkas, Maulidan Imtinan Ahmada

## Diagram
![Diagram](lfsr_dither.svg "Diagram")
## Description


## Generics

| Generic name | Type    | Value    | Description |
| ------------ | ------- | -------- | ----------- |
| OUT_W        | integer | 6        |             |
| STEP_N       | integer | 7        |             |
| SEED         | [15:0]  | 16'hACE1 |             |

## Ports

| Port name     | Direction | Type                    | Description |
| ------------- | --------- | ----------------------- | ----------- |
| clk_ref       | input     | wire                    |             |
| rst_n         | input     | wire                    |             |
| en            | input     | wire                    |             |
| cfg_amp_shift | input     | wire [2:0]              |             |
| dither        | output    | wire signed [OUT_W-1:0] |             |

## Signals

| Name                   | Type             | Description |
| ---------------------- | ---------------- | ----------- |
| state                  | reg  [15:0]      |             |
| nxt                    | reg  [15:0]      |             |
| i                      | integer          |             |
| raw = state[OUT_W-1:0] | wire [OUT_W-1:0] |             |

## Functions
- lfsr_step <font id="function_arguments">(input [15:0] s)</font> <font id="function_return">return ([15:0])</font>

## Processes
- unnamed: ( @(*) )
  - **Type:** always
- unnamed: ( @(posedge clk_ref or negedge rst_n) )
  - **Type:** always
