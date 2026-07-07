
# Entity: gshift_dlf 
- **File**: gshift_dlf.v
- **Title:**  Gear-Shifting Digital Loop Filter (DLF)
- **Author:**  Muhammad Shofuwan Anwar, Ferhad Zulfas, Hardian Tri Pamungkas, Maulidan Imtinan Ahmada
- **Brief:**  Proportional-Integral (PI) loop filter featuring an adaptive gear-shifting mechanism for fast frequency acquisition and optimal jitter reduction.

## Diagram
![Diagram](gshift_dlf.svg "Diagram")
## Description


## Ports

| Port name | Direction | Type   | Description                                                            |
| --------- | --------- | ------ | ---------------------------------------------------------------------- |
| te        | input     | wire   | e[k] direction reference from BB-PD (1: speed up, 0: slow down)        |
| clk       | input     | wire   | Main system clock                                                      |
| rst_n     | input     | wire   | Asynchronous active-low reset                                          |
| tune      | output    | [15:0] | 16-bit tuning word output to the Digitally Controlled Oscillator (DCO) |

## Signals

| Name                                      | Type              | Description                                                                           |
| ----------------------------------------- | ----------------- | ------------------------------------------------------------------------------------- |
| lock_count                                | reg [4:0]         | 5-bit saturating counter to track consecutive direction changes (0 to 16)             |
| te_prev                                   | reg               | Register to store the previous state of the phase error (te)                          |
| dirchg = (te != te_prev)                  | wire              | High if the BB-PD changes direction, indicating phase oscillation around the target   |
| locked = (lock_count == 5'd16)            | wire              | Asserts high when the PLL achieves a steady locked state                              |
| kp_shift                                  | reg [3:0]         | Arithmetic right/left shift value representing the Proportional gain                  |
| ki_shift                                  | reg [3:0]         | Arithmetic right/left shift value representing the Integral gain                      |
| te_signed = (te == 1'b1) ? 2'sd1 : -2'sd1 | wire [1:0]        | Convert the 1-bit binary error signal (0 or 1) into a 2-bit signed integer (-1 or +1) |
| proportional_net = te_signed <<< kp_shift | wire [15:0]       | Apply Proportional gain using arithmetic bit-shifting for hardware efficiency         |
| integral_net = te_signed <<< ki_shift     | wire [15:0]       | Apply Integral gain using arithmetic bit-shifting for hardware efficiency             |
| integral_reg                              | reg signed [15:0] | 16-bit accumulator register for the Integral path                                     |

## Processes
- leaky_bucket_lock_detector: ( @(posedge clk or negedge rst_n) )
  - **Type:** always
  - **Description**
  This block utilizes a Leaky Bucket algorithm to monitor BB-PD phase oscillations 
- gear_shifting_fsm: ( @(posedge clk or negedge rst_n) )
  - **Type:** always
  - **Description**
  Dynamically adjusts the PI gains based on the PLL lock status 
- integral_accumulator: ( @(posedge clk or negedge rst_n) )
  - **Type:** always
  - **Description**
  Integral accumulator block executing the core arithmetic integration 
- tuning_word_synthesis: ( @(posedge clk or negedge rst_n) )
  - **Type:** always
  - **Description**
  Tuning word synthesis by summing Proportional and Integral paths 
