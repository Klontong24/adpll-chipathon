
# Entity: bbpd 
- **File**: bbpd.v
- **Title:**  Bang-Bang Phase Detector
- **Author:**  Muhammad Shofuwan Anwar, Ferhad Zulfas, Hardian Tri Pamungkas, Maulidan Imtinan Ahmada

## Diagram
![Diagram](bbpd.svg "Diagram")
## Description


## Ports

| Port name | Direction | Type | Description                           |
| --------- | --------- | ---- | ------------------------------------- |
| tref      | input     | wire | reference clock                       |
| tdiv      | input     | wire | clock from clk_div generated from DCO |
| rst_n     | input     | wire | FF reset                              |
| te        | output    |      | signal output e[k]                    |

## Signals

| Name   | Type | Description                    |
| ------ | ---- | ------------------------------ |
| q_ref  | reg  | FF output from captured signal |
| q_div  | reg  | FF output from captured signal |
| ff_rst | wire | combinational reset            |

## Processes
- dff_up: ( @(posedge tref or negedge ff_rst) )
  - **Type:** always
  - **Description**
  This DFF is used to capture the reference signal 
- dff_down: ( @(posedge tdiv or negedge ff_rst) )
  - **Type:** always
  - **Description**
  This DFF is used to capture the division signal (signal from clk_div) 
- priority_encoder: ( @(posedge q_div or negedge rst_n) )
  - **Type:** always
  - **Description**
  This DFF act as "priority encoder", which one is more faster, tref or tdiv 
