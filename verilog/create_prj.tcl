set project_dir prj
set project_name top
create_project -force $project_name $project_dir -part xc7a35ticsg324-1L
set source_files { src/game_manager.sv src/uart_rx.sv src/print_result.sv src/main.sv src/print_board.sv src/recv_user_input.sv src/clk_div.sv src/make_turn.sv src/uart_tx.sv src/make_judge.sv }
add_files -norecurse $source_files
set constraint_files { src/main.xdc }
add_files -fileset constrs_1 -norecurse $constraint_files
set sim_files { sim/make_turn_tb.sv sim/recv_user_input_tb.sv sim/game_manager_tb.sv sim/print_result_tb.sv sim/print_board_tb.sv sim/make_judge_tb.sv }
add_files -fileset sim_1 -norecurse $sim_files
import_ip -files ipcores/ila_0/ila_0.xci
import_ip -files ipcores/vio_0/vio_0.xci
import_ip -files ipcores/clk_wiz_0/clk_wiz_0.xci
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
