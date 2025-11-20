# Logic-Networks-VHDL-Labs

## Compilation

To compile and analyse the vhd quickly run the following in the terminal (Mac & Linux)

```bash
ghdl -a --std=08 *.vcd
for i in {1,2,3,4}; do ghdl -e --std=08 "parking_tb_case$i";done
for i in {1,2,3,4}; do ghdl -r --std=08 "parking_tb_case$i" --vcd="case$i.vcd";done
```
