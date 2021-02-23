set project_dir prj
set project_name top
create_project -force $project_name $project_dir -part xc7a35ticsg324-1L
set source_files { ./verilog/game_manager.sv ./verilog/main.sv ../verilog/src/game_manager.sv ../verilog/src/uart_rx.sv ../verilog/src/print_result.sv ../verilog/src/main.sv ../verilog/src/print_board.sv ../verilog/src/recv_user_input.sv ../verilog/src/clk_div.sv ../verilog/src/make_turn.sv ../verilog/src/uart_tx.sv ../verilog/src/make_judge.sv }
add_files -norecurse $source_files
set constraint_files { ../verilog/src/main.xdc }
add_files -fileset constrs_1 -norecurse $constraint_files
set sim_files { ./verilog/make_turn_tb.sv }
add_files -fileset sim_1 -norecurse $sim_files
import_ip -files ../verilog/ipcores/ila_0/ila_0.xci
import_ip -files ../verilog/ipcores/vio_0/vio_0.xci
import_ip -files ../verilog/ipcores/clk_wiz_0/clk_wiz_0.xci

set_property ip_repo_paths ./tictactoe/solution1/impl/ip [current_project]
update_ip_catalog
create_ip -name make_turn -vendor xilinx.com -library hls -version 1.0 -module_name make_turn_0
generate_target {instantiation_template} [get_files $project_dir/top.srcs/sources_1/ip/make_turn_0/make_turn_0.xci]

set_property top top [current_fileset]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
reset_project
launch_runs synth_1 -jobs 4
wait_on_run synth_1
launch_runs impl_1 -jobs 4
wait_on_run impl_1
open_run impl_1
report_utilization -file [file join $project_dir "project.rpt"]
report_timing -file [file join $project_dir "project.rpt"] -append
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
close_project
quit
