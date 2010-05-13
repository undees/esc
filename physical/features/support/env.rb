require 'tcl'

class TclWorld
  def tcl
    return @tcl if @tcl

    @tcl = Tcl::Interp.load_from_file('tcl/suspect.tcl')
    @tcl.eval IO.read('tcl/waveform_defs.tcl')
    @tcl
  end
end

World { TclWorld.new }
