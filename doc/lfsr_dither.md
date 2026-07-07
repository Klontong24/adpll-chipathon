
# Entity: lfsr_dither 
- **File**: lfsr_dither.v
- **Title:**  LFSR Generator for Dithering
- **Author:**  Muhammad Shofuwan Anwar, Ferhad Zulfas, Hardian Tri Pamungkas, Maulidan Imtinan Ahmada

## Diagram
![Diagram](lfsr_dither.svg "Diagram")
## Description


## Generics

| Generic name | Type    | Value | Description     |
| ------------ | ------- | ----- | --------------- |
| OUT_W        | integer | 6     | Output width    |
| STEP_N       | integer | 7     | Steps per clock |

## Ports

| Port name     | Direction | Type                    | Description       |
| ------------- | --------- | ----------------------- | ----------------- |
| clk_ref       | input     | wire                    | Reference clock   |
| rst_n         | input     | wire                    | Async reset       |
| en            | input     | wire                    | Enable/freeze     |
| cfg_amp_shift | input     | wire [2:0]              | Amplitude control |
| dither        | output    | wire signed [OUT_W-1:0] | Dither output     |

## Signals

| Name  | Type             | Description   |
| ----- | ---------------- | ------------- |
| state | reg  [15:0]      | Current state |
| nxt   | reg  [15:0]      | Next state    |
| i     | integer          |               |
| raw   | wire [OUT_W-1:0] | LFSR_bits     |

## Constants

| Name | Type | Value    | Description   |
| ---- | ---- | -------- | ------------- |
| SEED |      | 16'hACE1 | Initial state |

## Functions
- lfsr_step <font id="function_arguments">(input [15:0] s)</font> <font id="function_return">return ([15:0])</font>
  -  One LFSR step
## Processes
- compute_next: ( @(*) )
  - **Type:** always
- update_state: ( @(posedge clk_ref or negedge rst_n) )
  - **Type:** always
