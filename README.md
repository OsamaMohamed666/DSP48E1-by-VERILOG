# DSP48E1-by-VERILOG
## Reference:  
[https://0x04.net/~mwk/xidocs/ug/ug479_7Series_DSP48E1.pdf]


## Block Diagram
![image](https://github.com/user-attachments/assets/5ea1b237-c23d-4c8f-91f3-c375e94fb362)

## My Implementation supervised by CND-LAB.
Differences 
  1. I used the same architecture as DSP48E1 but without the pattern detection block. 
  2. I used only one high-synchronized reset for all flip-flops.  
  3. No MULTSIGNIN & MULTSIGNOUT PORTS.
  4. All the parameters that control the muxes I used as inputs to simplify the direct test cases.




