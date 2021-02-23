open_project tictactoe
set_top make_turn
add_files make_turn.cpp
add_files -tb tb_make_turn.cpp
open_solution "solution1"
set_part {xc7a35ticsg324-1L}
create_clock -period 100MHz -name default
csim_design -clean
csynth_design
cosim_design -trace_level all
export_design -rtl verilog -format ip_catalog -version "1.0"

