# Mostly Bad Grounding 32 (MBG32)
> All-Digital Phase-Locked Loop (ADPLL) Hardware Design for Chipathon 2026.

## Team Members

| Name | GitHub Profile | University |
| :--- | :--- | :--- |
| Muhammad Shofuwan Anwar | [Shofuuu](https://github.com/Shofuuu) | National Taiwan University of Science and Technology (NTUST) |
| Ferhad Zulfas | [ferhadzulfas](http://github.com/ferhadzulfas) | Universitas Gadjah Mada (UGM) |
| Hardian Tri Pamungkas | [Klontong24](https://github.com/Klontong24) | Universitas Gadjah Mada (UGM) |
| Maulidan Imtinan Ahmada | [maulidaann](https://github.com/maulidaann) | Universitas Gadjah Mada (UGM) |

---

## Block Diagrams

### Bang-Bang Phase Detector (BB-PD)
**[Documentation](doc/bbpd.md)**

This block acts as the eye of the ADPLL, providing coarse sensing of the incoming reference clock (`tref`) and the feedback clock from the divider (`tdiv`), which is derived from the DCO output. 

If `tref` arrives earlier than `tdiv`, it indicates that the output frequency is too low and needs to be increased. Conversely, if `tdiv` arrives earlier than `tref`, the output clock is leading the reference clock, indicating that the output frequency should be decreased. 

It is called a "bang-bang" phase detector because its operation is binary, producing only UP or DOWN decisions rather than a continuous-valued output. The term "bang-bang" originates from control theory, where a controller switches directly between discrete states instead of making gradual adjustments.

### Proportional-Integral Digital Loop Filter (DLF-PI)
**[Documentation](doc/dlf_pi.md)**

*(Documentation in progress)*

### LFSR Dithering (LFSR-DITHER)
**[Documentation](doc/lfsr_dither.md)**

*(Documentation in progress)*

