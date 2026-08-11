vlib work
vcom and_gate.vhd
vcom tb_and_gate.vhd
vsim -c work.tb_and_gate
vcd file and_gate.vcd
vcd add -r /*
run 100 ns
quit -f
