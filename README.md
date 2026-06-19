# Mostly Bad Grounding 32 (MBG32)
## All-Digital Phase-Locked Loop (ADPLL) hardware design for Chipathon 2026.

### Group Members:
- Muhammad Shofuwan Anwar [(Github: Shofuuu)](https://github.com/Shofuuu)
- Ferhad Zulfas [(Github: ferhadzulfas)](http://github.com/ferhadzulfas)
- Hardian Tri Pamungkas [(Github: Klontong24)](https://github.com/Klontong24)
- Maulidan Imtinan Ahmada [(Github: maulidaann)](https://github.com/maulidaann)

### Diagram block:
- **BB-PD [[Documentation]](doc/bbpd.md)**\
This block acts as the eye of the ADPLL, providing coarse sensing of the incoming reference clock (`tref`) and the feedback clock from the divider (`tdiv`), which is derived from the DCO output. If `tref` arrives earlier than `tdiv`, it indicates that the output frequency is too low and needs to be increased. Conversely, if `tdiv` arrives earlier than `tref`, the output clock is leading the reference clock, indicating that the output frequency should be decreased. It is called a "bang-bang" phase detector because its operation is binary, producing only UP or DOWN decisions rather than a continuous-valued output. The term "bang-bang" originates from control theory, where a controller switches directly between discrete states instead of making gradual adjustments.
