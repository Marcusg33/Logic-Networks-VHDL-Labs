# Logic-Networks-VHDL-Labs

## Compilation

To compile and analyse the vhd quickly run the following in the terminal (Mac & Linux)

```bash
ghdl -a --std=08 *.vhd
for i in {1,2,3,4}; do ghdl -e --std=08 "parking_tb_case$i";done
for i in {1,2,3,4}; do ghdl -r --std=08 "parking_tb_case$i" --vcd="case$i.vcd";done
```

For Windows

```powershell
# Analyze all VHD files
ghdl -a --std=08 *.vhd

# Elaborate tests 1..4
for ($i = 1; $i -le 4; $i++) { ghdl -e --std=08 "parking_tb_case$i" }

# Run tests and produce VCDs case1..case4.vcd
for ($i = 1; $i -le 4; $i++) { ghdl -r --std=08 "parking_tb_case$i" --vcd="case$i.vcd" }
```
