require 'tcl'

class TclWorld
  def tcl
    @tcl ||= Tcl::Interp.load_from_file('tcl/waveform_defs.tcl')
  end
end

World { TclWorld.new }
