FILE = bbpd

sim: ../src/$(FILE).v $(FILE)_tb.v
	 iverilog -o $(FILE)_tb.vvp $(FILE)_tb.v ../src/$(FILE).v
	 vvp $(FILE)_tb.vvp

wave: $(FILE)_tb.vvp
	 gtkwave $(FILE)_tb.vcd

