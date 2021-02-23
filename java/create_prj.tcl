set project_dir prj
set project_name top
create_project -force $project_name $project_dir -part xc7a35ticsg324-1L
set source_files { top/top.sv lib/synthesijer_mul32.vhd lib/rs232c_tx.vhd lib/clk_div.vhd lib/synthesijer_lshift32.vhd lib/rs232c_rx.vhd src/IO.vhd src/rs232c.vhd src/TicTacToe.vhd }
add_files -norecurse $source_files
set constraint_files { top/top.xdc }
add_files -fileset constrs_1 -norecurse $constraint_files
import_ip -files ipcores/clk_wiz_0/clk_wiz_0.xci
set_property top top [current_fileset]
update_compile_order -fileset sources_1
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
