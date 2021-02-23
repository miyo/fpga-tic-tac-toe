require './vivado_util.rb'

def main()
  dir="prj"
  name="top"
  
  vivado = Vivado.new(dir=dir, name=name, top="top")
  #vivado.add_parameters({"general.maxThreads" => 1})
  
  vivado.set_target("xc7a35ticsg324-1L")
  vivado.add_sources(Dir.glob("src/*.sv"))
  vivado.add_constraints(Dir.glob("src/*.xdc"))
  vivado.add_testbenchs(Dir.glob("sim/*.sv"))
  vivado.add_ipcores(Dir.glob("ipcores/**/*.xci"))
  
  #vivado.add_verilog_define({"BOARD_ID" => board_id})
  
  vivado.generate_tcl("create_prj.tcl")
  #vivado.run()
  
  config = Vivado.new(dir=dir, name=name, top="top", kind=Vivado.CONFIG)
  config.set_chip("xc7a35t_0")
  config.generate_tcl("config_board.tcl")
  #config.run()
end

main()
