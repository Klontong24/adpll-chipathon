FILE = dco

sim: ../src/*.v $(FILE)_tb.v
	iverilog -D IVERILOG_SIM -o $(FILE)_tb.vvp $(FILE)_tb.v ../src/*.v
	vvp $(FILE)_tb.vvp
wave: 
	gtkwave $(FILE)_tb.vcd
clean:
	rm -rf *.vvp *.vcd

